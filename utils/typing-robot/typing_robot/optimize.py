"""Suggesting layouts: a deterministic search over letter swaps, under constraints.

From the baseline, try every allowed swap of two movable characters, take the one that lowers the
objective most, and repeat until no swap helps. No randomness: the same robot and constraints always
give the same layout. Like any greedy search, it finds a good layout, not necessarily the best one.

    objective = effort / baseline effort + CHANGE * moved fraction ± ONE_HAND * one-hand fraction
"""
from dataclasses import dataclass, field
from itertools import combinations

from .metrics import evaluate


@dataclass(frozen=True)
class Constraints:
    name: str = "free"
    no_interrow: bool = False     # letters stay on their physical row
    same_hand: bool = False       # letters stay on the hand that typed them
    fixed: frozenset = field(default_factory=frozenset)   # characters that don't move
    max_moved: int = None         # at most this many characters on another key

    def allows(self, layout, baseline, robot):
        board = robot.board
        moved = 0
        for c, kid in layout.items():
            base = baseline[c]
            if kid == base:
                continue
            moved += 1
            if c in self.fixed:
                return False
            if self.no_interrow and board.by_id[kid].line != board.by_id[base].line:
                return False
            if self.same_hand and robot.side_of(kid) != robot.side_of(base):
                return False
        return self.max_moved is None or moved <= self.max_moved


PRESETS = {
    "no-interrow": Constraints("no-interrow", no_interrow=True),
    "no-interrow-keep-zxcv": Constraints("no-interrow-keep-zxcv", no_interrow=True, fixed=frozenset("zxcv")),
    "same-hand": Constraints("same-hand", same_hand=True),
    "max-4-moved": Constraints("max-4-moved", max_moved=4),
    "free": Constraints("free"),
}


def objective(result, base, change_weight, one_hand_weight):
    return result.effort / base.effort + change_weight * result.moved / 100 + one_hand_weight * result.one_hand / 100


def suggest(robot, baseline, words, letters, constraints, movable="abcdefghijklmnopqrstuvwxyz",
            change_weight=0.25, one_hand_weight=0.0, max_rounds=200):
    """The best layout found under the constraints. one_hand_weight < 0 favours one-hand words,
    > 0 avoids them, 0 ignores them."""
    base = evaluate(robot, baseline, words, letters, baseline)
    chars = [c for c in movable if c in baseline]
    current = dict(baseline)
    score = objective(base, base, change_weight, one_hand_weight)
    for _ in range(max_rounds):
        best = None
        for a, b in combinations(chars, 2):
            cand = dict(current)
            cand[a], cand[b] = current[b], current[a]
            if not constraints.allows(cand, baseline, robot):
                continue
            s = objective(evaluate(robot, cand, words, letters, baseline), base, change_weight, one_hand_weight)
            if s < score - 1e-9 and (best is None or s < best[0]):
                best = (s, cand)
        if best is None:
            break
        score, current = best
    return current
