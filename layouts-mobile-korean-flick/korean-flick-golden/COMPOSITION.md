# Composition: the golden layout

How the [golden layout](README.md) turns gestures into text: the procedure, and test cases to check
an implementation against. **Procedure only: there is no test code yet.** The page
([layout.html](layout.html)) implements most of it; [where it differs](#where-the-page-differs) is
listed at the end.

The rules are [JIS Korean](https://github.com/team-mirae/jis-korean)'s deterministic engine (its
`docs/spec.md` §4.1–4.3 and §5–6), carried over to flick gestures. Its predictive layer (§10) is
**out of scope**: no prediction, no learning, no correction. The same gestures always give the same
text. Items marked **[decide]** are open.

## 1. Terms

- **Gesture**: one touch on one key, either a **tap** or a **flick** (← ↑ → ↓). One gesture types
  at most one thing.
- **Jamo gesture**: a gesture that types one consonant or one vowel (table below). Every other
  gesture that types something is a **symbol gesture**: `# · = + - . , ? ! ~ ' " · —`, the number
  section (`< [ { ( 「 」 ) } ] >` and 1–0).
- **Simple vowel**: ㅏ ㅐ ㅑ ㅒ ㅓ ㅔ ㅕ ㅖ ㅗ ㅛ ㅜ ㅠ ㅡ ㅣ. **Dedicated compound**: ㅘ ㅙ ㅚ ㅝ ㅟ ㅢ
  typed by one gesture (the ㅘ key, and ㅣ↑).
- **Segment**: the unconfirmed text, everything typed since the last commit (JIS Korean §5). It's
  shown as preedit and can still change; committed text can't.
- **Syllable being composed**: the last syllable of the segment, while it can still take jamo.

The golden layout's jamo gestures:

| Key | Tap | ← | ↑ | → | ↓ |
|---|---|---|---|---|---|
| ㅇ | ㅇ | ㄱ | ㄲ | ㅋ | ㅎ |
| ㄴ | ㄴ | ㄷ | ㄸ | ㅌ | — |
| ㄹ | ㄹ | ㅅ | ㅆ | ㅈ | ㅉ |
| ㅁ | ㅁ | ㅂ | ㅃ | ㅍ | ㅊ |
| # | *#* | ㅕ | ㅛ | ㅑ | ㅠ |
| ㆍ | *·* | ㅓ | ㅗ | ㅏ | ㅜ |
| = | *=* | ㅖ | *+* | ㅒ | *-* |
| ㅣ | ㅣ | ㅔ | ㅢ | ㅐ | ㅡ |
| ㅘ | ㅘ | ㅝ | ㅚ | ㅙ | ㅟ |

*Italic*: symbol gestures on those keys.

## 2. Rules

### R1. The syllable automaton

The standard 2-set automaton (JIS Korean §4.1), one jamo gesture at a time:

| State of the syllable being composed | Gesture | Result |
|---|---|---|
| none | consonant | starts a syllable with it as initial |
| none | vowel | starts a syllable on an **implied ㅇ** (R2) |
| initial only | vowel | becomes the medial |
| initial only | consonant | the lone initial ends as a bare jamo; the consonant starts a new syllable |
| initial + medial | simple vowel that combines (R3) | compound medial |
| initial + medial | any other vowel | new syllable on an implied ㅇ |
| initial + medial | consonant that can be a final | becomes the final |
| initial + medial | ㄸ ㅃ ㅉ (never finals) | new syllable with it as initial |
| with final | consonant that makes a double final (R4) | double final |
| with final | other consonant | new syllable with it as initial |
| with final | vowel | **the final moves** to a new syllable as its initial; for a double final, only its second consonant moves |
| any | symbol gesture | the syllable ends; the symbol joins the segment |

A gesture never changes a syllable before the one being composed, except a final moving out of it.

### R2. Implied ㅇ

A vowel with no initial to take it starts a syllable on an implied ㅇ: at the start of the
segment, after a symbol, after a commit, and after a syllable it can't combine with. A typed ㅇ
gives the same text (ㅇ then ㅏ is 아, as ㅏ alone is); the difference shows only in R7.

### R3. Compound vowels

- A **simple vowel** combines with the medial before it when the syllable has no final, by the
  sequences ㅗㅏ → ㅘ, ㅗㅐ → ㅙ, ㅗㅣ → ㅚ, ㅜㅓ → ㅝ, ㅜㅔ → ㅞ, ㅜㅣ → ㅟ, ㅡㅣ → ㅢ. Nothing else
  combines: ㅏ then ㅣ is 아이, not 애.
- A **dedicated compound** never combines, before or after: 고 then ㅘ is 고와, 과 (by the ㅘ key) then
  ㅣ is 과이. JIS Korean §4.1's rule for its dedicated compound keys.
- ㅞ has no gesture of its own; it's ㅜ then ㅔ.

### R4. Finals

- Finals: ㄱ ㄲ ㄴ ㄷ ㄹ ㅁ ㅂ ㅅ ㅆ ㅇ ㅈ ㅊ ㅋ ㅌ ㅍ ㅎ. Never ㄸ ㅃ ㅉ.
- Double finals by sequence: ㄱㅅ ㄴㅈ ㄴㅎ ㄹㄱ ㄹㅁ ㄹㅂ ㄹㅅ ㄹㅌ ㄹㅍ ㄹㅎ ㅂㅅ.

### R5. Repeating a vowel puts the final back

JIS Korean §4.2's double press, for flicks. When a vowel gesture has just **taken a final** (R1,
"the final moves"), repeating **the same gesture** (same key, same direction) right away:

