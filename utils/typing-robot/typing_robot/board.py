"""Boards and keymaps, read from VIA's own files.

- A board is a VIA keyboard definition (``definition.json``): ``matrix`` and ``layouts.keymap``, the
  latter in KLE (keyboard-layout-editor) format, where each key's first label is its matrix
  position, ``"row,col"``.
- A keymap is a VIA saved layout (``layout.json``, VIA's "Save layout"): ``layers`` is a list of
  layers, each a flat list of QMK keycodes in matrix order (``row * cols + col``).

Coordinates are in key units (u): x grows to the right, y grows toward the typist.
"""
import json
from dataclasses import dataclass

from .keycodes import CHAR_OF


@dataclass(frozen=True)
class Key:
    id: str     # the VIA matrix position, "row,col"
    line: int   # the physical row: which KLE row the key is drawn on (0 = top)
    x: float
    y: float
    w: float
    h: float

    @property
    def cx(self):
        return self.x + self.w / 2

    @property
    def cy(self):
        return self.y + self.h / 2


class Board:
    def __init__(self, name, rows, cols, keys, vendor_product_id=None):
        self.name = name
        self.rows = rows
        self.cols = cols
        self.keys = keys
        self.vendor_product_id = vendor_product_id
        self.by_id = {k.id: k for k in keys}

    def lines(self):
        """The keys, by physical row, left to right."""
        out = {}
        for k in self.keys:
            out.setdefault(k.line, []).append(k)
        return [sorted(out[i], key=lambda k: k.x) for i in sorted(out)]


def parse_kle(rows):
    """Keys from a KLE keymap as VIA uses it. Supports x / y offsets, w / h, and decals (skipped);
    keys of a non-default layout option (VIA's 4th label, "group,option" with option != 0) are left
    out. Rotation isn't supported."""
    keys = []
    y = 0.0
    for line, row in enumerate(rows):
        x = 0.0
        w = h = 1.0
        decal = False
        for item in row:
            if isinstance(item, dict):
                if "r" in item or "rx" in item or "ry" in item:
                    raise ValueError("rotated keys aren't supported")
                x += item.get("x", 0)
                y += item.get("y", 0)
                w = item.get("w", w)
                h = item.get("h", h)
                decal = item.get("d", decal)
                continue
            labels = str(item).split("\n")
            option = labels[3] if len(labels) > 3 else ""
            skip = decal or (option and "," in option and option.split(",")[1].strip() != "0")
            if not skip:
                keys.append(Key(labels[0].strip(), line, x, y, w, h))
            x += w
            w = h = 1.0
            decal = False
        y += 1
    return keys


def load_board(path):
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    vpid = None
    if "vendorId" in d and "productId" in d:
        vpid = (int(d["vendorId"], 16) << 16) | int(d["productId"], 16)
    return Board(d["name"], d["matrix"]["rows"], d["matrix"]["cols"], parse_kle(d["layouts"]["keymap"]), vpid)


def load_keymap(path, board, layer=0):
    """{key id: keycode} for one layer of a VIA saved layout."""
    with open(path, encoding="utf-8") as f:
        d = json.load(f)
    codes = d["layers"][layer]
    out = {}
    for k in board.keys:
        r, c = (int(v) for v in k.id.split(","))
        out[k.id] = codes[r * board.cols + c]
    return out


def layout_of(keymap):
    """{character: key id} for the characters the tool knows (see keycodes.CHAR_OF). The first key
    wins when two send the same character (the WeCat4's two Spaces)."""
    out = {}
    for key_id, code in keymap.items():
        ch = CHAR_OF.get(code)
        if ch is not None and ch not in out:
            out[ch] = key_id
    return out


def save_keymap(src_path, dst_path, board, layout, layer=0):
    """Writes a copy of a VIA saved layout with the characters of ``layout`` on its keys, for VIA's
    "Load saved layout". Keys whose character isn't in ``layout`` keep their keycode."""
    from .keycodes import KC_OF
    with open(src_path, encoding="utf-8") as f:
        d = json.load(f)
    codes = d["layers"][layer]
    for ch, key_id in layout.items():
        r, c = (int(v) for v in key_id.split(","))
        codes[r * board.cols + c] = KC_OF[ch]
    with open(dst_path, "w", encoding="utf-8") as f:
        json.dump(d, f, indent=2)
        f.write("\n")
