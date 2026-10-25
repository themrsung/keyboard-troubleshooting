# Layout proposals

JIS's extra keys on keyboards that don't have them, for macOS: カタカナ, 英数 and かな (one key per
language), ¥ and ろ, mostly for [JIS Korean](https://github.com/team-mirae/jis-korean) and
Japanese Kana input. New layouts should follow the [principles](PRINCIPLES.md).

| Layout | Keyboard | How |
|---|---|---|
| [hhkb-jis-golden](hhkb-jis-golden/README.md) | HHKB Studio JIS: **the golden layout**, the reference for the others | PFU's keymap tool |
| [numpad-numbers](numpad-numbers/README.md) | Numpad (SPM AL21W), as a number input device | Firmware (VIA protocol), from the factory keymap |
| [us-ansi-104-key-to-jis](us-ansi-104-key-to-jis/README.md) | Full-size US (Hansung TFG Magnetox XF) | Firmware only, plain keys and `MO()`: the board's mod-tap is broken |
| [us-ansi-104-key-to-jis-with-lt](us-ansi-104-key-to-jis-with-lt/README.md) | Full-size US (Keychron C2 Pro, Mac side) | The same in firmware, plus カタカナ / 英数 on a tap of Fn / ⌘ |
| [us-ansi-87-key-to-jis](us-ansi-87-key-to-jis/README.md) | Tenkeyless US (MONGDOL 87) | Firmware, tap vs hold, two layers |
| [hhkb-pro-bt-us-to-jis](hhkb-pro-bt-us-to-jis/README.md) | HHKB Professional BT (US) | Karabiner-Elements |
| [macbook-us-to-jis](macbook-us-to-jis/README.md) | MacBook built-in (US) | Karabiner-Elements, keyboard type stays US |
| [macbook-jis-to-hhkb](macbook-jis-to-hhkb/README.md) | MacBook built-in (JIS), with the HHKB Fn layer | Karabiner-Elements: カタカナ / Fn on Caps Lock, Fn on 🌐 too |

Every layout stores the keyboard (or Karabiner's virtual keyboard) as JIS on macOS: see the
background in the [README](../README.md).

## Key names

The READMEs and drawings here call keys by their legends. This legend maps them to the
repository's canonical names ([KEYNAMES.md](../conventions/keynames/REV1-20261025/KEYNAMES.md)),
for every file in `layouts/`. Key tables also have a column with the canonical name of the
physical key. Tap vs hold is written `HoldTap(hold, tap)`, such as
`HoldTap(KeyMomentaryLayerOne, KeyJISKLangKorean)` for `LT(1,KC_INT2)`. Shortcuts such as ⌘⇧4
have no key name of their own.

| Written here | Canonical name |
|---|---|
| カタカナ (the HHKB JIS 半/全 position, `KC_INT2`, Karabiner `japanese_pc_katakana`) | `KeyJISKLangKorean` |
| 英数 (`KC_LNG2`) / かな (`KC_LNG1`) | `KeyJISMacEnglish` / `KeyJISMacKana` |
| ¥ / ろ / JIS's ] (む in Kana) | `KeyLongKatakana` / `KeyRo` / `KeyMu` |
| Control left of A (HHKB-style, in Caps Lock's place) | `KeyLeftControl` |
| Ctrl, Control on a full-size or MacBook bottom row: left / right | `KeyUSLeftControl` / `KeyRightControl` |
| Caps Lock (the function) | `KeyCapsLock` |
| ⌥, Opt, Option, ◇, Alt: left / right / either | `KeyLeftAuxiliary` / `KeyRightAuxiliary` / `KeyUniversalAuxiliary` |
| ⌘, Command, ◆, Win, Code (an aftermarket cap): left / right / either | `KeyLeftPrimary` / `KeyRightPrimary` / `KeyUniversalPrimary` |
| Shift: left / right | `KeyLeftShift` / `KeyRightShift` |
| Fn, Fn1 on the HHKB JIS and HHKB Studio: left / right / either | `KeyHHKBLeftFunction` / `KeyHHKBRightFunction` / `KeyHHKBUniversalFunction` |
| Fn2 / Fn3 on the HHKB Studio | `KeyHHKBFunctionTwo` / `KeyHHKBFunctionThree` |
| The HHKB US's Fn (right of right Shift) | `KeyHHKBUSFunction` |
| fn / 🌐 on a MacBook | `KeyMACGlobe` |
| A Fn made by Karabiner-Elements (right ◇, right ⌥, a held Caps Lock) | `KeyVirtualFunction` |
| Fn on a firmware-remapped board: `MO(1)` / `MO(2)` | `KeyMomentaryLayerOne` / `KeyMomentaryLayerTwo` |
| The Keychron C2 Pro's Fn cap (in the Menu key's place) | `KeyWINMenu` position; as stock Fn, `KeyMomentaryNextLayer` |
| The AL21W's Fn1 (`LT(1, KC_MPLY)`) / Fn2 (`LT(2, KC_TAB)`) | `HoldTap(KeyMomentaryLayerOne, KeyMediaPlayPause)` / `HoldTap(KeyMomentaryLayerTwo, KeyTab)` |
| LB / RB / middle click (the HHKB Studio's pointing-stick buttons) | `KeyLeftMouseButton` / `KeyRightMouseButton` / `KeyMiddleMouseButton` |
| Touch ID | `KeyMACTouchID` |
| Menu (a full-size board's bottom row) | `KeyWINMenu` |
| Cortana / light (the Keychron C2 Pro's caps on Scroll Lock and Pause) | `KeyWINCortana` / `KeyKeyboardHardwareControl` |
| Backspace, BS, delete (Mac) / forward Delete, Del / Ins | `KeyDeleteLeft` / `KeyDeleteRight` / `KeyInsert` |
| Enter, return / keypad Enter / Esc / Tab / Space | `KeyISOEnter` (`KeyUSEnter` on US boards) / `KeyNumpadEnter` / `KeyEscape` / `KeyTab` / `KeySpacebar` |
| The US caps `` ` `` - = [ ] \ ; ' , . / | `KeyUSGrave`, `KeyUSMinus`, `KeyUSEquals`, `KeyUSLeftBracket`, `KeyUSRightBracket`, `KeyUSBackslash`, `KeyUSSemicolon`, `KeyUSApostrophe`, `KeyUSComma`, `KeyUSPeriod`, `KeyUSSlash` |
| The JIS caps ^ @ [ ] ; : (by position) | `KeyHe`, `KeyDakuten`, `KeyHandakuten`, `KeyMu`, `KeyRe`, `KeyKe` |
| 1 … 0 / F1 … F24 (F18 was the old Korean key) | `KeyOne` … `KeyZero` / `KeyFunctionOne` … `KeyFunctionTwentyFour` |
| The AL21W's top row, 1st to 4th | `KeyNumpadTopOne` … `KeyNumpadTopFour` |
| Num Lock / keypad = / keypad * / + − . 0–9 | `KeyWINNumlock` / `KeyNumpadEquals` / `KeyNumpadMultiply`, `KeyNumpadDivide`, `KeyNumpadPlus`, `KeyNumpadMinus`, `KeyNumpadDecimal`, `KeyNumpadZero` … `KeyNumpadNine` |
| PrtSc / ScrLk / Pause | `KeyPrintScreen` / `KeyScrollLock` / `KeyPause` |
| Vol− / Vol+ / Mute / ▶︎❚❚ / ⏏ / Power / Calculator | `KeyVolumeDown` / `KeyVolumeUp` / `KeyMute` / `KeyMediaPlayPause` / `KeyEject` / `KeySystemPower` / `KeyCalculator` |
| Lighting, rollover, Bluetooth / USB / 2.4 GHz modes, hardware reset, pointing-stick and pad settings | `KeyKeyboardHardwareControl` |
| RFU (`KC_NO`, reserved for future use) | `KeyReservedForFutureUse` |
| Transparent (`KC_TRNS`; "same as the base layer" in the drawings) | `KeyPassthrough` |
| Deliberately undefined (hatched in the drawings) | `KeyAbstract` |

In [render/build.py](render/build.py), a key's id is its browser `KeyboardEvent.code` where it
has one (`ShiftRight`, `IntlRo`, `Lang1`), and its canonical name otherwise.

## The drawings

Each layout has a `layout.html` and light and dark PNGs, where every key shows three legends: its
US QWERTY cap (top left), what it types in JIS Korean's Mode A (bottom left) and in Japanese Kana
(bottom right), Shift above each. Remapped keys show what they type, outlined. They're generated
from [render/build.py](render/build.py) (the keyboards' geometry and each layout's layers) and
[render/template.html](render/template.html):

```sh
python3 -B layouts/render/build.py   # layouts/<name>/layout.html
sh layouts/render/render.sh          # layout-light.png and layout-dark.png, with Google Chrome
```
