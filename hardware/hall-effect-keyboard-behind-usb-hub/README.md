# A hall-effect keyboard stopped working behind a USB hub

**Status:** fixed; hardware (2026-10-24).

## Setup

- Computer: macOS, Apple Silicon.
- Keyboard: Hansung TFG Magnetox XF, stock firmware, wired (hall-effect switches).
- Hub: a cheap USB4 hub with its own power supply, about two years old.
- Cable: USB-A (hub) to USB-C (keyboard).

## Symptom

The keyboard suddenly stopped working. Nothing on the setup had been changed.

## What fixed it

A different cable in a different hub port. The keyboard has worked since.

Both were changed at the same time, so whether the old cable or the old port was at fault isn't
known. The owner puts it down to unstable power delivery: the keyboard came back once the
connection changed, with the keyboard itself unchanged. Neither the old cable nor the old port has
been measured.

## What to try, in order

1. Another port on the hub.
2. Another cable.
3. Plugging the keyboard straight into the computer, with no hub.

Only once all three have failed is the keyboard itself likely to be faulty.

## Applies to

- Hall-effect (magnetic) keyboards: seen here.
- Other keyboards whose switches draw more power: inferred, not seen.

## Cost

At best nothing and a few minutes. Skipping these steps can mean sending a working keyboard for
repair or replacing it.
