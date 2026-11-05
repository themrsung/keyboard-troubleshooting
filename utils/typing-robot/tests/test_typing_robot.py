"""python3 -B -m unittest discover -s utils/typing-robot/tests"""
import json
import math
import os
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from typing_robot import board as boardmod, corpus, interview, metrics, optimize  # noqa: E402
from typing_robot.robot import Robot  # noqa: E402

BOARD_DIR = os.path.join(ROOT, "boards", "gats-wecat4")


def wecat4():
    board = boardmod.load_board(os.path.join(BOARD_DIR, "definition.json"))
    keymap = boardmod.load_keymap(os.path.join(BOARD_DIR, "layout.json"), board)
    return board, keymap, boardmod.layout_of(keymap)


class BoardTest(unittest.TestCase):
    def test_rows_are_13u_and_44_keys(self):
        board, _, _ = wecat4()
        self.assertEqual(len(board.keys), 44)
        for row in board.lines():
            self.assertAlmostEqual(row[-1].x + row[-1].w, 13.0)

    def test_measured_widths(self):
        board, _, _ = wecat4()
        bottom = [k.w for k in board.lines()[3]]
        self.assertEqual(bottom, [1.25, 1, 1.25, 2.25, 1, 2.75, 1.25, 1, 1.25])

    def test_layout_has_the_letters(self):
        _, _, layout = wecat4()
        self.assertTrue(set("abcdefghijklmnopqrstuvwxyz,./ ") <= set(layout))
        self.assertEqual(layout["/"], "2,1")   # left of Z
        self.assertEqual(layout[" "], "3,4")   # the left Space comes first

    def test_vendor_product_id_matches_the_saved_layout(self):
        board, _, _ = wecat4()
        with open(os.path.join(BOARD_DIR, "layout.json")) as f:
            self.assertEqual(json.load(f)["vendorProductId"], board.vendor_product_id)

    def test_save_keymap_round_trips(self):
        board, _, layout = wecat4()
        lay = dict(layout)
        lay["e"], lay["r"] = layout["r"], layout["e"]
        with tempfile.TemporaryDirectory() as d:
            path = os.path.join(d, "x.json")
            boardmod.save_keymap(os.path.join(BOARD_DIR, "layout.json"), path, board, lay)
            self.assertEqual(boardmod.layout_of(boardmod.load_keymap(path, board)), lay)


class RobotTest(unittest.TestCase):
    def setUp(self):
        self.board, self.keymap, self.layout = wecat4()
        self.robot = Robot.from_profile(self.board, self.layout)

    def test_default_fingers(self):
        f = lambda c: self.robot.fingers[self.layout[c]]
        self.assertEqual([f(c) for c in "qazb"], ["L5", "L5", "L5", "L2"])
        self.assertEqual([f(c) for c in "tgy"], ["L2", "L2", "R2"])
        self.assertEqual([f(c) for c in "hnp"], ["R2", "R2", "R5"])
        self.assertEqual(self.robot.home["R5"], "1,11")   # Enter, right of L
        self.assertEqual(self.robot.fingers["3,4"], "L1")
        self.assertEqual(self.robot.fingers["3,7"], "R1")

    def test_home_row_is_free_and_reaches_cost(self):
        self.assertEqual(self.robot.word_cost([self.layout[c] for c in "asdf"]), (0.0, 0.0))
        e_top, _ = self.robot.word_cost([self.layout["r"]])
        e_far, _ = self.robot.word_cost([self.layout["b"]])
        self.assertGreater(e_top, 0)
        self.assertGreater(e_far, 0)

    def test_root_joints_weigh_more(self):
        # The same reach costs more when the wrist has to move: a smaller hand reaches less.
        small = Robot.from_profile(self.board, self.layout, {"spans": {"L": 6.0, "R": 6.0}})
        far = [self.layout["t"]]
        s = small.strokes(far)[0]
        self.assertGreater(s.wrist_shift, 0)
        heavy = Robot.from_profile(self.board, self.layout, {"spans": {"L": 6.0, "R": 6.0}}, {"wrist": 10.0})
        self.assertGreater(heavy.word_cost(far)[0], small.word_cost(far)[0])

    def test_answers_override_by_majority(self):
        profile = {"answers": [{"word": "but", "char": "b", "finger": "R2"},
                               {"word": "big", "char": "b", "finger": "R2"},
                               {"word": "bed", "char": "b", "finger": "L2"}]}
        robot = Robot.from_profile(self.board, self.layout, profile)
        self.assertEqual(robot.fingers[self.layout["b"]], "R2")

    def test_pose_reaches_its_target(self):
        hand = self.robot.hands["L"]
        k = self.board.by_id[self.layout["q"]]
        p = hand.pose(5, (k.cx, k.cy))
        kx, ky = hand.knuckle[5]
        seg = hand.length[5] / 2
        a = hand.forward[5] + p.mcp
        tip = (kx + p.shift[0] + seg * math.cos(a) + seg * math.cos(a + p.pip),
               ky + p.shift[1] + seg * math.sin(a) + seg * math.sin(a + p.pip))
        self.assertAlmostEqual(tip[0], k.cx, places=6)
        self.assertAlmostEqual(tip[1], k.cy, places=6)


