# HHKB Studio JIS: the golden layout, with Back and Forward on Fn2

One profile for an **HHKB Studio JIS** (`PD-ID120B`, stock firmware, USB `04FE:0015`), for PFU's
HHKB Studio Keymap Tool (1.1.2). It's the [golden layout](../../layouts/hhkb-jis-golden/README.md)'s
Profile1 with two keys added on Fn2 (`KeyHHKBFunctionTwo`), for macOS.

The file is [hhkb-studio-jis.hks](hhkb-studio-jis.hks), exported from the owner's board on
2026-10-26 with **Single** save type: one profile, not all four.

## What's added

| Fn2 + | Sends | Code in the file | Does on macOS |
|---|---|---|---|
| 英数 (`KeyJISMacEnglish`) | Right ⌘ (`KeyRightPrimary`) + `KeyHandakuten` (`[` on JIS) | 6192 (0x1830) | Back (⌘[) |
| かな (`KeyJISMacKana`) | Right ⌘ (`KeyRightPrimary`) + `KeyMu` (`]` on JIS) | 6194 (0x1832) | Forward (⌘]) |

Back sits on the left and Forward on the right, under the thumbs, next to the pointing-stick
buttons. ⌘[ / ⌘] is macOS's closest thing to a universal Back / Forward, and it needs no
Karabiner-Elements; mouse buttons 4 and 5 (`KeyMouseButtonFour` / `KeyMouseButtonFive`) would be
ideal, but Safari and Finder ignore them without a remapper.

The keys are the JIS positions of `[` and `]` (HID 0x30 and 0x32), so the keyboard must be stored
by macOS as **JIS**, see [studio-jis-stored-as-ansi](../../hhkb/studio-jis-stored-as-ansi/README.md).
Stored as ANSI, the same codes are ⌘] and ⌘\\.

How the tool writes modifiers isn't documented. The high byte 0x18 is what it wrote for right ⌘
on both keys; an earlier export, with ⌘ set differently on かな, had 0x08 there.

## Where it works *(tested on macOS 27.0.1, 2026-10-26)*

| App | Back / Forward |
|---|---|
| Google Chrome | works |
| Finder | works |
| Claude (desktop) | works |
| Discord | works |
| Signal | doesn't |
| YouTube Music (PWA) | doesn't; other PWAs likely don't either |
| VS Code | doesn't; ⌘[ / ⌘] there are Outdent / Indent Line |

## How to use

1. **Store the Studio as JIS** on the Mac (see above).
2. Load [hhkb-studio-jis.hks](hhkb-studio-jis.hks) in the HHKB Studio Keymap Tool and write it to
   the keyboard. Unlike the golden layout's file it carries one profile; which profile the tool
   loads it into, and whether the others are left alone, hasn't been checked, so **export your
   own keymap first**.
3. **DIP switches** are recorded in the file, but they're physical: on the owner's board only
   switch 6 is on (power saving off). Set them by hand.

Everything else is the golden layout's Profile1: pointing-stick buttons on, gesture pads all off,
the Standard, Fn1, Fn2 and Fn3 layers as drawn there.
