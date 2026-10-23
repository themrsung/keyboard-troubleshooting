# A key eaten in OnTestKeyDown and handed back later is lost

**Status:** solved in JIS Korean's Windows shell.

Source: JIS Korean, [`docs/troubleshooting/windows-tsf-notes.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/windows-tsf-notes.md),
first section. Windows 11 Pro 25H2, the three controls of `type-test.ps1`.

## Symptom

Enter, the arrows and Tab after Korean text: the text was committed, but the key itself was lost
(no new line, the caret didn't move), in all three controls.

## Cause *(measured)*

The shell claimed every key while composing in `OnTestKeyDown`, so `OnKeyDown` could commit first,
then returned keys the engine didn't consume with `*eaten = FALSE`. By then Windows has already
turned the key into a processed IME key: the app never sees it, and no key-up follows. The source
notes that FKeyIME's "commit, then pass" uses the same pattern.

## Fix

The engine runs in `OnTestKeyDown`. A key it doesn't consume is committed there and reported as not
eaten, so the app gets it; the result is cached for the `OnKeyDown` that may follow. Two measured
facts shaped the cache:

- `OnKeyDown` gets the lParam with the repeat count cleared (`0x220000` after `0x220001`), so the
  cache compares virtual key, scan code and extended flag only. Comparing the whole lParam sent
  every key through the engine twice.
- Through the IMM layer, `OnKeyDown` follows even for a key `OnTestKeyDown` didn't eat (Enter), so
  not-eaten results are cached too.
