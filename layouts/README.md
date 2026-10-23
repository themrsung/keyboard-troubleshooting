# Layout proposals

JIS's extra keys on keyboards that don't have them, for macOS: カタカナ, 英数 and かな (one key per
language), ¥ and ろ, mostly for [JIS Korean](https://github.com/team-mirae/jis-korean) and
Japanese Kana input. New layouts should follow the [principles](PRINCIPLES.md).

| Layout | Keyboard | How |
|---|---|---|
| [hhkb-jis-golden](hhkb-jis-golden/README.md) | HHKB Studio JIS: **the golden layout**, the reference for the others | PFU's keymap tool |
| [numpad-numbers](numpad-numbers/README.md) | Numpad (SPM AL21W), as a number input device | Firmware (VIA protocol), from the factory keymap |
| [us-ansi-104-key-to-jis](us-ansi-104-key-to-jis/README.md) | Full-size US (Hansung TFG Magnetox XF) | Firmware only, plain keys and `MO()`: the board's mod-tap is broken |
| [us-ansi-87-key-to-jis](us-ansi-87-key-to-jis/README.md) | Tenkeyless US (MONGDOL 87) | Firmware, tap vs hold, two layers |
| [hhkb-pro-bt-us-to-jis](hhkb-pro-bt-us-to-jis/README.md) | HHKB Professional BT (US) | Karabiner-Elements |
| [macbook-us-to-jis](macbook-us-to-jis/README.md) | MacBook built-in (US) | Karabiner-Elements, keyboard type stays US |

Every layout stores the keyboard (or Karabiner's virtual keyboard) as JIS on macOS: see the
background in the [README](../README.md).

## The drawings

Each layout has a `layout.html` and light and dark PNGs, where every key shows three legends: its
US QWERTY cap (top left), what it types in JIS Korean's Mode A (bottom left) and in Japanese Kana
(bottom right), Shift above each. Remapped keys show what they type, outlined. They're generated
from [render/build.py](render/build.py) (the keyboards' geometry and each layout's layers) and
[render/template.html](render/template.html):

```sh
python3 -I layouts/render/build.py   # layouts/<name>/layout.html
sh layouts/render/render.sh          # layout-light.png and layout-dark.png, with Google Chrome
```
