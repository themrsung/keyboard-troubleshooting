# Keyboard Setup Assistant can't identify a keyboard that Karabiner-Elements is modifying

**Status:** cause found and worked around by the owner (2026-11-04).

## Setup

- Computer: macOS 27.0.1, Apple Silicon.
- Karabiner-Elements 16.3.0.
- Keyboard: **not recorded** (a keyboard turned on in Karabiner's Devices settings).

## Symptom

Keyboard Setup Assistant (System Settings → Keyboard → Change Keyboard Type…) couldn't identify
the keyboard's type by its normal flow, where it asks for the key right of the left Shift and the
key left of the right Shift. Skipping and picking the type by hand, or writing it with `defaults
write` (see the [Background](../../README.md#background-keyboard-types-on-macos)), were the ways
around it until now.

## Cause

The keyboard was turned on in Karabiner-Elements (Settings → Devices, "Modify events"). Karabiner
then holds the keyboard itself, and its presses reach macOS from Karabiner's virtual keyboard
(`Karabiner DriverKit VirtualHIDKeyboard`, `593-1452-0`), not from the keyboard. Why that stops
the assistant isn't measured; most likely it doesn't see the presses come from the keyboard it's
trying to identify. Turning the keyboard off in Karabiner is what made it work.

## Fix

1. In Karabiner-Elements, Settings → Devices, **turn the keyboard off**. Karabiner lets go of it
   right away; no restart of Karabiner or of the Mac is needed.
2. Run Keyboard Setup Assistant. It now goes through the normal flow and identifies the type.
3. Turn the keyboard back on in Karabiner, if you use Karabiner with it.

The type the assistant stores is for the keyboard itself. While Karabiner modifies the keyboard,
macOS reads keys by the **virtual keyboard's** type (`593-1452-0`), which is stored separately; set
that one by hand if needed
([hhkb/studio-jis-stored-as-ansi](../../hhkb/studio-jis-stored-as-ansi/README.md)).

## Related

- [via/keycap-legend-language-and-jis](../../via/keycap-legend-language-and-jis/README.md): a
  remapped MONGDOL 87 that started typing JIS keys while Karabiner's device settings were being
  changed. Karabiner letting go of the board may explain it better than VIA's legend language.
