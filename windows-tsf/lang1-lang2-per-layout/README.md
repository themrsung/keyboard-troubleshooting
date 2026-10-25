# 英数 / かな (LANG2 / LANG1) arrive differently under the US layout

**Status:** handled in FKeyIME by matching both forms by scan code; measured on the device
(2026-10-17).

Source: FKeyIME, spec §8 ("Mac 英数 / かな keys"), commit
[`a03bd9c`](https://github.com/themrsung/fkeyime/commit/a03bd9c). HHKB Studio, keymap Profile 1
(its macOS keymap), over Bluetooth.

## What Profile 1 sends *(measured with a low-level hook and Raw Input)*

The language key sends F18 (`KeyFunctionEighteen`, scan 0x69; which physical key isn't recorded);
英数 is HID LANG2 (`KeyJISMacEnglish`); かな is LANG1 (`KeyJISMacKana`); right Command
(`KeyRightPrimary`) is a plain Right Win (`E0 5C`), which a TIP can't use ([modifier-taps-unreachable](../modifier-taps-unreachable/README.md)).

## Windows delivers LANG1 / LANG2 per layout *(measured)*

| Thread layout | 英数 (LANG2) | かな (LANG1) |
| --- | --- | --- |
| Korean, Japanese | one key-down, VK 0x19, scan `E0 F1`, no key-up | one key-down, VK 0x15, scan `E0 F2`, no key-up |
| US | **no key-down**; two key-ups per press, scan 0x71 (VK 0xE9, then 0xFF) | **no key-down**; two key-ups, scan 0x72 (VK 0xFF) |

FKeyIME matches them by scan code on key-down (`E0 F1` / `E0 F2`) and on key-up (0x71 / 0x72,
acting on the first of the pair). Measured on the owner's HHKB Studio in Notepad: every direction
switched, including かな from English, which needed the key-up path.

## Injected keys don't reproduce it

A scan code alone gets no VK, and injecting VK + scan gives the key-down form under every layout.
The US layout's key-up form needs the real keyboard.

## Why it's opt-in

A Korean keyboard's 한자 (`KeyKTSHanja`) and 한/영 (`KeyKTSHangulToggle`) keys send the same HID
usages, so with the option on they would act as English and Japanese.

An earlier, reverted attempt (commits [`91b7605`](https://github.com/themrsung/fkeyime/commit/91b7605),
[`876010c`](https://github.com/themrsung/fkeyime/commit/876010c)) recognised 한/영 (`KeyKTSHangulToggle`) as
`VK_HANGUL` or the LANG1 scan code (0x72 / 0xF2), never as right Alt (`KeyRightAuxiliary`,
`E0 38`), which is the HHKB's real right Alt under the Japanese layout (measured with `MapVirtualKeyEx`). Reverted by the owner's decision.
