# Editing a VIA keyboard's keymap without the VIA app

VIA is a protocol as much as an app: the keyboard answers 32-byte raw-HID reports on usage page
0xFF60, and the keymap is just keycodes in its memory. When the app won't do something (see
[any-key-rejects-layer-tap](../any-key-rejects-layer-tap/README.md)), or for backups and scripted
changes, [viahid.swift](viahid.swift) talks to the keyboard directly on macOS. macOS asks for no
permission for this vendor-defined interface.

```sh
swiftc -O -o viahid viahid.swift
./viahid --vid 0x0416 --pid 0x8144 --vendor-version 0xF0 version   # protocol, uptime, layers, Hansung's version
./viahid --vid 0x0416 --pid 0x8144 --rows 7 --cols 16 read 0 > layer0.txt
./viahid --vid 0x0416 --pid 0x8144 set 0 5 2 0091 1 5 1 0088      # layer row col hexcode, repeated
./viahid --vid 0x36B0 --pid 0x311A reset                           # every layer back to the firmware's keymap
```

- `read` prints `row,col keycode` lines, so a layer saved with it can be written back by turning
  each line into `set` arguments. **Back up every layer before writing.**
- `set` checks the keyboard's echo of each write and prints `ok`.
- `reset` sends `DYNAMIC_KEYMAP_RESET` (0x06): every layer back to the keymap built into the
  firmware. Lighting and macros stay as they are. Back up first.
- Keycodes are 16-bit QMK keycodes in the numbering of the keyboard's protocol version (protocol
  11+: mod-tap 0x2000, layer-tap 0x4000, `MO()` 0x5220). Some useful ones:

| Keycode | Value | Canonical name |
|---|---|---|
| `KC_INT1` ろ / `KC_INT2` カタカナ / `KC_INT3` ¥ | 0x0087 / 0x0088 / 0x0089 | `KeyRo` / `KeyJISKLangKorean` / `KeyLongKatakana` |
| `KC_LNG1` (かな on a Mac) / `KC_LNG2` (英数 on a Mac) | 0x0090 / 0x0091 | `KeyJISMacKana` / `KeyJISMacEnglish` (on Korean boards `KeyKTSHangulToggle` / `KeyKTSHanja`) |
| `KC_F13` … `KC_F24` | 0x0068 … 0x0073 | `KeyFunctionThirteen` … `KeyFunctionTwentyFour` |
| `KC_TRNS` / `KC_NO` | 0x0001 / 0x0000 | `KeyPassthrough` / no key (sent by `KeyNoOp` and `KeyReservedForFutureUse`) |
| `LSG(KC_4)` (⌘⇧4 on a Mac) | 0x0A21 | shortcut: `KeyLeftShift` + `KeyLeftPrimary` + `KeyFour` |
| `LT(layer, kc)` | 0x4000 + layer << 8 + kc | `HoldTap(KeyMomentaryLayerN, key)` |
| `MO(layer)` | 0x5220 + layer | `KeyMomentaryLayerN` |
| `MT(mods, kc)` | 0x2000 + mods << 8 + kc | `HoldTap(modifier, key)` |

The rows and columns are the keyboard's matrix, from its VIA definition (`"matrix"`), and a key's
`row,col` is its label in the definition's keymap. Tested on a Hansung TFG Magnetox XF, and `reset` on an SPM AL21W
([al21w-factory-reset](../../spm-works/al21w-factory-reset/README.md)).

## Pitfall

In zsh, an unquoted `$args` isn't split into words, so `./viahid … set $args` passes one argument
and writes nothing. Use an array: `args=(0 5 2 0091 …); ./viahid … set "${args[@]}"`.
