# Hansung firmware: mod-tap adds right Shift, and taps send the modifier

**Status:** confirmed on one keyboard; no workaround in firmware. Not reported to Hansung (their
in-app assistant only answers in Korean).

## Setup

- TFG Magnetox XF (USB 0x0416:0x8144), firmware **5.9.2**, VIA protocol 12, 4 layers, over USB.
- macOS 27, keyboard stored as JIS (42), not modified by Karabiner.
- Keycodes written with VIA's `DYNAMIC_KEYMAP_SET_KEYCODE` (see
  [raw-hid-keymap-editing](../../via/raw-hid-keymap-editing/README.md)), in QMK's current
  numbering: mod-tap is `0x2000 | mods << 8 | key`, with `MOD_LCTL` 0x01, `MOD_LSFT` 0x02,
  `MOD_LGUI` 0x08. That's the numbering Hansung's own driver uses for protocol 11 and 12, so the
  values are what its driver would write ([web-driver-internals](../web-driver-internals/README.md)).

## What happens

| Keycode | Action | Expected | Got |
|---|---|---|---|
| `LGUI_T(KC_Z)` `0x281D` | hold, press Tab | ⌘Tab | ⌘⇧Tab (app switcher goes backwards) |
| `LGUI_T(KC_Z)` `0x281D` | tap | `z` | no `z` |
| `LCTL_T(KC_Z)` `0x211D` | hold, press Tab in Chrome | next tab | previous tab (⌃⇧Tab) |
| `LSFT_T(KC_Z)` `0x221D` | tap | `z` | `Z` |
| `LGUI_T(KC_LNG2)` `0x2891` | tap, in macOS Japanese input | 英数, switches to English | nothing; plain `KC_LNG2` on the same key works |

With right Shift removed (below):

| Keycode | Action | Expected | Got |
|---|---|---|---|
| `LCTL_T(KC_Z)` `0x211D` | tap | `z` | ⌃Z (suspended the terminal's foreground job) |
| `LGUI_T(KC_LNG2)` `0x2891` | tap | 英数 | acts as ⌘, never 英数 |

`LGUI_T(KC_LNG2)` failed the same way on two different keys, so it isn't one switch.

Working on the same keyboard: plain keys, modifier combos such as `LSG(KC_4)` (⌘⇧4),
`LT(1,KC_KANA)` (tap and hold both right), `MO(1)`, `KC_INT1`–`KC_INT3`, `KC_LNG1`, `KC_LNG2`.

## Why (most likely)

Two separate faults.

1. **Right Shift on hold.** The keycode's upper byte for a mod-tap is 0x20–0x3F (0x28 for
   `MOD_LGUI`). Read as a raw USB HID modifier byte, 0x08 is left GUI, as intended, but 0x20 is
   **right Shift**, and 0x20 is set in every mod-tap keycode, because it's the bit that marks the
   mod-tap range. So the firmware seems to apply the upper byte as a HID modifier byte instead of
   QMK's 5-bit modifier field (`& 0x1F`).
2. **The modifier on tap.** QMK sends only the tap key on a tap. This firmware seems to press the
   modifier when the key goes down and keep it held while it sends the tap key, so a tap of
   `LCTL_T(KC_Z)` is ⌃Z.

The second fault is the one that can't be worked around: even with right Shift removed, a tap still
carries the modifier.

## What was tried

- **Other tap keys:** a whole row of candidates for 英数 (`KC_LNG2`, `KC_INT4` 変換, `KC_INT5` 無変換,
  `KC_LNG3`–`KC_LNG5`, `KC_GRV`) and mod-tap variants (`LGUI_T(KC_INT5)`, `RGUI_T(KC_LNG2)`).
  Only plain `KC_LNG2` gave 英数. See [japanese-keycodes-on-macos](../../qmk/japanese-keycodes-on-macos/README.md).
- **Removing the right Shift on the Mac:** the keyboard's own right Shift set to `KC_LSFT` in
  firmware, and macOS told to drop right Shift from this keyboard only:

  ```sh
  hidutil property --matching '{"VendorID":0x0416,"ProductID":0x8144}' \
    --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E5,"HIDKeyboardModifierMappingDst":0x700000000}]}'
  # undo:
  hidutil property --matching '{"VendorID":0x0416,"ProductID":0x8144}' --set '{"UserKeyMapping":[]}'
  ```

  The keyboard's right Shift still typed capitals (through `KC_LSFT`), but taps still went out with
  the modifier (the second table above).

## Workarounds

- Use **layer-tap** (`LT`) for tap vs hold, and plain keys. Layers don't send anything when held, so
  the fault never shows.
- For tap one key / hold a modifier, let the computer do it: Karabiner-Elements' `to_if_alone`
  with the key set to the plain modifier in firmware. See
  [hhkb-pro-bt-us-to-jis](../../layouts/hhkb-pro-bt-us-to-jis/README.md).
- Or give up tap vs hold on that key: the [104-key layout](../../layouts/us-ansi-104-key-to-jis/README.md)
  puts カタカナ and 英数 on Fn + the modifiers instead.

Hansung's own **ModTap** feature (an advanced key in its driver, for the magnetic switches) wasn't
tested. Its tap key list has no 英数 anyway.
