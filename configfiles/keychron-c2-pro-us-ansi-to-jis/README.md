# Keychron C2 Pro: US ANSI to JIS, macOS and Windows

The first cross-platform configuration here: one VIA keymap for a **Keychron C2 Pro** (ANSI, RGB,
USB `3434:0520`, stock firmware, VIA protocol 11) that carries a layout for each side of its
Mac / Windows switch.

| Switch | Base layer | Fn layer | Layout |
|---|---|---|---|
| Mac | 0 | 1 | [us-ansi-104-key-to-jis-with-lt](../../layouts/us-ansi-104-key-to-jis-with-lt/README.md): JIS's keys for macOS, カタカナ / 英数 on a tap of the left Fn / ⌘ |
| Windows | 2 | 3 | [windows-104-key-golden](../../layouts-windows-ko-kr/windows-104-key-golden/README.md): the golden layout for Windows with the Microsoft IME Korean |

The file is [keychron-c2-pro.layout.json](keychron-c2-pro.layout.json): all four layers in VIA's
saved-layout format, keys in matrix order (6 × 20), read from the board.

## How to use

- **The Mac / Windows switch,** next to the USB port, picks the layout: **Mac** makes layer 0 the
  base layer, **Windows** makes it layer 2. It's safe to toggle while the keyboard is plugged in
  and in use.
- **The configuration is built around that:** each side's Fn key reaches only its own Fn layer
  (`MO(1)` / `LT(1,…)` on the Mac side, `MO(3)` / `LT(3,…)` on the Windows side), so the two
  layouts never mix.
- **To load it:** VIA's Save + Load (Load), or write the keycodes over raw HID with
  [viahid](../../via/raw-hid-keymap-editing/README.md). **Back up the board's current keymap
  first.** Loading the file hasn't been tried yet. Keychron's own keycodes (Task View and File
  Explorer on the Windows Fn layer) are written as hex (0x7F07, 0x7F08), because this firmware
  numbers them differently from VIA's `CUSTOM(n)`, and VIA may not take them: set those two keys
  by hand if it doesn't.
- **On the Mac,** store the keyboard as **JIS** (see the Mac layout's README), so ¥ and ろ type.
- **On Windows,** check the Microsoft IME Korean's keyboard type (see the Windows layout's README):
  on Type 1, Right Alt and Right Control are 한/영 and 한자.
