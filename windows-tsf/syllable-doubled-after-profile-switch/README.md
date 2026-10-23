# A Korean syllable appears twice after a profile switch

**Status:** solved with a delayed profile switch (2026-10-17).

Source: FKeyIME, [`docs/issues/korean-syllable-doubled.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/korean-syllable-doubled.md),
spec §8, commit [`fc127e4`](https://github.com/themrsung/fkeyime/commit/fc127e4).

## Symptom

In a classic Win32 Edit: 가, then F19 (switch to English), then `a` gave `가a가`; 가 then F19 alone
gave `가가`. Committing with Enter first worked.

## What didn't help *(measured)*

- Comparing contexts by COM identity.
- Skipping a redundant `SetText`.
- Unpreserving the F-keys while composing.
- Switching the profile after a posted message.

## Cause and fix

Switching the profile (`ActivateProfile`) right after an F-key commits a Korean composition makes
the IMM compatibility layer deliver the syllable a second time. FKeyIME switches only after the app
has processed the commit: on a 30 ms timer (`WM_TIMER` comes after queued messages) or at the next
key, whichever comes first. Keys typed in between already follow the new mode. Tested with every
key queued at once as well.
