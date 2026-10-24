# Mobile layout principles

The [layout principles](../layouts/PRINCIPLES.md), idempotency and conservation, apply here too.
These are what they mean on a phone, plus what a touch keyboard adds. Like those, they're
guidelines, not strict rules.

## 1. One gesture, one result

A tap or a flick types the same thing every time, whatever came before it. Multi-tap breaks this:
ㄱ tapped twice is ㅋ, unless the typist meant 각, and the keyboard can only guess from a timeout
or a separate key. That's idempotency's exception 2 (existing convention) for 천지인 and 나랏글
typists, so they're here as references, but a new candidate shouldn't rely on it.

A **cycle key** (획·쌍, like the kana keyboard's ゛゜小) changes what the last gesture typed instead
of typing something itself. It's the one toggle a candidate may have: its effect is on screen
before the next key, which is exception 3.

## 2. Conservation

- **The frame stays the same.** ↺ ‹ 한A1 🌐 on the left, ⌫ › space ↵ on the right, as in Gboard's
  12-key, so moving between candidates (or to the Japanese keyboard) only changes the center.
- **Composition is standard.** ㅗ then ㅏ is ㅘ, ㄱ then ㅅ as a final is ㄳ, on every candidate,
  even where a dedicated key or flick exists. A dedicated key is a shortcut, not the only way.

## 3. Composition: JIS Korean's deterministic engine

Every candidate, the references included, composes with
[JIS Korean](https://github.com/team-mirae/jis-korean)'s deterministic engine (its spec §4.1–4.2),
the lite engine with no prediction. **Learning and prediction are out of scope while planning.**

- **Implied ㅇ.** A vowel with no initial starts a syllable on an implied ㅇ: ㅏ → 아, 가 + ㅓ →
  가어, 아 + ㅣ → 아이. Vowels still combine: ㅗ + ㅏ → 와.
- **A vowel after a final takes it**, with nothing guessed: 화면 + ㅣ → 화며니, never 화면이. To keep
  the final, type ㅇ (화면 ㅇ ㅣ → 화면이), or repeat the vowel flick right away (화며니 → 화면이, once;
  backspace gives 화며니 back). The repeat is for flicks; multi-tap keys repeat to cycle.
- **A compound vowel from one gesture combines with nothing**: 고 + ㅘ (one flick) → 고와, where 고 +
  ㅏ → 과.
- **확정** (JIS Korean's F6) commits, and drops an implied ㅇ while its syllable has no final: ㅏ 확정
  → ㅏ, 가어 확정 → 가ㅓ, 와 확정 → ㅘ, 안 확정 → 안. A ㅇ asked for with a repeat stays (말이 확정 →
  말이). A candidate with a spare key puts 확정 there.

## 4. Direction means something

Where a flick goes should follow one rule across the keyboard, so it can be learned once: a vowel
goes where its dot points (ㅓ ←, ㅗ ↑, ㅏ →, ㅜ ↓), and each candidate fixes one rule for where a
doubled or aspirated consonant sits relative to its plain one.
