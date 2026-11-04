# MONSTARGEAR pebble mini: macOS, JIS's language keys on Fn

A VIA keymap for a **MONSTARGEAR pebble mini** (몬스타기어 조약돌 미니), which reports itself as
**GUTS WECAT4** (manufacturer "Hangsheng"; USB `342D:E47E`, stock firmware, VIA protocol 12). It's
the layout [mini-numberless](../../layouts/mini-numberless/README.md), as it is on the board.

The file is [gats-wecat4.layout.json](gats-wecat4.layout.json): all four layers in VIA's
saved-layout format, keys in matrix order (4 × 12), read from the board on 2026-11-04. It's not the factory keymap: the board had already been
customised when it was read, and the factory keymap hasn't been recorded. The 16
macro slots are empty on the board, and in the file too.
[gats-wecat4.definition.json](gats-wecat4.definition.json) is a VIA definition for the board: its
matrix and key positions.

| Layer | Reached with | Has |
|---|---|---|
| 0 | | Control left of A; Fn1, ⌥, ⌘, Space, Fn1, Space, ⌘, ⌥, Fn2 along the bottom |
| 1 | Fn1: bottom left, or between the spaces (`MO(1)`) | Esc, 1–0 and Delete on the top row; volume, eject, vim arrows, `` ` `` `[` `]` `\` `;` `'` ろ; 英数 and かな on the left and right Space |
| 2 | Fn2: bottom right (`MO(2)`) | F1–F12 on the top row; below it, the same as layer 1 |
| 3 | nothing | all passthrough |

## How to use

- **To load it:** VIA's Save + Load (Load), or write the keycodes over raw HID with
  [viahid](../../via/raw-hid-keymap-editing/README.md), using
  [wecat4-keymap.txt](../../layouts/mini-numberless/wecat4-keymap.txt) (the same keymap as
  `viahid set` arguments). **Back up the board's current keymap first.** Loading the file through
  VIA hasn't been tried: there's no VIA definition for this board in VIA's repository, so VIA
  needs [gats-wecat4.definition.json](gats-wecat4.definition.json), the board's definition,
  loaded first (Settings → Show Design tab → Load).
- **On the Mac,** store the keyboard as **JIS**, so ろ (`KC_INT1`) types. 英数 (`KC_LNG2`) and
  かな (`KC_LNG1`) work either way
  ([japanese-keycodes-on-macos](../../qmk/japanese-keycodes-on-macos/README.md)).
- **What the wipe of layer 3 dropped:** as found before the wipe, layer 3 held the board's RGB lighting keys,
  vendor keys (0x7E00–0x7E58, probably connection and battery) and 0x7C03; they're listed in the
  layout's README. Nothing in layers 0–2 reached layer 3.

## Key names

`KC_TRNS` is `KeyPassthrough`. `KC_NO` sits only at the matrix positions with no switch (`1,10`,
`3,3`, `3,6`, `3,8`). Other names: [Key names](../../layouts/README.md#key-names).
