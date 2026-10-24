"""Draws the mobile Korean flick candidates: one interactive layout.html per candidate.

    python3 -I layouts-mobile-korean-flick/render/build.py   # <name>-golden/ and candidates/<name>/layout.html
    sh layouts-mobile-korean-flick/render/render.sh          # and layout-light.png / layout-dark.png

Each layout is <name>-golden/layout.json or candidates/<name>/layout.json: its title and lede, whether it has a digit row,
an optional row of ten symbols above it ("symbols"), and the 12 keys of the 3×4 center, row by
row. The side columns (↺ ‹ 한A1 🌐 / ⌫ › space ↵) are the same for every candidate, from Gboard's
12-key, and live in template.html. A key is one of:

    {"kind": "flick", "legends": [tap, left, up, right, down]}   "" where a direction types nothing
    {"kind": "multitap", "cycle": [...], "label": ...}           repeat taps step through the cycle
    {"kind": "stroke", "stroke": "ㅣ" | "ㆍ" | "ㅡ"}             천지인's vowel strokes
    {"kind": "cycle", "table": name, "legends": [...]}           tap steps the last gesture's jamo
    {"kind": "blank"}

plus optional "label" (the center legend, when it isn't what a tap types), "sub" (a small note) and
"style" ("vowel" or "mod", for the cap color).

A candidate can also have "layers" for 한A1 to cycle through after Korean, such as {"en": rows,
"sym": rows}: four rows on the number rows' ten columns. Rows 1 and 2 take all ten; rows 3 and 4
take eight, from column 3, since 한A1 and 🌐 stay where they are. A cell is a character or
{"key": "shift" | "bs" | "enter" | "space", "span": n}.
"""
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# The 획·쌍 cycle the candidates share: plain → aspirated → tense, and a vowel's y-form
HOEK_SSANG = [["ㄱ", "ㅋ", "ㄲ"], ["ㄷ", "ㅌ", "ㄸ"], ["ㅂ", "ㅍ", "ㅃ"], ["ㅈ", "ㅊ", "ㅉ"], ["ㅅ", "ㅆ"],
              ["ㅏ", "ㅑ"], ["ㅓ", "ㅕ"], ["ㅗ", "ㅛ"], ["ㅜ", "ㅠ"], ["ㅐ", "ㅒ"], ["ㅔ", "ㅖ"]]


def main():
    template = open(os.path.join(HERE, "template.html"), encoding="utf-8").read()
    # The golden layout (<name>-golden/) and the candidates (candidates/<name>/)
    paths = glob.glob(os.path.join(ROOT, "*", "layout.json"))
    paths += glob.glob(os.path.join(ROOT, "candidates", "*", "layout.json"))
    for path in sorted(paths):
        layout = json.load(open(path, encoding="utf-8"))
        assert len(layout["keys"]) == 12, path
        for name, rows in layout.get("layers", {}).items():
            widths = [sum(1 if isinstance(c, str) else c.get("span", 1) for c in row) for row in rows]
            assert widths == [10, 10, 8, 8], (path, name, widths)
        data = {"title": layout["title"], "lede": layout["lede"], "digits": layout.get("digits", False),
                "symbols": layout.get("symbols", []), "layers": layout.get("layers", {}),
                "keys": layout["keys"], "join": layout.get("join", {}),
                "cycles": {"획·쌍": HOEK_SSANG, **layout.get("cycles", {})}}
        html = template.replace("{{TITLE}}", layout["title"]).replace("{{DATA}}", json.dumps(data, ensure_ascii=False))
        target = os.path.join(os.path.dirname(path), "layout.html")
        with open(target, "w", encoding="utf-8") as f:
            f.write(html)
        print(os.path.relpath(target, os.path.dirname(ROOT)))


if __name__ == "__main__":
    main()