1. puts the final back on its syllable (the whole double final, if it was one), and
2. starts the vowel's own syllable on a ㅇ that counts as **typed**, not implied (R7).

Only the first repeat does this; a third press types the vowel again as usual. Any other gesture in
between, including a different direction on the same key, ends the chance. Backspace right after a
repeat takes the repeat back (R8). Whether a repeat is possible again after that backspace is
**[decide]**.

### R6. Commits

The segment is committed, and the next vowel starts on an implied ㅇ again, by:

| Gesture | Effect |
|---|---|
| 확정 | Commit (R7). Nothing else is typed. |
| Space | Commit, then type a space. Space never converts. |
| ↵ | Commit, then a new line. |
| 한A1 (any layer change) | Commit, as an IME switch does. |
| ‹ › | Commit, then move the cursor. |
| Focus loss, app switch, 🌐 | Commit. |

Symbols don't commit: they stay in the segment, though they end the syllable (R1).

### R7. 확정

JIS Korean's F6 (`KeyFunctionSix`):

1. If the segment ends in a syllable on an **implied** ㅇ with **no final**, that ㅇ is dropped and the
   bare medial stays: ㅏ → ㅏ, 가어 → 가ㅓ, 와 → ㅘ. Only that last syllable: 아이 → 아ㅣ.
2. Then the whole segment is committed.

A typed ㅇ, or one from a repeat (R5), stays. With an empty segment, 확정 does nothing, so a second
확정 in a row changes nothing.

### R8. Backspace (⌫)

- With a non-empty segment, ⌫ removes the **last gesture's jamo or symbol** and recomposes:
  한 → 하 → ㅎ → nothing.
- A compound built by sequence comes apart one gesture at a time (과 typed ㅗ ㅏ → 고); a dedicated
  compound goes in one press (과 typed with the ㅘ key → ㄱ).
- An implied ㅇ isn't a gesture, so it goes with its vowel (가어 → 가).
- Right after a repeat (R5), ⌫ takes the repeat back and gives the first reading (말이 → 마리).
- With an empty segment, ⌫ passes through to the app, which deletes committed text as it does for
  any keyboard.

### R9. Undo (↺)

↺ undoes the last gesture in the segment, ⌫ included, and restores the segment as it was before
it. After a jamo or symbol gesture it gives the same text as ⌫. It differs after ⌫ itself (↺ brings
back what ⌫ removed) and after a commit: with an empty segment, ↺ does nothing, so it never reaches
into committed text **[decide]**.

### R10. The A and 1 layers

A and 1 type straight into the app, with no segment. Switching to them commits the Korean segment
(R6).

- ⇧ capitalizes the next letter, then turns off. A second ⇧ before a letter turns it off. Caps lock
  is **[decide]**.
