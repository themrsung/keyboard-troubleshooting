# Over Parsec from a Mac, only English works

**Status:** open (2026-10-18). Typing works with JIS symbols; switching modes doesn't. Waiting on
an owner decision.

Source: FKeyIME, [`docs/issues/parsec-from-mac.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/parsec-from-mac.md),
commit [`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e).

## Setup

HHKB HYBRID Type-S JIS on a Mac mini, set up as hhkb-ekj-trilingual's macOS guide says (Karabiner:
the HHKB key → F18, 英数 and かな keys). Parsec client on the Mac, Parsec host on the owner's Windows
PC over LAN, FKeyIME (development install) on Windows.

## What arrives on Windows *(measured, passive low-level hook + Raw Input)*

Every key from Parsec is injected (`LLKHF_INJECTED`) with a virtual key and a scan code.

| Pressed on the Mac | Arrives on Windows |
| --- | --- |
| Letters, digits, Shift, Space, Backspace, Enter | Normal scan codes |
| Shift+2, the `[` and `:` keys | scan 0x03 with Shift, 0x1B, 0x28 |
| ¥ | scan 0x7D (VK 0xFF), the JIS ¥ position |
| F18 (HHKB key), F19, F20, 英数, かな | **nothing** |
| Ctrl | **nothing** (owner: "control doesn't come through") |
| (something with Option) | Alt+Esc (scan 0x01 with Alt), three times |

With FKeyIME EN active, the owner typed `12"[:¥`: JIS symbols, because FKeyIME maps scan codes with
its own table and Parsec keeps the positions.

## Two separate causes, as recorded

1. FKeyIME wasn't running at first: after the reboot nothing loaded it
   ([sign-in-starts-on-microsoft-ime](../sign-in-starts-on-microsoft-ime/README.md)), so the first
   test typed through the Microsoft IMEs and the US layout. Picking FKeyIME ENG fixed that part.
2. Parsec from macOS doesn't forward F18–F20, 英数, かな or Ctrl *(measured: they never reach
   Windows)*. Why (Parsec's Mac key table, Karabiner's order, a Parsec setting) isn't known.

## Options the source lists for the owner (none chosen or tested)

- A Karabiner rule for Parsec only, mapping the HHKB key to Option+`` ` `` with FKeyIME's cycle key
  on (one cycling key instead of three one-way keys; whether Option+`` ` `` arrives as Alt+`` ` `` is
  not measured).
- A new FKeyIME option with three forwardable combos as one-way mode keys (adds key bindings, which
  the project's scope rule leaves to the owner).
- Finding out whether Parsec can forward F13–F24 (not tested).

The source notes that Ctrl not arriving is a Parsec / Karabiner matter on the Mac.
