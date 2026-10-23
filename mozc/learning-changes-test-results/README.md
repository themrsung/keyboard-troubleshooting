# Picking a non-first candidate in a test changed later runs

**Status:** a test rule (2026-10-17).

Source: FKeyIME, [`docs/issues/development-notes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/development-notes.md),
spec §9 ("Learning").

Mozc learns the candidates the user picks and keeps that in its profile folder. One manual test
that picked いく (not the first candidate) made it the first candidate for later runs *(measured)*.
FKeyIME's tests accept only first candidates, or cancel.