- ⌫ on A and 1 always passes through.

## 3. Test cases

Gestures are written as key + direction, with the jamo or symbol in parentheses when it helps: `ㅇ←
(ㄱ)` is a flick left on the ㅇ key, `ㅣ` a tap on the ㅣ key. **Result** is the whole text;
when a case is about commits, `|` marks where the committed text ends (`한|아`: 한 committed, 아
unconfirmed).

### Implied ㅇ (R2, R3)

| # | Gestures | Result |
|---|---|---|
| T1 | ㆍ→ (ㅏ) | 아 |
| T2 | ㆍ↑ (ㅗ) · ㆍ→ (ㅏ) | 와 |
| T3 | ㅇ← (ㄱ) · ㆍ→ · ㆍ← (ㅓ) | 가어 |
| T4 | ㅇ← · ㆍ↑ · ㅘ | 고와 |
| T5 | ㆍ→ · ㄴ · ㆍ→ | 아나 |
| T6 | ㆍ→ · ㅣ | 아이 |
| T7 | ㅇ · ㆍ→ | 아 |
| T8 | # · ㆍ→ | #아 |
| T9 | 1 · ㆍ→ | 1아 |

### Finals (R1, R4)

| # | Gestures | Result |
|---|---|---|
| T10 | ㅇ↓ (ㅎ) · ㅘ · ㅁ · #← (ㅕ) · ㄴ · ㅣ | 화며니 |
| T11 | ㅇ↓ · ㅘ · ㅁ · #← · ㄴ · ㅇ · ㅣ | 화면이 |
| T12 | ㄴ← (ㄷ) · ㆍ→ · ㄹ · ㅇ← (ㄱ) · ㆍ→ | 달가 |
| T13 | ㆍ→ · ㄴ · ㄹ→ (ㅈ) · ㆍ→ | 안자 |
| T14 | ㅇ← · ㆍ→ · ㄹ · ㅁ | 갊 |
| T15 | ㅇ← · ㆍ→ · ㄴ · ㅇ← | 간ㄱ |
| T16 | ㆍ→ · ㄴ↑ (ㄸ) | 아ㄸ |
| T17 | ㆍ→ · ㄴ↑ · ㆍ→ | 아따 |
| T18 | ㅇ← · ㅇ← | ㄱㄱ |
| T19 | ㄹ← (ㅅ) · ㆍ→ · ㅇ← · ㄹ← (ㅅ) · ㆍ← | 삭서 |

### Repeat (R5)

| # | Gestures | Result |
|---|---|---|
| T20 | ㅁ · ㆍ→ · ㄹ · ㅣ | 마리 |
| T21 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㅣ | 말이 |
| T22 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㅣ · ㅣ | 말이이 |
| T23 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㆍ→ | 마리아 |
| T24 | ㄴ← · ㆍ→ · ㄹ · ㅇ← · ㆍ→ · ㆍ→ | 닭아 |
| T25 | ㅁ · ㆍ→ · ㄹ · ㅘ · ㅘ | 말와 |
| T26 | ㅁ · ㆍ→ · ㄹ · ㆍ→ · ㆍ← | 마라어 |
| T27 | ㆍ→ · ㆍ→ | 아아 |
| T28 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㅣ · ⌫ | 마리 |
| T29 | ㅁ · ㆍ→ · ㄹ · ㅣ · 확정 · ㅣ | 마리\|이 |

### Compounds (R3)

| # | Gestures | Result |
|---|---|---|
| T30 | ㅇ← · ㆍ↑ · ㆍ→ | 과 |
| T31 | ㅇ← · ㅘ | 과 |
| T32 | ㅇ← · ㆍ↑ · ㅣ→ (ㅐ) | 괘 |
| T33 | ㅇ← · ㅘ · ㅣ | 과이 |
| T34 | ㅇ · ㅣ↓ (ㅡ) · ㅣ | 의 |
| T35 | ㅇ · ㅣ↑ (ㅢ) | 의 |
| T36 | ㅁ · ㆍ↓ (ㅜ) · ㆍ← (ㅓ) | 뭐 |
| T37 | ㅁ · ㅘ← (ㅝ) | 뭐 |
| T38 | ㅇ← · ㆍ↓ · ㅣ← (ㅔ) | 궤 |
| T39 | ㆍ↑ · ㆍ↑ | 오오 |

