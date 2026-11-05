"""Scoring a layout by having the robot type the word list on it.

- **effort** (per character, lower is easier): the root-weighted effort of hand.py, wrist > knuckle >
  midjoint, including each word's return to rest.
- **travel** (u per character): plain fingertip travel, for reference.
- **one-hand words** (%): the share of words, weighted by frequency, typed entirely by one hand.
  Words of one letter are left out. Whether more is better depends on the typist: it suits a hand
  that's busy (a phone, a mouse), and it's worse for speed, which comes from alternating hands.
- **moved** (%): how much changed from the baseline, by letter frequency: the share of typed letters
  that are on another key. **finger changed** (%) counts only those that also moved to another finger,
  the part that has to be relearned.
"""
from dataclasses import dataclass

from .chords import Chords


def typer(robot, layout):
    """A function from a word to the keys that type it (modifiers included), or None if a character
    can't be typed. With the board's Fn layers loaded (robot.layers), characters are typed with chords
    (chords.py); without them, only the base layer's characters, one key each."""
    if getattr(robot, "layers", None) is None:
        def keys(word):
            try:
                return [layout[c] for c in word], [layout[c] for c in word]
            except KeyError:
                return None
        return keys
    if not hasattr(robot, "_chords"):
        robot._chords = Chords(robot)
    table = robot._chords.table(layout)

    def keys(word):
        seq, last = [], []
        for c in word:
            k = table.get(c)
            if k is None:
                return None
            seq.extend(k)
            last.append(k[-1])
        return seq, last
    return keys


@dataclass
class Result:
    effort: float
    travel: float
    one_hand: float
    moved: float
    finger_changed: float


def evaluate(robot, layout, words, letters, baseline):
    eff = trav = chars = 0.0
    one = multi = 0.0
    to_keys = typer(robot, layout)
    for word, weight in words:
        typed = to_keys(word)
        if typed is None:
            continue
        keys, mains = typed
        e, t = robot.word_cost(keys)
        eff += weight * e
        trav += weight * t
        chars += weight * len(word)
        if len(word) > 1:
            multi += weight
            if len({robot.side_of(k) for k in mains}) == 1:
                one += weight
    total = moved = fchanged = 0.0
    for c, pct in letters.items():
        if c not in layout or c not in baseline:
            continue
        total += pct
        if layout[c] != baseline[c]:
            moved += pct
            if robot.fingers[layout[c]] != robot.fingers[baseline[c]]:
                fchanged += pct
    return Result(eff / chars if chars else 0.0, trav / chars if chars else 0.0,
                  100 * one / multi if multi else 0.0,
                  100 * moved / total if total else 0.0, 100 * fchanged / total if total else 0.0)
