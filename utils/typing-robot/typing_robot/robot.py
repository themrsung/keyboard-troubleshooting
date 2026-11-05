"""The typing robot: which finger presses each key, two hands, and a virtual board to type on.

The robot is built deterministically from a profile (the interview's answers). Same profile, same
robot, same numbers. Fingers are written as the typist says them: side and number, "L2" for the left
index, "R5" for the right pinky; finger one is the thumb.

Fingers belong to physical keys, not to characters: when a candidate layout puts another letter
on a key, the robot still presses that key with the same finger. That's what makes a layout
comparison meaningful.
"""
import math
from dataclasses import dataclass

from .hand import DEFAULT_SPAN, Hand

STAGGER = 0.375   # u: how far a row sits right of the row above it, on a row-staggered board


def finger_code(side, f):
    return f"{side}{f}"


def parse_code(code):
    return code[0], int(code[1])


def default_home(board, layout):
    """Home keys for the eight fingers, from the baseline layout: A S D F and J K L, and for the right
    pinky the key right of L (; on ANSI, Enter on the WeCat4)."""
    home = {}
    for code, ch in zip(("L5", "L4", "L3", "L2", "R2", "R3", "R4"), "asdfjkl"):
        home[code] = layout[ch]
    l_key = board.by_id[layout["l"]]
    right = [k for k in board.lines()[l_key.line] if k.x > l_key.x]
    home["R5"] = right[0].id if right else layout["l"]
    return home


def default_fingers(board, home, layout):
    """A touch typist's finger for every key, from where the home keys are. Each key goes to the
    nearest home finger after undoing the row stagger; left of the gap between the index fingers is
    the left hand. Keys on a row with no letters (the bottom row) go to the thumbs."""
    hkeys = {code: board.by_id[kid] for code, kid in home.items()}
    home_line = hkeys["L2"].line
    boundary = (hkeys["L2"].cx + hkeys["R2"].cx) / 2
    letter_lines = {board.by_id[kid].line for ch, kid in layout.items() if ch.isalpha()}
    out = {}
    for k in board.keys:
        x = k.cx - STAGGER * (k.line - home_line)
        side = "L" if x < boundary else "R"
        if k.line not in letter_lines:
            out[k.id] = finger_code(side, 1)
            continue
        best = min((c for c in hkeys if c[0] == side), key=lambda c: (abs(hkeys[c].cx - x), c))
        out[k.id] = best
    return out


@dataclass
class Stroke:
    char: str
    key: str
    finger: str
    tip_travel: float
    effort: float
    wrist_shift: float


class Robot:
    def __init__(self, board, fingers, home, spans, space_thumb="R", weights=None):
        """fingers: {key id: "L2"...}; home: {"L5": key id, ...} for fingers 2–5; spans: {"L": u, "R": u}."""
        self.board = board
        self.fingers = dict(fingers)
        self.home = dict(home)
        self.spans = dict(spans)
        self.space_thumb = space_thumb
        tips = {"L": {}, "R": {}}
        for code, kid in home.items():
            side, f = parse_code(code)
            k = board.by_id[kid]
            tips[side][f] = (k.cx, k.cy)
        # Thumbs rest on the Space nearest to them, about a key in from the index finger.
        for side, inward in (("L", 1.0), ("R", -1.0)):
            index = tips[side][2]
            spaces = [k for k in board.keys if self.fingers.get(k.id) == finger_code(side, 1) and k.w >= 2] \
                or [k for k in board.keys if self.fingers.get(k.id) == finger_code(side, 1)]
            k = min(spaces, key=lambda k: abs(k.cx - (index[0] + inward)))
            x = min(max(index[0] + inward, k.x + 0.5), k.x + k.w - 0.5)
            tips[side][1] = (x, k.cy)
        self.hands = {side: Hand(side, self.spans.get(side, DEFAULT_SPAN), tips[side], weights) for side in "LR"}
        self._poses = {}
        self._cache = {}

    @classmethod
    def from_profile(cls, board, layout, profile=None, weights=None):
        profile = profile or {}
        home = profile.get("home") or default_home(board, layout)
        fingers = default_fingers(board, home, layout)
        votes = {}
        for a in profile.get("answers", []):
            kid = layout.get(a["char"])
            if kid:
                votes.setdefault(kid, []).append(a["finger"])
        for kid, vs in votes.items():
            # The most common answer; on a tie, the first one given.
            fingers[kid] = max(dict.fromkeys(vs), key=vs.count)
        spans = profile.get("spans") or {"L": DEFAULT_SPAN, "R": DEFAULT_SPAN}
        robot = cls(board, fingers, home, spans, profile.get("space_thumb", "R"), weights)
        robot.answered = set(votes)
        return robot

    def key_pose(self, kid):
        if kid not in self._poses:
            side, f = parse_code(self.fingers[kid])
            k = self.board.by_id[kid]
            self._poses[kid] = self.hands[side].pose(f, (k.cx, k.cy))
        return self._poses[kid]

    def strokes(self, keys, chars=None):
        """Types a run of keys (one word) from rest, then lets the hands go back to rest. Returns
        each keystroke, and the cost of the return as a last Stroke with char None."""
        pose = {(s, f): self.hands[s].rest[f] for s in "LR" for f in self.hands[s].rest}
        wrist = {"L": (0.0, 0.0), "R": (0.0, 0.0)}
        out = []
        for i, kid in enumerate(keys):
            side, f = parse_code(self.fingers[kid])
            hand = self.hands[side]
            new = self.key_pose(kid)
            cur = pose[(side, f)]
            e = hand.effort(f, cur, new, wrist[side], new.shift)
            out.append(Stroke(chars[i] if chars else "", kid, finger_code(side, f), math.dist(cur.tip, new.tip), e,
                              math.hypot(*new.shift)))
            pose[(side, f)] = new
            wrist[side] = new.shift
        back_e = back_t = 0.0
        for (side, f), p in pose.items():
            rest = self.hands[side].rest[f]
            back_e += self.hands[side].effort(f, p, rest, (0.0, 0.0), (0.0, 0.0))
            back_t += math.dist(p.tip, rest.tip)
        back_e += sum(self.hands[s].weights["wrist"] * math.hypot(*wrist[s]) for s in "LR")
        out.append(Stroke(None, "", "", back_t, back_e, 0.0))
        return out

    def word_cost(self, keys):
        """(effort, tip travel) of typing a word's keys, including the return to rest."""
        keys = tuple(keys)
        if keys not in self._cache:
            s = self.strokes(keys)
            self._cache[keys] = (sum(x.effort for x in s), sum(x.tip_travel for x in s))
        return self._cache[keys]

    def side_of(self, kid):
        return self.fingers[kid][0]
