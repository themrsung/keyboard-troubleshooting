"""Draws the layouts in layouts/: one layout.html per layout, with every key showing three legends.

    python3 -I layouts/render/build.py            # writes layouts/<name>/layout.html
    sh layouts/render/render.sh                   # and layout-light.png / layout-dark.png (Chrome)

Each key shows its US QWERTY cap (top left), what it types in JIS Korean's Mode A (bottom left,
Shift above) and in Japanese Kana (bottom right, Shift above). Both come from the JIS key the key
sends, so a remapped key shows what it types, not what's printed on it.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
LAYOUTS = os.path.dirname(HERE)

# What each JIS key position types. Mode A is JIS Korean's original layout (spec §3); Kana is the
# JIS kana layout. (base, shift); None where the key has nothing of its own.
MODE_A = {
    "Digit1": ("ㅃ", "1"), "Digit2": ("ㅉ", "2"), "Digit3": ("ㄸ", "3"), "Digit4": ("ㄲ", "4"),
    "Digit5": ("ㅆ", "5"), "Digit6": ("ㅟ", "6"), "Digit7": ("ㅝ", "7"), "Digit8": ("ㅚ", "8"),
    "Digit9": ("ㅢ", "9"), "Digit0": ("ㅘ", "0"), "Minus": ("!", "?"), "Equal": ("(", ")"),
    "IntlYen": ("—", "^"),
    "KeyQ": ("ㅂ", "ㅃ"), "KeyW": ("ㅈ", "ㅉ"), "KeyE": ("ㄷ", "ㄸ"), "KeyR": ("ㄱ", "ㄲ"),
    "KeyT": ("ㅅ", "ㅆ"), "KeyY": ("ㅛ", None), "KeyU": ("ㅕ", None), "KeyI": ("ㅑ", None),
    "KeyO": ("ㅐ", "ㅒ"), "KeyP": ("ㅔ", "ㅖ"), "BracketLeft": ("'", '"'), "BracketRight": ("[", "「"),
    "KeyA": ("ㅁ", None), "KeyS": ("ㄴ", None), "KeyD": ("ㅇ", None), "KeyF": ("ㄹ", None),
    "KeyG": ("ㅎ", None), "KeyH": ("ㅗ", None), "KeyJ": ("ㅓ", None), "KeyK": ("ㅏ", None),
    "KeyL": ("ㅣ", None), "Semicolon": ("~", "-"), "Quote": (":", ";"), "Backslash": ("]", "」"),
    "KeyZ": ("ㅋ", "반각"), "KeyX": ("ㅌ", None), "KeyC": ("ㅊ", None), "KeyV": ("ㅍ", None),
    "KeyB": ("ㅠ", None), "KeyN": ("ㅜ", None), "KeyM": ("ㅡ", None), "Comma": (",", None),
    "Period": (".", None), "Slash": ("·", None), "IntlRo": ("\\", "_"),
}
KANA = {
    "Digit1": ("ぬ", None), "Digit2": ("ふ", None), "Digit3": ("あ", "ぁ"), "Digit4": ("う", "ぅ"),
    "Digit5": ("え", "ぇ"), "Digit6": ("お", "ぉ"), "Digit7": ("や", "ゃ"), "Digit8": ("ゆ", "ゅ"),
    "Digit9": ("よ", "ょ"), "Digit0": ("わ", "を"), "Minus": ("ほ", None), "Equal": ("へ", None),
    "IntlYen": ("ー", None),
    "KeyQ": ("た", None), "KeyW": ("て", None), "KeyE": ("い", "ぃ"), "KeyR": ("す", None),
    "KeyT": ("か", None), "KeyY": ("ん", None), "KeyU": ("な", None), "KeyI": ("に", None),
    "KeyO": ("ら", None), "KeyP": ("せ", None), "BracketLeft": ("゛", None), "BracketRight": ("゜", "「"),
    "KeyA": ("ち", None), "KeyS": ("と", None), "KeyD": ("し", None), "KeyF": ("は", None),
    "KeyG": ("き", None), "KeyH": ("く", None), "KeyJ": ("ま", None), "KeyK": ("の", None),
    "KeyL": ("り", None), "Semicolon": ("れ", None), "Quote": ("け", None), "Backslash": ("む", "」"),
    "KeyZ": ("つ", "っ"), "KeyX": ("さ", None), "KeyC": ("そ", None), "KeyV": ("ひ", None),
    "KeyB": ("こ", None), "KeyN": ("み", None), "KeyM": ("も", None), "Comma": ("ね", "、"),
    "Period": ("る", "。"), "Slash": ("め", "・"), "IntlRo": ("ろ", None),
}
# JIS Korean's F6–F10 (spec §6).
F_KEYS = {6: "한글", 7: "한자", 8: "두벌식", 9: "전각", 10: "반각"}

LETTERS = "QWERTYUIOPASDFGHJKLZXCVBNM"
US = {f"Key{c}": c for c in LETTERS}
US.update({f"Digit{i}": str(i) for i in range(10)})
US.update({"Backquote": "`", "Minus": "-", "Equal": "=", "BracketLeft": "[", "BracketRight": "]",
           "Backslash": "\\", "Semicolon": ";", "Quote": "'", "Comma": ",", "Period": ".", "Slash": "/"})


# --- Geometry: rows of (key id, US cap, width); a number alone is a gap. ---

def place(rows, y0=0.0, x0=0.0, row_height=1.0):
    keys = []
    for r, row in enumerate(rows):
        x = x0
        y = y0 + r * row_height
        for item in row:
            if isinstance(item, (int, float)):
                x += item
                continue
            key_id, cap, w = item[0], item[1], item[2] if len(item) > 2 else 1
            h = item[3] if len(item) > 3 else 1
            keys.append({"id": key_id, "us": cap, "x": x, "y": y, "w": w, "h": h})
            x += w
    return keys


def main_block(y, bottom_row):
    return place([
        [("Backquote", "`")] + [(f"Digit{i}", str(i)) for i in "1234567890"] + [("Minus", "-"), ("Equal", "="), ("Backspace", "Backspace", 2)],
        [("Tab", "Tab", 1.5)] + [(f"Key{c}", c) for c in "QWERTYUIOP"] + [("BracketLeft", "["), ("BracketRight", "]"), ("Backslash", "\\", 1.5)],
        [("CapsLock", "Caps Lock", 1.75)] + [(f"Key{c}", c) for c in "ASDFGHJKL"] + [("Semicolon", ";"), ("Quote", "'"), ("Enter", "Enter", 2.25)],
        [("ShiftLeft", "Shift", 2.25)] + [(f"Key{c}", c) for c in "ZXCVBNM"] + [("Comma", ","), ("Period", "."), ("Slash", "/"), ("ShiftRight", "Shift", 2.75)],
        bottom_row,
    ], y0=y)


PC_BOTTOM = [("ControlLeft", "Ctrl", 1.25), ("MetaLeft", "Win", 1.25), ("AltLeft", "Alt", 1.25), ("Space", "", 6.25),
             ("AltRight", "Alt", 1.25), ("MetaRight", "Win", 1.25), ("ContextMenu", "Menu", 1.25), ("ControlRight", "Ctrl", 1.25)]
F_ROW = [("Escape", "Esc"), 1] + [(f"F{i}", f"F{i}") for i in range(1, 5)] + [0.5] + \
        [(f"F{i}", f"F{i}") for i in range(5, 9)] + [0.5] + [(f"F{i}", f"F{i}") for i in range(9, 13)]


def tkl():
    keys = place([F_ROW])
    keys += main_block(1.25, PC_BOTTOM)
    keys += place([[("PrintScreen", "PrtSc"), ("ScrollLock", "ScrLk"), ("Pause", "Pause")]], x0=15.25)
    keys += place([[("Insert", "Ins"), ("Home", "Home"), ("PageUp", "PgUp")],
                   [("Delete", "Del"), ("End", "End"), ("PageDown", "PgDn")]], y0=1.25, x0=15.25)
    keys += place([[1, ("ArrowUp", "↑")], [("ArrowLeft", "←"), ("ArrowDown", "↓"), ("ArrowRight", "→")]], y0=4.25, x0=15.25)
    return keys


def full_size():
    keys = tkl()
    keys += place([
        [("NumLock", "Num"), ("NumpadDivide", "/"), ("NumpadMultiply", "*"), ("NumpadSubtract", "-")],
        [("Numpad7", "7"), ("Numpad8", "8"), ("Numpad9", "9"), ("NumpadAdd", "+", 1, 2)],
        [("Numpad4", "4"), ("Numpad5", "5"), ("Numpad6", "6")],
        [("Numpad1", "1"), ("Numpad2", "2"), ("Numpad3", "3"), ("NumpadEnter", "Enter", 1, 2)],
        [("Numpad0", "0", 2), ("NumpadDecimal", ".")],
    ], y0=1.25, x0=18.5)
    return keys


def hhkb():
    return place([
        [("Escape", "Esc")] + [(f"Digit{i}", str(i)) for i in "1234567890"] + [("Minus", "-"), ("Equal", "="), ("Backslash", "\\"), ("Backquote", "`")],
        [("Tab", "Tab", 1.5)] + [(f"Key{c}", c) for c in "QWERTYUIOP"] + [("BracketLeft", "["), ("BracketRight", "]"), ("Backspace", "Delete", 1.5)],
        [("ControlLeft", "Control", 1.75)] + [(f"Key{c}", c) for c in "ASDFGHJKL"] + [("Semicolon", ";"), ("Quote", "'"), ("Enter", "Return", 2.25)],
        [("ShiftLeft", "Shift", 2.25)] + [(f"Key{c}", c) for c in "ZXCVBNM"] + [("Comma", ","), ("Period", "."), ("Slash", "/"), ("ShiftRight", "Shift", 1.75), ("Fn", "Fn")],
        [1.5, ("AltLeft", "◇"), ("MetaLeft", "◆", 1.5), ("Space", "", 6), ("MetaRight", "◆", 1.5), ("AltRight", "◇")],
    ])


def hhkb_studio_jis():
    """The HHKB Studio JIS: caps are JIS (the id is still the key's code), the pointing-stick buttons below Space."""
    keys = place([
        [("Escape", "Esc")] + [(f"Digit{i}", str(i)) for i in "1234567890"] + [("Minus", "-"), ("Equal", "^"), ("IntlYen", "¥"), ("Backspace", "BS")],
        [("Tab", "Tab", 1.5)] + [(f"Key{c}", c) for c in "QWERTYUIOP"] + [("BracketLeft", "@"), ("BracketRight", "[")],
        [("ControlLeft", "Control", 1.75)] + [(f"Key{c}", c) for c in "ASDFGHJKL"] + [("Semicolon", ";"), ("Quote", ":"), ("Backslash", "]")],
        [("ShiftLeft", "Shift", 2)] + [(f"Key{c}", c) for c in "ZXCVBNM"] + [("Comma", ","), ("Period", "."), ("Slash", "/"), ("IntlRo", "\\"), ("ArrowUp", "↑"), ("ShiftRight", "Shift")],
        [("Fn1", "Fn1"), 0.25, ("HankakuZenkaku", "半/全"), ("AltLeft", "Opt"), ("MetaLeft", "⌘"), ("Lang2", "英数"), ("Space", "", 2.5),
         ("Lang1", "かな"), ("MetaRight", "⌘"), ("AltRight", "Opt"), ("Fn1Right", "Fn1"), 0.25, ("ArrowLeft", "←"), ("ArrowDown", "↓"), ("ArrowRight", "→")],
        [4.75, ("LB", "LB", 1.5), ("Fn2", "Fn2"), ("RB", "RB", 1.5)],
    ])
    # JIS's Enter: 1.5 wide on the Tab row, 1.25 on the Control row.
    keys.append({"id": "Enter", "us": "Enter", "x": 13.5, "y": 1, "w": 1.5, "h": 2, "ell": 0.25})
    return keys


def numpad_al21w():
    """The SPM AL21W: a numpad with a row of four keys above it (SPM's VIA definition, split Backspace)."""
    keys = place([[("TopLeft", "Esc"), ("TopSecond", "Calc"), ("TopThird", "BS"), ("TopRight", "Fn")]])
    keys += place([
        [("NumLock", "Num"), ("NumpadDivide", "/"), ("NumpadMultiply", "*"), ("NumpadSubtract", "-")],
        [("Numpad7", "7"), ("Numpad8", "8"), ("Numpad9", "9"), ("NumpadAdd", "+", 1, 2)],
        [("Numpad4", "4"), ("Numpad5", "5"), ("Numpad6", "6")],
        [("Numpad1", "1"), ("Numpad2", "2"), ("Numpad3", "3"), ("NumpadEnter", "Enter", 1, 2)],
        [("Numpad0", "0", 2), ("NumpadDecimal", ".")],
    ], y0=1.25)
    return keys


def macbook():
    keys = place([[("Escape", "esc", 1.5)] + [(f"F{i}", f"F{i}") for i in range(1, 13)] + [("TouchID", "")]])
    keys += place([
        [("Backquote", "`")] + [(f"Digit{i}", str(i)) for i in "1234567890"] + [("Minus", "-"), ("Equal", "="), ("Backspace", "delete", 1.5)],
        [("Tab", "tab", 1.5)] + [(f"Key{c}", c) for c in "QWERTYUIOP"] + [("BracketLeft", "["), ("BracketRight", "]"), ("Backslash", "\\")],
        [("CapsLock", "caps lock", 1.75)] + [(f"Key{c}", c) for c in "ASDFGHJKL"] + [("Semicolon", ";"), ("Quote", "'"), ("Enter", "return", 1.75)],
        [("ShiftLeft", "shift", 2.25)] + [(f"Key{c}", c) for c in "ZXCVBNM"] + [("Comma", ","), ("Period", "."), ("Slash", "/"), ("ShiftRight", "shift", 2.25)],
        [("Fn", "🌐"), ("ControlLeft", "control"), ("AltLeft", "option"), ("MetaLeft", "command", 1.25), ("Space", "", 5),
         ("MetaRight", "command", 1.25), ("AltRight", "option")],
    ], y0=1)
    keys += [
        {"id": "ArrowLeft", "us": "←", "x": 11.5, "y": 5.5, "w": 1, "h": 0.5},
        {"id": "ArrowUp", "us": "↑", "x": 12.5, "y": 5, "w": 1, "h": 0.5},
        {"id": "ArrowDown", "us": "↓", "x": 12.5, "y": 5.5, "w": 1, "h": 0.5},
        {"id": "ArrowRight", "us": "→", "x": 13.5, "y": 5.5, "w": 1, "h": 0.5},
    ]
    return keys


# --- What a key does on a layer. ---
# send(code): types the JIS key `code` (legends from MODE_A / KANA), marked moved if not its own.
# lang(tap, hold): a language key (tap), with what holding does.
# tap(code, hold): types `code` on a tap, and holding is `hold`.
# fn(label, small): a function on a layer (navigation, media, F-keys...).
# mod(label): a modifier or other key, moved if `moved`.

def send(code):
    return {"kind": "send", "code": code}


def lang(tap, hold=""):
    return {"kind": "lang", "tap": tap, "hold": hold}


def tap(code, hold):
    return {"kind": "tap", "code": code, "hold": hold}


def fn(label, small="", moved=False):
    return {"kind": "fn", "label": label, "small": small, "moved": moved}


def mod(label, moved=False):
    return {"kind": "mod", "label": label, "moved": moved}


def fkey(n, moved=False):
    return {"kind": "fkey", "label": f"F{n}", "jk": F_KEYS.get(n, ""), "moved": moved}


def base_layer(keys, overrides):
    """A key's own behaviour, unless overridden: characters send themselves, F-keys are F-keys."""
    layer = {}
    for k in keys:
        if k["id"] in overrides:
            layer[k["id"]] = overrides[k["id"]]
        elif k["id"] in MODE_A or k["id"] == "Backquote":
            layer[k["id"]] = send(k["id"])
        elif k["id"].startswith("F") and k["id"][1:].isdigit():
            layer[k["id"]] = fkey(int(k["id"][1:]))
        else:
            layer[k["id"]] = mod(k["us"])
    return layer


def fn_layer(keys, overrides):
    """Only the overridden keys do anything; the rest are blank."""
    return {k["id"]: overrides.get(k["id"], {"kind": "blank"}) for k in keys}


def open_layer(keys, overrides):
    """Like fn_layer, but the rest are deliberately undefined: passthrough here, free for any implementation."""
    return {k["id"]: overrides.get(k["id"], {"kind": "undef"}) for k in keys}


HHKB_FN = {  # The HHKB US Fn layer, Mac extras version, by key.
    **{f"Digit{d}": fkey(i + 1) for i, d in enumerate("1234567890")}, "Minus": fkey(11), "Equal": fkey(12),
    "Backslash": fn("Ins"), "Backquote": fn("Del"), "Tab": fn("Caps"),
    "KeyI": fn("⌘⇧4", "PrtSc"), "KeyO": fn("ScrLk"), "KeyP": fn("▶︎❚❚", "Pause"),
    "BracketLeft": fn("↑"), "Semicolon": fn("←"), "Quote": fn("→"), "Slash": fn("↓"),
    "KeyK": fn("Home"), "KeyL": fn("PgUp"), "Comma": fn("End"), "Period": fn("PgDn"),
    "KeyH": fn("*"), "KeyJ": fn("/"), "KeyN": fn("+"), "KeyM": fn("−"), "Enter": fn("Enter", "keypad"),
    "KeyA": fn("Vol−"), "KeyS": fn("Vol+"), "KeyD": fn("Mute"), "KeyF": fn("⏏"),
}


STUDIO_LANG = {  # Set on every layer of the golden layout, so they work while Fn1 or Fn2 is held.
    "HankakuZenkaku": lang("カタカナ"), "Lang2": lang("英数"), "Lang1": lang("かな"),
}


def layouts():
    out = {}

    keys = hhkb_studio_jis()
    out["hhkb-jis-golden"] = {
        "title": "HHKB Studio JIS, the golden layout",
        "lede": "The reference every other layout here follows: an HHKB Studio JIS in PFU's keymap tool, one key per language on the bottom row, and the HHKB Fn layer.",
        "cap_legend": "the JIS key cap",
        "keys": keys,
        "layers": [
            ("Standard", base_layer(keys, {
                **STUDIO_LANG, "Fn1": lang("Fn1"), "Fn1Right": lang("Fn1"), "Fn2": lang("Fn2"),
                "LB": mod("Left click"), "RB": mod("Right click"), "Space": mod(""),
            })),
            ("Fn1 (hold either Fn1)", fn_layer(keys, {
                "Escape": fn("Power"), **{f"Digit{d}": fkey(i + 1) for i, d in enumerate("1234567890")},
                "Minus": fkey(11), "Equal": fkey(12), "IntlYen": fn("Ins"), "Backspace": fn("Del"), "Tab": fn("Caps"),
                "KeyI": fn("PrtSc", "→ ⌘⇧4"), "KeyO": fn("ScrLk"), "KeyP": fn("Pause", "→ ▶︎❚❚"),
                "BracketLeft": fn("↑"), "Semicolon": fn("←"), "Quote": fn("→"), "Slash": fn("↓"),
                "KeyK": fn("Home"), "KeyL": fn("PgUp"), "Comma": fn("End"), "Period": fn("PgDn"),
                "KeyH": fn("*"), "KeyJ": fn("/"), "KeyN": fn("+"), "KeyM": fn("−"), "Enter": fn("Enter", "keypad"),
                "KeyA": fn("Vol−"), "KeyS": fn("Vol+"), "KeyD": fn("Mute"), "KeyF": fn("⏏"),
                "ArrowUp": fn("Shift", "right"), "ArrowLeft": fn("Del"), "ArrowDown": fn("⌘", "right"), "ArrowRight": fn("Control", "right"),
                **STUDIO_LANG, "Fn1": lang("Fn1"), "Fn1Right": lang("Fn1"),
            })),
            ("Fn2 (hold Fn2, below Space)", fn_layer(keys, {
                **{f"Digit{i}": fn(str(i), "stick speed") for i in range(1, 5)},
                "KeyG": fn("+", "stick speed"), "KeyB": fn("−", "stick speed"),
                **{f"Digit{d}": fn(s, "pad speed") for d, s in zip("6789", ["Low", "Mid", "Hi", "Max"])},
                **{f"Key{c}": fn(p, "pad on") for c, p in zip("ASDF", ["Left", "Front L", "Front R", "Right"])},
                **{f"Key{c}": fn(p, "pad off") for c, p in zip("ZXCV", ["Left", "Front L", "Front R", "Right"])},
                "Space": fn("Middle click"), **STUDIO_LANG, "Fn2": lang("Fn2"),
            })),
        ],
    }

    keys = numpad_al21w()
    numpad = {k["id"]: fn(k["us"]) for k in keys if k["id"].startswith("Numpad")}
    out["numpad-numbers"] = {
        "title": "Numpad for numbers",
        "lede": "An SPM AL21W as a number input device: the numpad section, with Backspace in place of Num Lock and Esc, =, Tab and Fn1 (play/pause on a tap) on the top row; arrows, modifiers, volume and connection modes on Fn1; the lighting toggle and hardware reset on Fn2.",
        "plain": True,
        "keys": keys,
        "layers": [
            ("Layer 0", {
                **numpad, "TopLeft": fn("Esc"), "TopSecond": fn("=", "keypad", True), "TopThird": fn("Tab", "", True),
                "TopRight": lang("▶︎❚❚", "Fn1"), "NumLock": fn("⌫", "Backspace", True),
            }),
            ("Layer 1 (Fn1)", fn_layer(keys, {
                "TopLeft": fn("Vol−"), "TopSecond": fn("Vol+"), "TopThird": lang("Tab", "Fn2"), "TopRight": lang("Fn1"),
                "NumLock": fn("Del", "forward", True), "NumpadDivide": fn("↑"), "Numpad7": fn("←"), "Numpad8": fn("↓"), "Numpad9": fn("→"),
                "Numpad4": fn("⌥", "right"), "Numpad5": fn("⌘", "right"), "Numpad6": fn("⇧", "right"), "NumpadAdd": fn("Control", "right"), "NumpadMultiply": mod("RFU"), "NumpadSubtract": mod("RFU"), "NumpadEnter": fn("6KRO", "/ NKRO", True),
                "Numpad1": fn("BT 1"), "Numpad2": fn("BT 2"), "Numpad3": fn("BT 3"),
                "Numpad0": fn("USB", "mode", True), "NumpadDecimal": fn("2.4G", "mode", True),
            })),
            ("Layer 2 (Fn2: hold Fn1, then Tab)", open_layer(keys, {
                "TopLeft": fn("Light", "on/off", True), "TopSecond": lang("英数"), "TopThird": lang("Fn2"), "TopRight": lang("Fn1"),
                "Numpad0": fn("Reset", "hold 3 s", True), "NumpadMultiply": mod("RFU"), "NumpadSubtract": mod("RFU"),
            })),
        ],
    }

    keys = full_size()
    out["us-ansi-104-key-to-jis"] = {
        "title": "Full-size US as JIS",
        "lede": "A Hansung TFG Magnetox XF set up as a JIS keyboard in its own firmware: plain keys and MO() only, because the firmware's mod-tap is broken.",
        "keys": keys,
        "layers": [
            ("Layer 0", base_layer(keys, {
                "CapsLock": mod("Control", True), "PrintScreen": fn("⌘⇧4"), "ScrollLock": fn("Caps"), "Pause": fn("▶︎❚❚"),
                "ControlLeft": lang("Fn"), "MetaLeft": mod("⌥", True), "AltLeft": mod("⌘", True), "Space": mod(""),
                "AltRight": lang("かな"), "MetaRight": mod("⌘", True), "ContextMenu": mod("⌥", True), "ControlRight": lang("Fn"),
            })),
            ("Layer 1 (Fn)", fn_layer(keys, {
                **{f"F{i}": fkey(i + 12) for i in range(1, 13)}, "F6": {**fkey(18), "jk": "Korean Key"},
                **HHKB_FN, "Backquote": {"kind": "blank"}, "Backspace": fn("Del"), "Backslash": fn("Ins"),
                "KeyZ": fn("⌥"), "KeyX": fn("⌘"),
                "MetaLeft": lang("カタカナ"), "AltLeft": lang("英数"), "Space": mod(""),
                "AltRight": send("IntlYen"), "MetaRight": send("Slash"), "ContextMenu": send("IntlRo"),
                "ControlLeft": lang("Fn"), "ControlRight": lang("Fn"),
                "PrintScreen": fn("PrtSc"), "ScrollLock": fn("ScrLk"), "Pause": fn("Pause"),
            })),
        ],
    }

    keys = tkl()
    out["us-ansi-87-key-to-jis"] = {
        "title": "Tenkeyless US as JIS",
        "lede": "A MONGDOL 87 remapped in its firmware: カタカナ, 英数 and かな on the thumbs with Fn and ⌘ on hold, ¥ and ろ on the Fn layer.",
        "keys": keys,
        "layers": [
            ("Layer 0", base_layer(keys, {
                "CapsLock": mod("Control", True), "PrintScreen": fn("⌘⇧4"), "ScrollLock": fn("Caps"), "Pause": fn("▶︎❚❚"),
                "ControlLeft": lang("カタカナ", "Fn"), "MetaLeft": mod("⌥", True), "AltLeft": lang("英数", "⌘"), "Space": mod(""),
                "AltRight": lang("かな"), "MetaRight": mod("⌘", True), "ContextMenu": mod("⌥", True), "ControlRight": lang("Fn"),
            })),
            ("Layer 2 (Fn)", fn_layer(keys, {
                **{f"F{i}": fkey(i + 12) for i in range(1, 13)}, "F6": {**fkey(18), "jk": "Korean Key"},
                "AltRight": send("IntlYen"), "MetaRight": send("Slash"), "ContextMenu": send("IntlRo"),
                "ControlLeft": lang("Fn"), "ControlRight": lang("Fn"),
            })),
        ],
    }

    keys = hhkb()
    out["hhkb-pro-bt-us-to-jis"] = {
        "title": "HHKB US as JIS",
        "lede": "An HHKB Professional BT (US) through Karabiner-Elements: tap vs hold on the modifiers, ¥ and JIS's ] on spare keys, Backspace top right, and a second Fn on right ◇.",
        "keys": keys,
        "layers": [
            ("Base", base_layer(keys, {
                "AltLeft": lang("カタカナ", "⌥"), "MetaLeft": lang("英数", "⌘"), "MetaRight": lang("かな", "⌘"),
                "AltRight": lang("Fn"), "Fn": lang("Fn"), "ShiftRight": tap("IntlRo", "Shift"), "Space": mod(""),
                "Backslash": send("IntlYen"), "Backspace": send("Backslash"), "Backquote": mod("⌫", True),
            })),
            ("Fn (the HHKB's Fn, or right ◇)", fn_layer(keys, {**HHKB_FN, "Fn": lang("Fn"), "AltRight": lang("Fn")})),
        ],
    }

    keys = macbook()
    out["macbook-us-to-jis"] = {
        "title": "MacBook US as JIS",
        "lede": "A MacBook's built-in US keyboard through Karabiner-Elements; the keyboard itself stays US ANSI, so it types as printed whenever Karabiner isn't running.",
        "keys": keys,
        "layers": [
            ("Base", base_layer(keys, {
                "ControlLeft": lang("カタカナ", "control"), "MetaLeft": lang("英数", "⌘"), "MetaRight": lang("かな", "⌘"),
                "ShiftRight": tap("IntlRo", "shift"), "CapsLock": mod("control", True), "Fn": lang("🌐", "Fn"),
                "AltRight": lang("Fn"), "AltLeft": mod("⌥"), "Space": mod(""), "TouchID": {"kind": "blank"},
            })),
            ("Fn (🌐, or right ⌥)", fn_layer(keys, {
                **HHKB_FN, "Backquote": {"kind": "blank"}, "Minus": send("IntlYen"), "Equal": {"kind": "blank"},
                **{f"F{i}": fkey(i) for i in range(1, 13)}, "Backspace": fn("Del"),
                "ArrowLeft": fn("Home"), "ArrowRight": fn("End"), "ArrowUp": fn("PgUp"), "ArrowDown": fn("PgDn"),
                "Fn": lang("Fn"), "AltRight": lang("Fn"),
            })),
        ],
    }
    return out


def main():
    template = open(os.path.join(HERE, "template.html"), encoding="utf-8").read()
    for name, layout in layouts().items():
        data = {"title": layout["title"], "lede": layout["lede"], "keys": layout["keys"],
                "capLegend": layout.get("cap_legend", "the US QWERTY key cap"),
                "plain": layout.get("plain", False),
                "layers": [{"name": n, "keys": l} for n, l in layout["layers"]],
                "modeA": MODE_A, "kana": KANA}
        html = template.replace("{{TITLE}}", layout["title"]).replace("{{DATA}}", json.dumps(data, ensure_ascii=False))
        with open(os.path.join(LAYOUTS, name, "layout.html"), "w", encoding="utf-8") as f:
            f.write(html)
        print(f"{name}/layout.html")


if __name__ == "__main__":
    main()
