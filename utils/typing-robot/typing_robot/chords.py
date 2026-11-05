"""Characters typed with chords: Shift for capitals and shifted symbols, an Fn key (a momentary layer,
``MO(n)`` on the base layer) for what's on the Fn layers, or both.

The host is macOS with the keyboard stored as JIS, so a keycode types JIS's character for it: Shift + 7
is ', and the keycode QMK calls ``KC_QUOT`` types :. Each character gets every chord that types it
(either Shift, any Fn key that reaches the layer), and the robot uses the one that costs it least to
type on its own. A held modifier is a keystroke whose finger stays on its key until that finger is
needed again: the robot's ordinary stroke model, with the modifier pressed first.
"""
from .keycodes import CHAR_OF

# keycode: (plain, with Shift) on macOS, keyboard stored as JIS. None: types nothing useful here.
JIS = {
    "KC_1": ("1", "!"), "KC_2": ("2", '"'), "KC_3": ("3", "#"), "KC_4": ("4", "$"), "KC_5": ("5", "%"),
    "KC_6": ("6", "&"), "KC_7": ("7", "'"), "KC_8": ("8", "("), "KC_9": ("9", ")"), "KC_0": ("0", None),
    "KC_MINS": ("-", "="), "KC_EQL": ("^", "~"), "KC_LBRC": ("@", "`"), "KC_RBRC": ("[", "{"),
    "KC_BSLS": ("]", "}"), "KC_NUHS": ("]", "}"), "KC_SCLN": (";", "+"), "KC_QUOT": (":", "*"),
    "KC_COMM": (",", "<"), "KC_DOT": (".", ">"), "KC_SLSH": ("/", "?"), "KC_INT1": ("\\", "_"),
    "KC_INT3": ("¥", "|"), "KC_SPC": (" ", None),
}
SHIFTS = ("KC_LSFT", "KC_RSFT")


def _mo_layer(code):
    if code.startswith("MO(") and code.endswith(")"):
        return int(code[3:-1])
    return None


class Chords:
    """{character: keys to press, modifiers first} for one layout, on a robot that knows the board's
    Fn layers (``robot.layers``: {layer number: {key id: keycode}}) and base keymap (``robot.base_keymap``)."""

    def __init__(self, robot):
        self.robot = robot
        base = robot.base_keymap
        self.shifts = [kid for kid, kc in base.items() if kc in SHIFTS]
        self.fn = {}   # layer: [key ids of the MO(layer) keys]
        for kid, kc in base.items():
            n = _mo_layer(kc)
            if n is not None:
                self.fn.setdefault(n, []).append(kid)
        # Characters on the Fn layers don't depend on the letter layout: work them out once.
        self.fixed = {}
        for n, keys in sorted(robot.layers.items()):
            for kid, kc in keys.items():
                # JIS first: CHAR_OF reads KC_QUOT as ', which is US; on JIS it types :.
                if kc in JIS:
                    plain, shifted = JIS[kc]
                elif kc in CHAR_OF and CHAR_OF[kc].isalpha():
                    plain, shifted = CHAR_OF[kc], CHAR_OF[kc].upper()
                else:
                    continue
                for ch, shift in ((plain, False), (shifted, True)):
                    if ch is None or ch == " ":
                        continue
                    for fk in self.fn.get(n, []):
                        for seq in self._with_shift((fk, kid), shift):
                            self._offer(self.fixed, ch, seq)

    def _with_shift(self, keys, shift):
        if not shift:
            return [keys]
        return [(keys[0], s) + keys[1:] if len(keys) > 1 else (s,) + keys for s in self.shifts] if self.shifts else []

    def _offer(self, table, ch, seq):
        cost = self.robot.word_cost(seq)[0]
        if ch not in table or cost < table[ch][0]:
            table[ch] = (cost, seq)

    def table(self, layout):
        """{character: key ids} for a letter layout ({lowercase char: key id} on the base layer)."""
        out = {}
        for ch, kid in layout.items():
            if ch == " ":
                continue
            self._offer(out, ch, (kid,))
            if ch.isalpha():
                for seq in self._with_shift((kid,), True):
                    self._offer(out, ch.upper(), seq)
            else:
                code = next((kc for kc, c in CHAR_OF.items() if c == ch), None)
                shifted = JIS.get(code, (None, None))[1]
                if shifted:
                    for seq in self._with_shift((kid,), True):
                        self._offer(out, shifted, seq)
        for ch, v in self.fixed.items():
            if ch not in out or v[0] < out[ch][0]:
                out[ch] = v
        return {ch: seq for ch, (_, seq) in out.items()}
