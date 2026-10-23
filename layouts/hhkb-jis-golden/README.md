# The golden layout: HHKB Studio JIS

The reference every other layout here follows ([PRINCIPLES.md](../PRINCIPLES.md), 3). It's a stock
HHKB Studio JIS with a new bottom row, set up entirely in PFU's HHKB Studio Keymap Tool: one key per
language (カタカナ, 英数, かな), the HHKB Fn layer on Fn1, and the pointing stick and gesture pads
on Fn2.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="layout-dark.png">
  <img alt="An HHKB Studio JIS: each key with its JIS cap, JIS Korean (Mode A) and Japanese Kana legends, on the Standard, Fn1 and Fn2 layers" src="layout-light.png">
</picture>

The keymap is [hhkb-studio-golden.hks](hhkb-studio-golden.hks), an export from the HHKB Studio
Keymap Tool, in **Profile1**; the drawing is [layout.html](layout.html). Load the file in the tool
and write it to the keyboard. **Importing replaces all four profiles**, so export your own first if
you keep a keymap on any of them. Profiles 2–4 are copied unchanged from the source below (PFU's
Mac default, and two Windows keymaps).

## Source, and what changed

Based on the owner's Profile1 in
[hhkb-ekj-trilingual](https://github.com/themrsung/hhkb-ekj-trilingual), in
[`docs/07-hhkb-studio.md`](https://github.com/themrsung/hhkb-ekj-trilingual/blob/main/docs/07-hhkb-studio.md)
and [`docs/hhkb-studio-setting-all.hks`](https://github.com/themrsung/hhkb-ekj-trilingual/blob/main/docs/hhkb-studio-setting-all.hks),
with two changes:

| | Source | Golden |
|---|---|---|
| The key in the 半/全 position, on all four layers | F18 (code 109, 0x6D) | **カタカナ** (code 136, 0x88: the Windows JIS カタカナ/ひらがな key) |
| Gesture pads (left side, front left, front right, right side) | off, off, on, on | **all off** |

Nothing else in the file differs from the source. The file was made by editing the source export
with those changes, and hasn't been loaded back into the tool from this repository yet.

## Standard

Stock JIS except the bottom row:

```
Fn1 | カタカナ | Opt | ⌘ | 英数 | Space | かな | ⌘ | Opt | Fn1 | ← | ↓ | →
                    LB | Fn2 | RB        (pointing-stick buttons, below Space)
```

- **カタカナ** goes to Korean in [JIS Korean](https://github.com/team-mirae/jis-korean), **英数** to
  English, **かな** to Japanese. macOS discards カタカナ by itself; JIS Korean reads it at the HID
  level ([katakana-lost-by-macos](../../macos-input-method/katakana-lost-by-macos/README.md)).
- Control is left of A, ↑ is in the Shift row left of the right Shift, ¥ and ろ are where JIS has
  them.

## Fn1 (hold either Fn1)

The HHKB Fn layer: F1–F12 on the number row, Insert / Delete on ¥ / BS, Caps Lock on Tab, the
arrows and Home / End / Page keys on the right, volume and eject on A–F, keypad keys on H J N M and
Enter, Power on Esc. Studio extras: the arrow cluster gives Delete, right ⌘ and right Control, and ↑
gives right Shift.

Fn1+I and Fn1+P send Print Screen and Pause. With the Karabiner-Elements rules from
hhkb-ekj-trilingual they become ⌘⇧4 and Play/Pause; without them macOS sees F13 and F15.

## Fn2 (hold Fn2, below Space)

| Fn2 + | Does |
|---|---|
| 1 / 2 / 3 / 4, G / B | Pointing-stick speed 1–4, faster / slower |
| 6 / 7 / 8 / 9 | Gesture-pad speed: low, mid, high, max |
| A / S / D / F | Turn on the left-side, front-left, front-right, right-side pad |
| Z / X / C / V | Turn the same pads off |
| Space | Middle click |

The pads start off, so touching the case's edges does nothing until a pad is turned on.

## Fn3

Unused: the same as Standard, except that the カタカナ key is set on it too. Not drawn.

## Settings outside the keymap

DIP switches all off; pointing-stick buttons on (LB / Fn2 / RB); gesture pads all off. See the
source for what the DIP switches do on the Studio and for Bluetooth pairing.
