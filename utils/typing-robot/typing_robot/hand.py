"""A deterministic model of one hand over the board, seen from above, in key units (u).

Each finger is a chain: wrist → knuckle (MCP) → finger midjoint (PIP) → fingertip.

- **Wrist.** Every knuckle is fixed relative to the wrist, so moving the wrist carries the whole
  hand. It moves only when a finger can't reach a key from where the hand is.
- **Knuckle (MCP).** It turns the finger: sideways (abduction, limited to ±SPREAD) and, with the
  midjoint, sets how far forward the tip lands.
- **Midjoint (PIP).** It bends the finger (0 = straight, PIP_MAX = fully curled), which shortens
  the finger's reach as seen from above. The two segments, knuckle → midjoint and midjoint → tip, are
  each half the finger's length.

The fingers' sizes scale with the hand's **span**: the distance from the tip of finger one (thumb) to
the tip of finger five (pinky) with the hand spread flat on the board, which the interview asks for.

Effort is root-weighted: the same distance costs more the closer to the root a joint is.

    effort = WRIST * wrist distance + MCP * (knuckle turn × segment length) + PIP * (midjoint bend × segment length)

This is a geometric sketch, not a biomechanical model: the finger proportions below are rough
adult averages, and curling is flattened into the board's plane.
"""
import math
from dataclasses import dataclass

FINGER_NAMES = {1: "thumb", 2: "index", 3: "middle", 4: "ring", 5: "pinky"}

# Knuckle (MCP) to fingertip, as a fraction of the span. For a 10.5 u (200 mm) span: index 84 mm,
# middle 94 mm, ring 88 mm, pinky 70 mm, thumb 60 mm.
LENGTH = {1: 0.30, 2: 0.42, 3: 0.47, 4: 0.44, 5: 0.35}
REST = 0.70                      # resting reach (knuckle to tip, seen from above), as a fraction of length
SPREAD = {1: math.radians(45), 2: math.radians(30), 3: math.radians(25), 4: math.radians(25), 5: math.radians(30)}
PIP_MAX = math.radians(150)      # the most the midjoint bends
THUMB_ANGLE = math.radians(30)   # the thumb points this far toward the other hand
DEFAULT_SPAN = 10.5              # u; about 200 mm
DEFAULT_WEIGHTS = {"wrist": 3.0, "mcp": 2.0, "pip": 1.0}


@dataclass(frozen=True)
class Pose:
    shift: tuple    # how far the wrist moved from rest, (dx, dy)
    mcp: float      # knuckle angle, radians from the finger's straight-ahead direction
    pip: float      # midjoint bend, radians (0 = straight)
    tip: tuple      # where the fingertip is, (x, y)


def _clamp(v, lo, hi):
    return lo if v < lo else hi if v > hi else v


def _wrap(a):
    return (a + math.pi) % (2 * math.pi) - math.pi


class Hand:
    def __init__(self, side, span, home_tips, weights=None):
        """side: "L" or "R"; span: thumb-to-pinky span in u; home_tips: {finger 1–5: (x, y)}, where each
        fingertip rests."""
        self.side = side
        self.span = span
        self.weights = dict(DEFAULT_WEIGHTS, **(weights or {}))
        self.home_tips = dict(home_tips)
        self.length, self.forward, self.knuckle = {}, {}, {}
        toward_other = 1 if side == "L" else -1
        for f, (tx, ty) in self.home_tips.items():
            length = LENGTH[f] * span
            if f == 1:
                d = (toward_other * math.sin(THUMB_ANGLE), -math.cos(THUMB_ANGLE))
            else:
                d = (0.0, -1.0)
            self.length[f] = length
            self.forward[f] = math.atan2(d[1], d[0])
            self.knuckle[f] = (tx - d[0] * REST * length, ty - d[1] * REST * length)
        self.rest = {f: self.pose(f, self.home_tips[f]) for f in self.home_tips}

    def pose(self, f, target):
        """The pose that puts finger f's tip on target, moving the wrist as little as needed."""
        kx, ky = self.knuckle[f]
        seg = self.length[f] / 2
        vx, vy = target[0] - kx, target[1] - ky
        r = math.hypot(vx, vy)
        turn = _clamp(_wrap(math.atan2(vy, vx) - self.forward[f]), -SPREAD[f], SPREAD[f])
        r_min, r_max = 2 * seg * math.cos(PIP_MAX / 2), 2 * seg
        rc = _clamp(r, r_min, r_max)
        reach_dir = self.forward[f] + turn
        px, py = kx + rc * math.cos(reach_dir), ky + rc * math.sin(reach_dir)
        shift = (target[0] - px, target[1] - py)
        if abs(shift[0]) < 1e-9 and abs(shift[1]) < 1e-9:
            shift = (0.0, 0.0)
        pip = math.acos(_clamp((rc * rc - 2 * seg * seg) / (2 * seg * seg), -1.0, 1.0))
        mcp = turn - math.atan2(seg * math.sin(pip), seg + seg * math.cos(pip))
        return Pose(shift, mcp, pip, tuple(target))

    def effort(self, f, a, b, wrist_from, wrist_to):
        """Effort of moving finger f from pose a to pose b, with the wrist going from one shift to another."""
        seg = self.length[f] / 2
        w = self.weights
        return (w["wrist"] * math.dist(wrist_from, wrist_to)
                + w["mcp"] * seg * abs(b.mcp - a.mcp)
                + w["pip"] * seg * abs(b.pip - a.pip))
