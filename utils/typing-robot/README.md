# typing-robot

A robot that types the way you do, on a virtual copy of a VIA keyboard, for testing whether
another letter layout would actually be easier for you to type on. It's an early, barebones
version: English only (letters, capitals and punctuation), and the GUTS WECAT4 ([layouts/mini-numberless](../../layouts/mini-numberless/)) as
the default board.

```sh
utils/typing-robot/typing-robot interview          # a few questions; writes profiles/profile.json
utils/typing-robot/typing-robot show               # the robot: each key's finger, and your hands
utils/typing-robot/typing-robot type "bird"        # it types on the virtual board, stroke by stroke
utils/typing-robot/typing-robot suggest --export out/   # easier layouts, tested, as VIA files
utils/typing-robot/typing-robot evaluate out/no-interrow.layout.json
python3 -B -m unittest discover -s utils/typing-robot/tests
```

Python 3, standard library only. Nothing is learned or predicted: the robot is your answers plus
the geometry below, so the same answers always give the same robot and the same numbers.

## How it works

1. **The interview** asks:
   - **How big each hand is:** spread it flat on the board and measure from the tip of finger one
     (thumb) to the tip of finger five (pinky), in keys (1 u = 19.05 mm), mm or cm.
   - **Where your fingers rest:** A S D F | J K L, and the key right of L (Enter on the WeCat4).
   - **Which thumb presses Space.** It's recorded, but not used in the scores yet: Space isn't
     typed.
   - **Rounds of "Type the word BIRD. Which finger did you use to type B?"** Answer with a side and
     a number (`L2`, `R5`) or in words (`left index`). The letters touch typists most often type
     differently come first: B, T, G, Y, H, N, V, C, M, Z… `--rounds all` asks about every letter.
2. **The robot.** Each key gets the finger you answered for its letter: the most common answer if
   you were asked more than once, the first one on a tie. The rest get the touch-typing default,
   from your home keys. Fingers belong to physical keys, not to letters, so on a candidate layout
   the robot presses each key with the same finger.
3. **The hands.** Each finger is a chain: **wrist → knuckle → finger midjoint → fingertip**, sized
   from your span. The knuckle turns the finger (sideways up to about 30°) and the midjoint bends it,
   which sets how far it reaches. When a key is out of reach, the wrist moves, carrying the hand.
   Effort is root-weighted: the same movement costs more the closer it is to the root of the chain.

   ```
   effort = 3 × wrist distance + 2 × knuckle turn × segment + 1 × midjoint bend × segment
   ```

   Change the weights with `--wrist`, `--mcp` and `--pip`. The model is a sketch, not
   biomechanics: rough adult finger proportions ([hand.py](typing_robot/hand.py)), seen from above.
4. **Typing.** The robot types each word of the [word list](data/words.txt) from rest, then lets its
   hands go back to rest; the return counts too.

## The scores

