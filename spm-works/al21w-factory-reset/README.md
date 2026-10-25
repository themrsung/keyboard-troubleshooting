# Resetting an SPM AL21W numpad to factory settings

**Status:** works (2026-10-24). macOS, Apple Silicon; SPM AL21W, stock firmware (VIA protocol 12,
4 layers), over USB (`0x36B0:0x311A`).

Two resets, and they do different things:

| Reset | How | Clears | Checked |
|---|---|---|---|
| Keymap only | VIA's `DYNAMIC_KEYMAP_RESET` (0x06): [`viahid … reset`](../../via/raw-hid-keymap-editing/README.md) | Every layer back to the firmware's keymap | Yes: answered, and the layers read back as factory |
| Everything | **Hold Fn + 0 for about 3 seconds** (`QK_CLEAR_EEPROM`) | The keyboard's saved settings, then it restarts; the lighting came back | Yes: the board restarted (below) |

## Key names

This note uses the short names on the left. Their canonical names
([KEYNAMES REV1-20261025](../../conventions/keynames/REV1-20261025/KEYNAMES.md)):

| Here | Canonical name |
|---|---|
| Fn, Fn1 (the top-right key, the factory `MO(1)`) | `KeyMomentaryLayerOne` |
| Top row, left to right, by position | `KeyNumpadTopOne` · `KeyNumpadTopTwo` · `KeyNumpadTopThree` · `KeyNumpadTopFour` (Fn) |
| 0, 1 … 9, . (keypad) | `KeyNumpadZero`, `KeyNumpadOne` … `KeyNumpadNine`, `KeyNumpadDecimal` |
| / · * · − · + · Enter (keypad) | `KeyNumpadDivide` · `KeyNumpadMultiply` · `KeyNumpadMinus` · `KeyNumpadPlus` · `KeyNumpadEnter` |
| Num Lock | `KeyWINNumlock` |
| Esc · Calculator · Backspace · Tab | `KeyEscape` · `KeyCalculator` · `KeyDeleteLeft` · `KeyTab` |
| `KbPrSlp` (SPM's label) | Probably `KeySystemSleep` (not checked) |
| かな (LANG1) · 英数 (LANG2) · F18 · Play/Pause | `KeyJISMacKana` · `KeyJISMacEnglish` · `KeyFunctionEighteen` · `KeyMediaPlayPause` |
| Lighting on/off, hue, saturation, brightness, effect speed, next effect; 6-key / full rollover; 2.4 GHz; Bluetooth 1–3; `QK_CLEAR_EEPROM` | `KeyKeyboardHardwareControl` (the lighting brightness keys aren't `KeyBrightnessUp` / `KeyBrightnessDown`) |
| `KC_NO` (the top-right key on layers 2 and 3) | `KeyNoOp` |
| Fn1 · Fn2 in [numpad-numbers](../../layouts/numpad-numbers/README.md) | `HoldTap(KeyMomentaryLayerOne, KeyMediaPlayPause)` · `HoldTap(KeyMomentaryLayerTwo, KeyTab)` |

So Fn + 0 is `KeyMomentaryLayerOne` held with `KeyNumpadZero`, and layer 1 has the reset on
`KeyNumpadZero`.

## What was wrong

The keymap had been edited in VIA, and the top-right key, the board's only `MO(1)`, had been set
to かな (LANG1), so the Fn layer couldn't be reached at all. Layer 0's other edits: F18, 英数 (LANG2)
and Play/Pause on the top row and Num Lock. Layers 1–3 were still factory.

## Keymap reset over VIA

```sh
swiftc -O -o viahid via/raw-hid-keymap-editing/viahid.swift
./viahid --vid 0x36B0 --pid 0x311A version                         # protocol 12, 4 layers
for l in 0 1 2 3; do ./viahid --vid 0x36B0 --pid 0x311A --rows 6 --cols 5 read $l > layer$l.txt; done
./viahid --vid 0x36B0 --pid 0x311A reset                           # "keymap reset: ok"
```

Back the layers up first: the reset can't be undone except by writing them back with `set`. It
leaves the lighting and macros alone.

## Hardware reset: Fn + 0, held

Fn is the top-right key. Its layer has `QK_CLEAR_EEPROM` (0x7C03) on 0.

- **A short press didn't restart the board:** the start time worked out from its uptime (VIA's
  uptime value) was the same before and after.
- **Held for about 3 seconds, it did:** the uptime was 21 s when read right afterwards, and the
  lighting came back. The keymap read back as factory on all four layers.

Standard QMK acts on this keycode as soon as it's pressed; this firmware evidently wants a hold.
Whether it also clears 2.4 GHz and Bluetooth pairings wasn't checked.

**On a numpad, Fn + 0 is an easy chord to hit.** The hold is what keeps it from wiping the board by
accident. [numpad-numbers](../../layouts/numpad-numbers/README.md) moves it to a second Fn layer:
Fn1 + Tab + 0, held. After a reset the factory keymap is back, with the reset on Fn + 0 again.

## The factory keymap

Read back after the resets. Rows and columns are the matrix in SPM's VIA definition (6 × 5).
Key names are as in [Key names](#key-names).

| Row | Layer 0 | Layer 1 (Fn) |
|---|---|---|
| Top | Esc · Calculator · Backspace · **Fn** (`MO(1)`) | `KbPrSlp` · Tab · — · held |
| 1 | Num Lock · / · * · − | `RTOG` (lighting on/off) · hue − · hue + · brightness − |
| 2 | 7 · 8 · 9 · + | `SIX_N` (6-key / full rollover) · effect speed − · effect speed + · brightness + |
| 3 | 4 · 5 · 6 | 2.4 GHz · saturation − · saturation + |
| 4 | 1 · 2 · 3 · Enter | Bluetooth 1 · Bluetooth 2 · Bluetooth 3 · next effect |
| 5 | 0 · . | **`QK_CLEAR_EEPROM`** (hold) · . |

Layers 2 and 3 are layer 0 without Fn (the top-right key is `KC_NO`). Layer 1 is read from its
keycodes against SPM's VIA definition (vendor keycodes from 0x7E00 in its `customKeycodes` order)
and QMK's protocol-12 numbering; only Fn + 0 was pressed.
