# Modifier keys and compositions

**Status:** both solved in FKeyIME (2026-10-17).

Source: FKeyIME, [`docs/issues/shift-splits-the-composition.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/shift-splits-the-composition.md),
spec §8 and §9, commits [`7091f80`](https://github.com/themrsung/fkeyime/commit/7091f80),
[`aa6789f`](https://github.com/themrsung/fkeyime/commit/aa6789f).

## Shift ended the composition

**Symptom.** わたしは… and とうきょう… converted wrongly: the conversion server received only
ょうにいく, because とうき had been committed when Shift was pressed for ょ *(measured with temporary
logging)*. In Korean, 있 (ㅇ ㅣ Shift+ㅆ) would have committed 이 first.

**Cause.** A modifier key on its own counted as "another key", and other keys end the composition.

**Fix.** Shift, Ctrl, Alt, Win and Caps Lock on their own pass through without touching the
composition. Probe cases "KO Shift inside a syllable" and "CONV Shift doesn't split the kana".

## An app ended the composition on Alt and left the caret inside it

**Symptom.** With ``Alt+` `` as a mode key, RichEdit ended the composition itself when Alt went
down, and the next text landed in front of it: `あ가` instead of `가あ` *(measured)*.

**Fix.** When an app ends a composition with the caret inside it, FKeyIME moves the caret past it.
