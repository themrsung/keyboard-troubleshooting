"""typing-robot: build a robot that types like you, then look for easier layouts.

    typing-robot interview            # the setup questions; writes the profile
    typing-robot show                 # the robot: each key's finger, and the hand model
    typing-robot type "bird"          # the robot types on the virtual board, stroke by stroke
    typing-robot evaluate [LAYOUT…]   # the three axes, for VIA saved layouts, against the baseline
    typing-robot suggest              # search for layouts under each preset constraint, and test them
"""
import argparse
import json
import os
import sys

from . import board as boardmod
from . import corpus, interview, metrics, optimize, render
from .hand import DEFAULT_SPAN, DEFAULT_WEIGHTS, FINGER_NAMES
from .robot import Robot

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_BOARD = os.path.join(ROOT, "boards", "gats-wecat4")
DEFAULT_PROFILE = os.path.join(ROOT, "profiles", "profile.json")


def load(args):
    board = boardmod.load_board(os.path.join(args.board, "definition.json"))
    keymap_path = args.keymap or os.path.join(args.board, "layout.json")
    keymap = boardmod.load_keymap(keymap_path, board)
    baseline = boardmod.layout_of(keymap)
    profile = None
    if os.path.exists(args.profile):
        with open(args.profile, encoding="utf-8") as f:
            profile = json.load(f)
    weights = {k: getattr(args, k) for k in DEFAULT_WEIGHTS if getattr(args, k, None) is not None}
    robot = Robot.from_profile(board, baseline, profile, weights)
    # The board's other layers, so characters on them (and capitals) can be typed with chords.
    with open(keymap_path, encoding="utf-8") as f:
        n_layers = len(json.load(f)["layers"])
    robot.base_keymap = keymap
    robot.layers = {n: boardmod.load_keymap(keymap_path, board, n) for n in range(1, n_layers)}
    return board, keymap, keymap_path, baseline, profile, robot


def note_profile(args, profile):
    if profile is None:
        print(f"No profile at {args.profile}: using a default touch typist with {DEFAULT_SPAN} u hands. "
              "Run `typing-robot interview` first.\n")


def cmd_interview(args):
    board, keymap, _, baseline, _, _ = load(args)
    words = corpus.load_words(args.words)
    try:
        profile = interview.run(board, keymap, baseline, words, rounds=args.rounds)
    except (EOFError, KeyboardInterrupt):
        print("\nInterview stopped: nothing saved.")
        return 1
    os.makedirs(os.path.dirname(os.path.abspath(args.profile)), exist_ok=True)
    with open(args.profile, "w", encoding="utf-8") as f:
        json.dump(profile, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"Saved {args.profile}.")
    args_show = argparse.Namespace(**vars(args))
    cmd_show(args_show)


def cmd_show(args):
    board, _, _, baseline, profile, robot = load(args)
    note_profile(args, profile)
    print(f"{board.name}: each key's character and the finger that presses it (L2 = left index).")
    if profile:
        print("Keys you answered for are from the interview; the rest are the touch-typing default.")
    print()
    print(render.layout_text(board, baseline, robot))
    print()
    for side in "LR":
        h = robot.hands[side]
        lengths = ", ".join(f"{FINGER_NAMES[f]} {h.length[f]:.1f}" for f in sorted(h.length))
        print(f"{'Left' if side == 'L' else 'Right'} hand: span {h.span} u; knuckle to tip (u): {lengths}")
    w = robot.hands["L"].weights
    print(f"Effort weights: wrist {w['wrist']}, knuckle {w['mcp']}, midjoint {w['pip']}")


def cmd_type(args):
    board, _, _, baseline, profile, robot = load(args)
    note_profile(args, profile)
    layout = boardmod.layout_of(boardmod.load_keymap(args.layout, board)) if args.layout else baseline
    total_e = total_t = 0.0
    print(f"{'char':<5}{'key':<7}{'finger':<8}{'tip u':>7}{'wrist u':>9}{'effort':>8}")
    table = metrics.typer(robot, layout)
    for word in args.text.split():
        chars = [c for c in word if table(c) is not None]
        skipped = set(word) - set(chars)
        if skipped:
            print(f"  (can't type {''.join(sorted(skipped))!r} on this layout: skipped)")
        keys, labels = [], []
        for c in chars:
            k = table(c)[0]
            keys += k
            labels += [f"{c}+" if i < len(k) - 1 else c for i in range(len(k))]
        for s in robot.strokes(keys, labels):
            name = s.char if s.char is not None else "rest"
            print(f"{name:<5}{s.key:<7}{s.finger:<8}{s.tip_travel:>7.2f}{s.wrist_shift:>9.2f}{s.effort:>8.2f}")
            total_e += s.effort
            total_t += s.tip_travel
    print(f"\nTotal: tip travel {total_t:.2f} u, effort {total_e:.2f}")


def table(rows, base):
    head = f"{'layout':<26}{'effort/char':>12}{'travel u/char':>15}{'one-hand %':>12}{'moved %':>9}{'finger chg %':>14}"
    out = [head, "-" * len(head)]
    for name, r in rows:
        out.append(f"{name:<26}{r.effort:>12.3f}{r.travel:>15.3f}{r.one_hand:>12.1f}{r.moved:>9.1f}{r.finger_changed:>14.1f}")
    return "\n".join(out)


def verdict(r, base, one_hand):
    def pct(a, b):
        return 100 * (a - b) / b if b else 0.0
    parts = [f"effort {pct(r.effort, base.effort):+.1f}% ({'easier' if r.effort < base.effort else 'not easier'})",
             f"travel {pct(r.travel, base.travel):+.1f}%"]
    d = r.one_hand - base.one_hand
    if one_hand == "ignore":
        parts.append(f"one-hand words {d:+.1f} pts")
    else:
        good = d > 0 if one_hand == "more" else d < 0
        parts.append(f"one-hand words {d:+.1f} pts ({'better' if good else 'not better'} for '{one_hand}')")
    parts.append(f"{r.moved:.1f}% of typing moved, {r.finger_changed:.1f}% to another finger")
    return "; ".join(parts)


