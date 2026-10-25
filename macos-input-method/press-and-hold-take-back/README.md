# Press and hold needed the app to take back a typed letter

**Status:** press and hold removed; ⌥ + letter variants replace it (2026-10-22).

Source: JIS Korean, commit [`197a050`](https://github.com/team-mirae/jis-korean/commit/197a050),
spec §3.6.3.

## What it was

JIS English offered accented variants when a letter key was held, like macOS's own press and hold.
The letter already typed was taken back into the marked text (`jk_take_back`), by replacing the
characters before the insertion point.

## Problem

iTerm2 and Discord ignored the take-back, so the held letter stayed in front of the variant.

## What replaced it

⌥ (`KeyUniversalAuxiliary`) + a letter shows the variants as marked text in a row with nothing
typed first (1–9 and 0 pick, Enter (`KeyISOEnter`) commits, Esc (`KeyEscape`) and Backspace
(`KeyDeleteLeft`) cancel). `jk_take_back` was removed. Holding a key repeats it. In
terminals ⌥ goes to the app untouched (readline).
