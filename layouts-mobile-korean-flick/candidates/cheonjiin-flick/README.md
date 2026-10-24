# 천지인 flick

**New.** 천지인's grid and consonant groups, so a 천지인 typist finds every key where it was, with
**no multi-tap**: a flick types what a repeat tap would have. The three vowel strokes become the
dot-direction vowel keys of the artifact's drafts.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="layout-dark.png">
  <img alt="The 천지인 flick candidate: 천지인's 12-key grid with flicks in place of repeat taps, in Gboard's frame" src="layout-light.png">
</picture>

Try it: [layout.html](layout.html). Keys are [layout.json](layout.json).

## Keys

| | Tap | ← | ↑ | → | ↓ |
|---|---|---|---|---|---|
| **ㅣ** (row 1) | ㅣ | ㅔ | ㅢ | ㅐ | ㅡ |
| **ㆍ** (row 1) | — | ㅓ | ㅗ | ㅏ | ㅜ |
| **ᆢ** (row 1) | — | ㅕ | ㅛ | ㅑ | ㅠ |
| **ㄱ** (row 2) | ㄱ | — | ㄲ | ㅋ | — |
| **ㄴ** (row 2) | ㄴ | — | — | ㄹ | — |
| **ㄷ** (row 2) | ㄷ | — | ㄸ | ㅌ | — |
| **ㅂ** (row 3) | ㅂ | — | ㅃ | ㅍ | — |
| **ㅅ** (row 3) | ㅅ | — | ㅆ | ㅎ | — |
| **ㅈ** (row 3) | ㅈ | — | ㅉ | ㅊ | — |
| **.** (row 4) | . | , | ? | ! | — |
| **ㅇ** (row 4) | ㅇ | — | — | ㅁ | — |
| **~** (row 4) | ~ | ' | " | · | - |

A digit row 1–0 sits on top.

## Rules

- **Consonants: one rule for every key.** Tap is the first consonant of the 천지인 group, → the
  second (the one a second tap would give: ㅋ ㄹ ㅌ ㅍ ㅎ ㅊ ㅁ), ↑ the doubled one. ← and ↓ are free on
  every consonant key.
- **Vowels where the dot points**: ㆍ and ᆢ as in the drafts. The 천지인 row's ㅡ moves to ㅣ ↓.
- **천지인's own vowel joins still work**: ㅏ then ㅣ is ㅐ, ㅓ + ㅣ ㅔ, ㅑ + ㅣ ㅒ, ㅕ + ㅣ ㅖ, ㅘ + ㅣ ㅙ,
  ㅝ + ㅣ ㅞ, on top of the standard compounds (ㅗ + ㅏ ㅘ). ㅒ and ㅖ have no flick of their own; they're
  ᆢ then ㅣ.
- Where 천지인 has space (row 4, right), there's a second punctuation key, since space is in the
  side column.

## Typing

| Text | Gestures |
|---|---|
| 한글 | ㅅ→ (ㅎ) · ㆍ→ (ㅏ) · ㄴ · ㄱ · ㅣ↓ (ㅡ) · ㄴ→ (ㄹ) |
| 까치 | ㄱ↑ (ㄲ) · ㆍ→ · ㅈ→ (ㅊ) · ㅣ |
| 뭐해 | ㅇ→ (ㅁ) · ㆍ↓ (ㅜ) · ㆍ← (ㅓ) · ㅅ→ (ㅎ) · ㆍ→ · ㅣ |
| 없어 | ㅇ · ㆍ← · ㅂ · ㅅ · ㅇ · ㆍ← |

## Compared with 천지인

- 각 is ㄱ ㆍ→ ㄱ: no timeout or → key between the two ㄱ, which multi-tap needs.
- Vowels take one gesture instead of two or three strokes (ㅕ is ᆢ← instead of ㆍㆍㅣ).
- Typists have to unlearn the strokes; the consonant positions carry over.

## Open questions

- Use the free ← and ↓ on the consonant keys, for example ↓ for the aspirated form and → for
  the second consonant only where they differ (ㄴ → ㄹ, ㅅ → ㅎ, ㅇ → ㅁ).
- ㆍ and ᆢ have no tap.
