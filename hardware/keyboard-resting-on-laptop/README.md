# Backspace sent the message with a stray `3`; a Hanja pick typed its number

**Status:** open, hypothesis (2026-10-17). Neither reproduced with injected keys.

Source: FKeyIME, [`docs/issues/backspace-sends-enter.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/backspace-sends-enter.md),
[`docs/issues/hanja-pick-types-a-digit.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/hanja-pick-types-a-digit.md),
commits [`09a599f`](https://github.com/themrsung/fkeyime/commit/09a599f),
[`f37135f`](https://github.com/themrsung/fkeyime/commit/f37135f).

## Symptoms

1. In the Claude app, Backspace sent the message as if Enter had been pressed, and a stray `3` was
   typed in between. After a restart Backspace worked normally.
2. In Notepad with the Microsoft Korean IME (the AutoHotkey path: F18, then F17 for 한자), picking a
   Hanja with Down and Enter also typed the candidate's number.

## What was checked

- (1) FKeyIME's log: Claude was in English mode, where Backspace isn't in FKeyIME's table and
  nothing is composed, so FKeyIME passes it on untouched *(code and log)*. Injected keys gave no
  Enter in a Win32 Edit, a TSF RichEdit or Edge: `hu` Backspace `x` → `hx`; Backspace emptying a
  Korean, kana or conversion composition deleted cleanly; Edge's key log had no Enter
  (`fkeyime_probe.exe --typing` "EN backspace" cases and `--type-fg` on a test page).
- (2) FKeyIME wasn't involved: it never loaded in that Notepad *(log, loaded modules)*. Injected keys
  picked correctly every time (the digit 1, Enter, Down+Enter, Down+2) in a Win32 Edit and a Notepad
  tab, over two rounds (`--hanja`, `--hanja-fg`). The report then went away.

## Hypothesis (owner's)

The HHKB rests on top of the laptop. Pressing Backspace, top right on the HHKB, may also press the
laptop's own keys underneath (the keypad's Enter and `3`). That would explain both symptoms and why
injected keys never show them. The source links (2) to the same cause as *probably*.

## Recorded way to check it if it comes back

Record key codes while reproducing it with `fkeyime_probe.exe --keylog 40` (vk, scan, extended,
injected, from a low-level hook): the laptop's keys come from a different keyboard than the HHKB
and would show as extra key events. Not done yet.