### 확정 (R7)

| # | Gestures | Result |
|---|---|---|
| T40 | ㆍ→ · 확정 | ㅏ\| |
| T41 | ㅇ← · ㆍ→ · ㆍ← · 확정 | 가ㅓ\| |
| T42 | ㆍ↑ · ㆍ→ · 확정 | ㅘ\| |
| T43 | ㅘ · 확정 | ㅘ\| |
| T44 | ㆍ→ · ㄴ · 확정 | 안\| |
| T45 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㅣ · 확정 | 말이\| |
| T46 | ㆍ→ · ㆍ (·) · 확정 | 아·\| |
| T47 | ㆍ→ · ㅣ · 확정 | 아ㅣ\| |
| T48 | ㅇ↓ · ㆍ→ · ㄴ · 확정 · ㆍ→ | 한\|아 |
| T49 | ㅇ↓ · ㆍ→ · ㄴ · 확정 · ㆍ→ · 확정 | 한ㅏ\| |
| T50 | ㅇ · ㆍ→ · 확정 | 아\| |
| T51 | 확정 (empty segment) | (nothing) |

### Commits (R6)

| # | Gestures | Result |
|---|---|---|
| T52 | ㆍ→ · ㄴ · space · ㆍ→ | 안 \|아 |
| T53 | ㅇ← · ㆍ→ · ㄴ · 한A1 · 한A1 · 한A1 · ㆍ→ | 간\|아 |
| T54 | ㅇ← · ㆍ→ · ㄴ · ‹ · › · ㆍ→ | 간\|아 |
| T55 | ㆍ→ · ㄴ · ↵ · ㆍ→ | 안⏎\|아 |
| T56 | ㆍ→ · ㄴ · # · ㆍ→ | 안#아 (one segment) |
| T57 | ㆍ→ · ㄴ · # · ㆍ→ · 확정 | 안#ㅏ\| |

### Backspace and undo (R8, R9)

| # | Gestures | Result |
|---|---|---|
| T58 | ㅇ↓ · ㆍ→ · ㄴ · ⌫ | 하 |
| T59 | ㅇ← · ㆍ↑ · ㆍ→ · ⌫ | 고 |
| T60 | ㅇ← · ㅘ · ⌫ | ㄱ |
| T61 | ㅇ← · ㆍ→ · ㆍ← · ⌫ | 가 |
| T62 | ㆍ→ · ㄴ · 확정 · ⌫ | (the app deletes; 안 is committed, so the IME doesn't reopen it) |
| T63 | ㅁ · ㆍ→ · ㄹ · ㅣ · ↺ | 말 |
| T64 | ㅇ← · ㅘ · ↺ | ㄱ |
| T65 | ㅁ · ㆍ→ · ㄹ · ㅣ · ㅣ · ↺ | 마리 |
| T66 | ㆍ→ · ㄴ · 확정 · ↺ | 안\| (nothing to undo) |
| T67 | ㅇ↓ · ㆍ→ · ㄴ · ⌫ · ↺ | 한 |

### A and 1 layers (R10)

| # | Gestures | Result |
|---|---|---|
| T68 | 한A1 · ⇧ · h · i | Hi |
| T69 | 한A1 · ⇧ · ⇧ · h | h |
| T70 | ㆍ→ · ㄴ · 한A1 · ⇧ · h · i · 한A1 · ! · 한A1 · ㆍ→ | 안Hi!\|아 |

## Where the page differs

Checked against `layout.html`'s code, not yet by running every case:

- **No segment.** The page doesn't keep committed text apart from the segment. So ⌫ after a commit
  reopens the last syllable instead of passing through (T62: the page gives 아), and ↺ can undo a
  commit (T66: the page undoes the 확정).
- **A and 1 type into the same buffer** as Korean. The results match, but ⌫ on A or 1 can reach back
  into Korean text, jamo by jamo.
- **R5 after ⌫:** the page doesn't allow a repeat after the backspace in T28, one of the two
  answers to the [decide] in R5.
