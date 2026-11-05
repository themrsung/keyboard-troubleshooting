"""The virtual board, as text: each key drawn to scale (CELL characters per u)."""

CELL = 6


def board_text(board, label):
    """label(key) → a short string, or "" for a blank key."""
    lines = []
    for row in board.lines():
        s = ""
        for k in row:
            start, width = round(k.x * CELL), max(3, round(k.w * CELL))
            s = s.ljust(start)
            text = label(k)[: width - 2]
            s += "[" + text.center(width - 2) + "]"
        lines.append(s.rstrip())
    return "\n".join(lines)


def layout_text(board, layout, robot=None):
    """Each key's character, and with a robot, the finger that presses it (e.g. "b L2")."""
    rev = {kid: c for c, kid in layout.items() if c != " "}
    def label(k):
        c = rev.get(k.id, "")
        if robot is None or not c:
            return c
        return f"{c} {robot.fingers[k.id]}"
    return board_text(board, label)
