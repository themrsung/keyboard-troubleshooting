# Classic apps end a Korean composition at once

**Status:** solved in both TIPs with an interim-character selection (2026-10-17 in FKeyIME; JIS
Korean's Windows shell needed more for long compositions).

Source: FKeyIME, [`docs/issues/korean-jamo-not-composed.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/korean-jamo-not-composed.md),
commit [`fc127e4`](https://github.com/themrsung/fkeyime/commit/fc127e4); JIS Korean,
[`docs/troubleshooting/windows-tsf-notes.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/windows-tsf-notes.md).
Measured with each project's typing test (FKeyIME `fkeyime_probe --typing`; JIS Korean
`windows/tools/type-test.ps1`) in a classic Edit and a RichEdit through the IMM compatibility
layer, and a RichEdit on TSF itself (`SES_USECTF`).

## Symptom

In a classic Win32 Edit, Korean typed `ㅇㅏㄴㄴㅕㅇ` instead of `안녕`: every jamo committed on
its own. Japanese compositions in the same control worked. The log showed the app ending each
Korean composition right after it started (`OnCompositionTerminated` after every key).

## Cause, as recorded

Apps that reach TSF through the IMM compatibility layer treat a Korean composition with a plain
caret after it as finished.

## FKeyIME: one syllable

The composing syllable is selected as an **interim character** (a block cursor), as the Microsoft
Korean IME does.

## JIS Korean: a composition longer than one character

JIS Korean's composition is a whole segment, not one syllable:

| Tried | Result |
| --- | --- |
| Interim selection over the whole composition | `SetSelection` fails with `E_INVALIDARG` once it's longer than one character |
| A normal (non-interim) selection over it | The app ends the composition: `한ㄱ을` for 한글 |
| Interim on the last character only | The IMM layer commits everything before it, at every key: `한한한한글` |
| Interim on the first character, then leave it | **Works.** TSF keeps the interim selection as the composition grows: after `SetText` it covers the whole composition, interim style included (read back with `GetSelection`) |

So the shell sets the interim selection when it can, accepts the one TSF kept when it can't, and
only then falls back to a caret. Whether a context goes through the IMM layer: `TF_SS_TRANSITORY`
in `ITfContext::GetStatus`. TSF-native contexts get a plain caret.