class MetricsAndSearchTest(unittest.TestCase):
    def setUp(self):
        self.board, _, self.layout = wecat4()
        self.robot = Robot.from_profile(self.board, self.layout)
        self.words = corpus.load_words()[:150]
        self.letters = corpus.load_letters()

    def test_baseline_has_nothing_moved(self):
        r = metrics.evaluate(self.robot, self.layout, self.words, self.letters, self.layout)
        self.assertEqual((r.moved, r.finger_changed), (0.0, 0.0))
        self.assertGreater(r.effort, 0)
        self.assertTrue(0 <= r.one_hand <= 100)

    def test_moved_is_weighted_by_frequency(self):
        lay = dict(self.layout)
        lay["e"], lay["r"] = self.layout["r"], self.layout["e"]
        r = metrics.evaluate(self.robot, lay, self.words, self.letters, self.layout)
        total = sum(self.letters.values())
        self.assertAlmostEqual(r.moved, 100 * (self.letters["e"] + self.letters["r"]) / total)
        self.assertAlmostEqual(r.finger_changed, r.moved)   # e (L3) and r (L2) swap fingers

    def test_constraints_hold_and_search_is_deterministic(self):
        for name, cons in optimize.PRESETS.items():
            lay = optimize.suggest(self.robot, self.layout, self.words, self.letters, cons)
            self.assertTrue(cons.allows(lay, self.layout, self.robot), name)
            self.assertEqual(sorted(lay), sorted(self.layout))
            self.assertEqual(len(set(lay.values())), len(lay))
        a = optimize.suggest(self.robot, self.layout, self.words, self.letters, optimize.PRESETS["no-interrow"])
        b = optimize.suggest(self.robot, self.layout, self.words, self.letters, optimize.PRESETS["no-interrow"])
        self.assertEqual(a, b)
        for c, kid in a.items():
            self.assertEqual(self.board.by_id[kid].line, self.board.by_id[self.layout[c]].line)


class InterviewTest(unittest.TestCase):
    def test_parsers(self):
        self.assertEqual(interview.parse_span("9.5u"), 9.5)
        self.assertEqual(interview.parse_span("190.5mm"), 10.0)
        self.assertEqual(interview.parse_span("19.05 cm"), 10.0)
        self.assertRaises(ValueError, interview.parse_span, "big")
        self.assertEqual(interview.parse_finger("left index"), "L2")
        self.assertEqual(interview.parse_finger("R5"), "R5")
        self.assertEqual(interview.parse_finger("r thumb"), "R1")
        self.assertRaises(ValueError, interview.parse_finger, "R7")

    def test_scripted_interview(self):
        board, keymap, layout = wecat4()
        answers = iter(["9", "", "y", "R", "R2", "L2", "", "R2"])
        said = []
        profile = interview.run(board, keymap, layout, corpus.load_words(), ask=lambda _: next(answers),
                                say=said.append, rounds=3)
        self.assertEqual(profile["spans"], {"L": 9.0, "R": 10.5})
        self.assertEqual([a["finger"] for a in profile["answers"]], ["R2", "L2", "R2"])
        self.assertEqual([a["char"] for a in profile["answers"]], ["b", "t", "g"])
        self.assertTrue(any("Didn't get that" in s for s in said))
        robot = Robot.from_profile(board, layout, profile)
        self.assertEqual(robot.fingers[layout["g"]], "R2")


class ChordsTest(unittest.TestCase):
    """Characters on the Fn layers are typed with chords, and stay on their physical keys whatever the
    base layer is rearranged to."""

    def setUp(self):
        from typing_robot.chords import Chords
        board, keymap, self.layout = wecat4()
        self.robot = Robot.from_profile(board, self.layout)
        self.robot.base_keymap = keymap
        path = os.path.join(BOARD_DIR, "layout.json")
        with open(path, encoding="utf-8") as f:
            n = len(json.load(f)["layers"])
        self.robot.layers = {i: boardmod.load_keymap(path, board, i) for i in range(1, n)}
        self.chords = Chords(self.robot)

    def test_jis_chords(self):
        t = self.chords.table(self.layout)
        fn = {kid for kid, kc in self.robot.base_keymap.items() if kc == "MO(1)"}
        shifts = {kid for kid, kc in self.robot.base_keymap.items() if kc in ("KC_LSFT", "KC_RSFT")}
        self.assertEqual(t["a"], (self.layout["a"],))
        self.assertIn(t["A"][0], shifts)
        # Shift + 7 is ' on JIS, and 7 is Fn1 + U: Fn, Shift, then the key.
        self.assertIn(t["'"][0], fn)
        self.assertIn(t["'"][1], shifts)
        self.assertEqual(t["'"][-1], self.layout["u"])
        self.assertEqual(t[";"][-1], self.layout["m"])   # KC_SCLN on Fn1 + M
        self.assertEqual(t[":"][-1], self.layout[","])   # KC_QUOT types : on JIS

    def test_fn_layers_dont_follow_the_base_layer(self):
        before = self.chords.table(self.layout)
        lay = dict(self.layout)
        lay["."], lay["z"] = self.layout["z"], self.layout["."]
        after = self.chords.table(lay)
        for c in ("\\", ";", ":", "'", "1"):   # ろ (\\) is Fn + the original . key
            self.assertEqual(after[c], before[c], c)
        self.assertEqual(after["."], (self.layout["z"],))
        self.assertEqual(after[">"][-1], self.layout["z"])   # Shift + . follows the new .


if __name__ == "__main__":
    unittest.main()
