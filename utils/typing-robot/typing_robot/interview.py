"""The setup interview: a few questions, answered at the terminal, saved as a profile (JSON).

1. Each hand's span: thumb tip to pinky tip, spread flat on the board.
2. The home keys.
3. Which thumb presses Space.
4. Rounds of "Type the word BIRD. Which finger did you use to type B?", for the letters touch
   typists most often type differently first.

Nothing is guessed from the answers: each answer is stored as given, and the robot uses the most
common answer per letter (robot.py). Letters that weren't asked keep the touch-typing default.
"""
import re

from .hand import FINGER_NAMES
from .keycodes import KEY_ALIASES
from .robot import default_home

MM_PER_U = 19.05

# Letters touch typists most often type with a different finger than the chart says, first.
PRIORITY = "btgyhnvcmzxqpurewiosadfjkl"

NAMES = {v: k for k, v in FINGER_NAMES.items()}
HOME_ORDER = ("L5", "L4", "L3", "L2", "R2", "R3", "R4", "R5")


def parse_span(text):
    """A span in u: "9.5", "9.5u", "9 keys", "180mm", "18cm", "18 cm"."""
    m = re.fullmatch(r"\s*([0-9]+(?:\.[0-9]+)?)\s*(u|keys?|mm|cm)?\s*", text.lower())
    if not m:
        raise ValueError("a number, in u (keys), mm or cm")
    v, unit = float(m.group(1)), m.group(2) or "u"
    u = v / MM_PER_U if unit == "mm" else v * 10 / MM_PER_U if unit == "cm" else v
    if not 3 <= u <= 20:
        raise ValueError(f"{u:.1f} u is out of range (3–20 u)")
    return round(u, 2)


def parse_finger(text):
    """"L2", "r5", "left index", "right pinky", "L thumb" → "L2"."""
    t = text.strip().lower().replace("-", " ")
    m = re.fullmatch(r"(l|r|left|right)\s*([1-5]|thumb|index|middle|ring|pinky)", t)
    if not m:
        raise ValueError("a side and a finger, like L2, R5 or 'left index' (finger one is the thumb)")
    side = m.group(1)[0].upper()
    f = m.group(2)
    return f"{side}{f if f.isdigit() else NAMES[f]}"


def _key_from_answer(text, board, layout, keymap):
    t = text.strip().lower()
    if t in layout and t != " ":
        return layout[t]
    code = KEY_ALIASES.get(t) or (text.strip().upper() if text.strip().upper().startswith("KC_") else None)
    for kid, kc in keymap.items():
        if kc == code:
            return kid
    raise ValueError("a letter, or a key name like Enter")


def _ask(ask, say, prompt, parse, default=None):
    while True:
        text = ask(prompt + (f" [{default}] " if default is not None else " ")).strip()
        if not text and default is not None:
            text = str(default)
        try:
            return parse(text)
        except ValueError as e:
            say(f"  Didn't get that: {e}.")


# For letters the word list may have no word of three or more letters for.
FALLBACK = {"z": "zero", "q": "quick", "j": "just", "x": "next", "k": "kind"}


def pick_word(char, words, used):
    for w, _ in words:
        if char in w and len(w) >= 3 and w not in used:
            return w
    return FALLBACK.get(char, char)


def run(board, keymap, layout, words, ask=input, say=print, rounds=10):
    labels = {kid: kc for kid, kc in keymap.items()}
    say(f"Setting up the typing robot for {board.name}. Finger one is the thumb, five the pinky; answer")
    say("with a side and a number (L2 = left index) or in words (right pinky).\n")

    say("1. Hand size. Spread each hand flat on the board and measure from the tip of finger one")
    say(f"   (thumb) to the tip of finger five (pinky), in keys (1 u = {MM_PER_U} mm), mm or cm.")
    spans = {}
    for side, name in (("L", "left"), ("R", "right")):
        spans[side] = _ask(ask, say, f"   Your {name} hand's span?", parse_span, 10.5)

    home = default_home(board, layout)
    rev = {v: k for k, v in layout.items() if k != " "}

    def legend(kid):
        names = {"KC_ENT": "Enter", "KC_BSPC": "Backspace", "KC_LCTL": "Control", "KC_TAB": "Tab"}
        return rev.get(kid, "").upper() or names.get(labels[kid], labels[kid].removeprefix("KC_").title())
    say("\n2. Home keys. The robot's fingers rest on: "
        + " ".join(legend(home[c]) for c in HOME_ORDER[:4]) + " | " + " ".join(legend(home[c]) for c in HOME_ORDER[4:]))
    if _ask(ask, say, "   Is that where yours rest? (y/n)", lambda t: _yes_no(t), "y") is False:
        for code in HOME_ORDER:
            side, f = code[0], int(code[1])
            name = f"{'left' if side == 'L' else 'right'} {FINGER_NAMES[f]}"
            home[code] = _ask(ask, say, f"   Which key does your {name} rest on?",
                              lambda t: _key_from_answer(t, board, layout, keymap), legend(home[code]))

    say("\n3. Space.")
    space_thumb = _ask(ask, say, "   Which thumb do you press Space with? (L/R)",
                       lambda t: _side(t), "R")

    order = [c for c in PRIORITY if c in layout]
    n = len(order) if rounds in (None, "all") else min(int(rounds), len(order))
    say(f"\n4. {n} rounds. Type each word on your keyboard as you normally would, then answer.")
    answers, used = [], set()
    for i, c in enumerate(order[:n], 1):
        w = pick_word(c, words, used)
        used.add(w)
        say(f"\n   Round {i}/{n}: type the word {w.upper()}.")
        finger = _ask(ask, say, f"   Which finger did you use to type {c.upper()}?", parse_finger)
        answers.append({"word": w, "char": c, "finger": finger})

    say("\nDone.")
    return {"version": 1, "board": board.name, "spans": spans, "home": home,
            "space_thumb": space_thumb, "answers": answers}


def _yes_no(t):
    t = t.strip().lower()
    if t in ("y", "yes"):
        return True
    if t in ("n", "no"):
        return False
    raise ValueError("y or n")


def _side(t):
    t = t.strip().lower()
    if t in ("l", "left"):
        return "L"
    if t in ("r", "right"):
        return "R"
    raise ValueError("L or R")