def cmd_evaluate(args):
    board, _, _, baseline, profile, robot = load(args)
    note_profile(args, profile)
    words, letters = corpus.load_words(args.words), corpus.load_letters(args.letters)
    base = metrics.evaluate(robot, baseline, words, letters, baseline)
    rows = [("baseline", base)]
    for path in args.layouts:
        lay = boardmod.layout_of(boardmod.load_keymap(path, board))
        rows.append((os.path.basename(path), metrics.evaluate(robot, lay, words, letters, baseline)))
    print(table(rows, base))
    for name, r in rows[1:]:
        print(f"\n{name}: {verdict(r, base, args.one_hand)}")


def cmd_suggest(args):
    board, _, keymap_path, baseline, profile, robot = load(args)
    note_profile(args, profile)
    words, letters = corpus.load_words(args.words), corpus.load_letters(args.letters)
    names = args.constraint or list(optimize.PRESETS)
    one_hand_weight = {"ignore": 0.0, "more": -args.one_hand_weight, "fewer": args.one_hand_weight}[args.one_hand]
    base = metrics.evaluate(robot, baseline, words, letters, baseline)
    rows = [("baseline (QWERTY)", base)]
    found = []
    for name in names:
        cons = optimize.PRESETS[name]
        if args.fix:
            cons = optimize.Constraints(cons.name + "+fix", cons.no_interrow, cons.same_hand,
                                        cons.fixed | frozenset(args.fix.lower()), cons.max_moved)
        lay = optimize.suggest(robot, baseline, words, letters, cons, change_weight=args.change_weight,
                               one_hand_weight=one_hand_weight)
        r = metrics.evaluate(robot, lay, words, letters, baseline)
        rows.append((cons.name, r))
        found.append((cons.name, lay, r))
    print(table(rows, base))
    for name, lay, r in found:
        moved = sorted(c for c in lay if lay[c] != baseline[c])
        print(f"\n== {name} ==")
        if not moved:
            print("No swap made it easier for this robot: QWERTY stays.")
            continue
        rev = {kid: c for c, kid in baseline.items()}
        print("Moves: " + ", ".join(f"{c}→{rev[lay[c]]}'s key" for c in moved))
        print(render.layout_text(board, lay))
        print(verdict(r, base, args.one_hand))
        if args.export:
            os.makedirs(args.export, exist_ok=True)
            path = os.path.join(args.export, f"{name}.layout.json")
            boardmod.save_keymap(keymap_path, path, board, lay)
            print(f"Saved {path} (VIA: Load saved layout)")


def main(argv=None):
    p = argparse.ArgumentParser(prog="typing-robot", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--board", default=DEFAULT_BOARD, help="a folder with a VIA definition.json and layout.json (default: GUTS WECAT4)")
    p.add_argument("--keymap", help="the baseline VIA saved layout (default: the board's layout.json)")
    p.add_argument("--profile", default=DEFAULT_PROFILE, help="the interview's answers (default: profiles/profile.json)")
    p.add_argument("--words", default=corpus.WORDS, help="ranked word list, one per line, or word<TAB>count")
    p.add_argument("--letters", default=corpus.LETTERS, help="letter<TAB>percent")
    p.add_argument("--wrist", type=float, help=f"effort weight of the wrist (default {DEFAULT_WEIGHTS['wrist']})")
    p.add_argument("--mcp", type=float, help=f"effort weight of the knuckle (default {DEFAULT_WEIGHTS['mcp']})")
    p.add_argument("--pip", type=float, help=f"effort weight of the finger midjoint (default {DEFAULT_WEIGHTS['pip']})")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("interview", help="the setup questions")
    s.add_argument("--rounds", default="10", help="how many letters to ask about, or 'all' (default 10)")
    s.set_defaults(func=cmd_interview)

    s = sub.add_parser("show", help="the robot's fingers and hands")
    s.set_defaults(func=cmd_show)

    s = sub.add_parser("type", help="type text on the virtual board")
    s.add_argument("text")
    s.add_argument("--layout", help="a VIA saved layout to type on (default: the baseline)")
    s.set_defaults(func=cmd_type)

    one_hand = dict(choices=("ignore", "more", "fewer"), default="ignore",
                    help="whether more one-hand words is better (default: ignore, report only)")
    s = sub.add_parser("evaluate", help="score VIA saved layouts against the baseline")
    s.add_argument("layouts", nargs="*")
    s.add_argument("--one-hand", **one_hand)
    s.set_defaults(func=cmd_evaluate)

    s = sub.add_parser("suggest", help="search for easier layouts and test them")
    s.add_argument("--constraint", action="append", choices=list(optimize.PRESETS),
                   help="a preset to run (repeatable; default: all)")
    s.add_argument("--fix", default="", help="letters that must not move, e.g. zxcv")
    s.add_argument("--change-weight", type=float, default=0.25,
                   help="how much moving every letter costs, as a fraction of the baseline's effort (default 0.25)")
    s.add_argument("--one-hand", **one_hand)
    s.add_argument("--one-hand-weight", type=float, default=0.25)
    s.add_argument("--export", help="a folder to write each suggestion to, as a VIA saved layout")
    s.set_defaults(func=cmd_suggest)

    args = p.parse_args(argv)
    if args.cmd == "interview" and args.rounds != "all":
        args.rounds = int(args.rounds)
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
