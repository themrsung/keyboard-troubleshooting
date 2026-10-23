"""Converts a definition from Hansung's web driver to a VIA v3 definition.

    python3 -I convert-definition.py hansung-definition.json via-definition.json

Hansung's driver (app.superstore.co.kr) keeps one definition per keyboard at
https://app.superstore.co.kr/definitions/b/<id>.json, where <id> is vendor ID << 16 | product ID
(68583748 for 0x0416:0x8144). The file is VIA's compiled definition with short field names:
nm name, uid vendor/product, grd matrix (rw rows, cl cols), pnl menus, cds keycodes, vw layout
(ks keys, each with rw/cl matrix position, x/y/w/h, ang/ox/oy rotation, dec decal). This turns the
keys' absolute positions back into the KLE keymap VIA v3 expects, and checks the round trip.
"""
import json
import sys


def to_kle(keys):
    rows = {}
    for k in keys:
        if k.get("ang", 0):
            sys.exit("rotated keys aren't supported")
        rows.setdefault(k["y"], []).append(k)
    kle, previous_y = [], None
    for y in sorted(rows):
        row, cursor = [], 0
        for i, k in enumerate(sorted(rows[y], key=lambda k: k["x"])):
            props = {}
            if i == 0:
                gap = y if previous_y is None else y - (previous_y + 1)
                if round(gap, 4):
                    props["y"] = round(gap, 4)
            if round(k["x"] - cursor, 4):
                props["x"] = round(k["x"] - cursor, 4)
            if k["w"] != 1:
                props["w"] = k["w"]
            if k["h"] != 1:
                props["h"] = k["h"]
            if k.get("dec"):
                props["d"] = True
            if props:
                row.append(props)
            row.append(f'{k["rw"]},{k["cl"]}')
            cursor = k["x"] + k["w"]
        kle.append(row)
        previous_y = y
    return kle


def positions(kle):
    """The absolute position of each "row,col" label in a KLE keymap."""
    found, y = {}, -1
    for row in kle:
        y, x, w, h = y + 1, 0, 1, 1
        for item in row:
            if isinstance(item, dict):
                x += item.get("x", 0)
                y += item.get("y", 0)
                w, h = item.get("w", 1), item.get("h", 1)
                continue
            found[item] = (round(x, 4), round(y, 4), w, h)
            x += w
            w, h = 1, 1
    return found


def main(source, destination):
    hansung = json.load(open(source))
    keys = hansung["vw"]["ks"]
    kle = to_kle(keys)
    placed = positions(kle)
    wrong = [k for k in keys if placed.get(f'{k["rw"]},{k["cl"]}') != (k["x"], k["y"], k["w"], k["h"])]
    if wrong:
        sys.exit(f"{len(wrong)} keys don't round-trip, e.g. {wrong[0]}")
    via = {
        "name": hansung["nm"],
        "vendorId": f'0x{hansung["uid"] >> 16:04X}',
        "productId": f'0x{hansung["uid"] & 0xFFFF:04X}',
        "matrix": {"rows": hansung["grd"]["rw"], "cols": hansung["grd"]["cl"]},
        "menus": hansung.get("pnl", []),
        "keycodes": hansung.get("cds", []),
        "layouts": {"keymap": kle},
    }
    if hansung["vw"].get("opt"):
        print("note: layout options aren't converted:", hansung["vw"]["opt"])
    with open(destination, "w") as f:
        f.write(json.dumps(via, ensure_ascii=False, indent=2) + "\n")
    print(f'{via["name"]}: {len(keys)} keys, {via["matrix"]["rows"]}x{via["matrix"]["cols"]} matrix, round trip ok')


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