Each layout is scored against the baseline (QWERTY, the board's `layout.json`):

| Column | What it is | Better |
|---|---|---|
| effort/char | the root-weighted effort above, per letter typed | lower |
| travel u/char | plain fingertip travel, per letter, in u | lower |
| one-hand % | the share of words, weighted by frequency, typed with one hand only (words of two letters or more) | your call: see below |
| moved % | how much of your typing is on another key, weighted by [letter frequency](data/letters.tsv) | lower: less to relearn |
| finger chg % | the part of moved % that's also on another finger | lower |

One-hand words suit typing with one hand busy (a phone, a mouse) and hurt speed, which comes from
alternating hands, so the score is only reported by default. `--one-hand more` or `--one-hand fewer`
makes `suggest` aim for it.

## Suggesting layouts

`suggest` starts from QWERTY and keeps making the letter swap that lowers the objective most, until
no swap helps:

```
objective = effort / QWERTY's effort + 0.25 × moved fraction (± one-hand fraction)
```

`--change-weight` sets the 0.25: how much effort a full relearn has to save to be worth it. The
search is greedy, so its layout is good, not necessarily the best. The presets, all run by default
(`--constraint` picks some; `--fix zxcv` adds letters that mustn't move):

| Preset | Constraint |
|---|---|
| `no-interrow` | every letter stays on its row |
| `no-interrow-keep-zxcv` | the same, and Z X C V (undo, cut, copy, paste) stay put |
| `same-hand` | every letter stays on its hand |
| `max-4-moved` | at most four letters move, anywhere |
| `free` | none |

Then it tests each suggestion by having the robot type the word list on it, and prints the scores
next to QWERTY, with each one's change in effort and travel. `--export DIR` writes each as a VIA
saved layout, which VIA's **Load saved layout** reads.

The macOS input source still has to be QWERTY (US, or JIS for the layouts in
[layouts/](../../layouts/README.md)): the layout changes which keycode each key sends, in the
firmware.

## Boards

A board is a folder with two VIA files:

- **`definition.json`:** VIA's keyboard definition: `matrix` and `layouts.keymap` in KLE format, each
  key labelled with its matrix position `"row,col"`. Rotated keys aren't supported.
- **`layout.json`:** a VIA saved layout ("Save layout" in VIA), the baseline keymap. Layer 0 is
  read.

Another board: `--board path/to/folder`. Another baseline: `--keymap file.json`.

[boards/gats-wecat4](boards/gats-wecat4/) is the WECAT4:

- **The matrix (4 × 12)** is from the firmware in
  [dogakey/wecat4-vial](https://github.com/dogakey/wecat4-vial) (`keymaps/vial/keymap.c`).
- **The key widths** are measured from MONSTARGEAR's product photo, as in
  [layouts/mini-numberless](../../layouts/mini-numberless/): bottom row 1.25 · 1 · 1.25 · 2.25 ·
  1 · 2.75 · 1.25 · 1 · 1.25. The Vial definition has Win at 1.25 and the right Space at 2.5, which
  doesn't match the photo.
- **The baseline keymap** is the board's own, all four layers, exported over VIA on 2026-11-04
  (the same file as [configfiles/monstargear-pebble-mini](../../configfiles/monstargear-pebble-mini/README.md)):
  Control left of A, and Fn1 (`MO(1)`), ⌥, ⌘, Space, Fn1 (`MO(1)`), Space, ⌘, ⌥, Fn2 (`MO(2)`)
  along the bottom, and - ^ ¥ on Fn + Z, X and C (set later the same day, so newer than the
  configfiles copy). Exports keep layers 1–3 as they are, so loading one doesn't touch the Fn
  layers.
- **The IDs** are `0x342D:0xE47E`, from the same repository; check them against the board before
  loading a layout in VIA.

## Chords

With the board's other layers loaded (the CLI loads every layer of the baseline), each character is
typed the way you'd type it on macOS with the keyboard stored as JIS
([typing_robot/chords.py](typing_robot/chords.py)): capitals and shifted symbols with Shift, and
characters on an Fn layer with that layer's Fn key, plus Shift where needed. `'` is Fn1 + Shift + U
(Shift + 7 on JIS, and 7 is Fn1 + U); `;` and `:` are Fn1 + M and Fn1 + `,` (`KC_QUOT` types `:` on
JIS). Each character gets the chord that costs the robot least: either Shift, any Fn key for its
layer. A held modifier keeps its finger on its key until that finger is needed again.

Characters on the Fn layers stay on their physical keys whatever the base layer is rearranged to:
with `.` moved, Fn + the old `.` key still types ろ. Only base-layer characters move, and their
Shift forms with them.

## Data

- [data/letters.tsv](data/letters.tsv): English letter frequencies, the commonly cited table
  (Lewand, 2000).
- [data/words.txt](data/words.txt): about 500 common English words, roughly most frequent first
  (the first half of Edward Fry's "1000 Instant Words"), weighted 1/rank. They're a starter list,
  not a measured corpus. `--words` takes your own, one word per line, or `word<TAB>count`. Case is
  kept, so capitals cost a Shift; a word with a character the board can't type is left out.
  `--letters` takes your own frequency table, which can include punctuation.

Your profile (`profiles/*.json`) is ignored by git.

## Limits

- **English only, on a JIS Mac.** Korean and Kana aren't typed yet, and the chords assume macOS
  with the keyboard stored as JIS.
- **Same-finger repeats aren't scored.** Two keys in a row with one finger only cost their travel,
  so a search can stack common letters on one finger (E and T both on the right index, for one).
  Check same-finger bigrams separately before trusting a suggestion.
- **One finger per key**, whatever the word. If you type a letter with different fingers in
  different words, the robot uses the most common answer.
- **A word at a time, from rest.** Rolls and same-finger repeats only count through travel and
  effort; there's no timing.
