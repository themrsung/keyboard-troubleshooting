"""The QMK keycodes the tool reads as characters: English only for now (a–z, a few punctuation keys,
Space). Everything else (modifiers, layer keys) is a key the robot never types with."""

CHAR_OF = {f"KC_{c.upper()}": c for c in "abcdefghijklmnopqrstuvwxyz"}
CHAR_OF.update({"KC_COMM": ",", "KC_DOT": ".", "KC_SLSH": "/", "KC_SCLN": ";", "KC_QUOT": "'", "KC_SPC": " "})

KC_OF = {ch: kc for kc, ch in CHAR_OF.items()}

# Names a typist may use for a key during the interview, beyond its character.
KEY_ALIASES = {
    "enter": "KC_ENT", "return": "KC_ENT", "tab": "KC_TAB", "backspace": "KC_BSPC", "bs": "KC_BSPC",
    "space": "KC_SPC", "control": "KC_LCTL", "ctrl": "KC_LCTL", "shift": "KC_LSFT", "lshift": "KC_LSFT",
    "rshift": "KC_RSFT", "comma": "KC_COMM", "period": "KC_DOT", "dot": "KC_DOT", "slash": "KC_SLSH",
    ";": "KC_SCLN", "semicolon": "KC_SCLN", "'": "KC_QUOT", "quote": "KC_QUOT",
}
