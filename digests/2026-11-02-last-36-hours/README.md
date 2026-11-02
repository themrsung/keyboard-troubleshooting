# Digest: keyboard repositories, 2026-10-31 22:08 → 2026-11-02 10:08 (UTC+9)

Every commit made in the 36 hours before 2026-11-02 10:08 (UTC+9) in the keyboard-related
repositories, with what each found and how it was solved. Collected from `git log --all` in local
clones, after a fetch, and from GitHub (`gh repo list` by push date) for
[themrsung](https://github.com/themrsung) and [team-mirae](https://github.com/team-mirae).

**About hardware.** This digest only repeats what the commits and their notes record. Where a commit
doesn't say which keyboard, computer or device something was measured on, it says **"not
recorded"**. None of the commits below name the physical keyboard used for a measurement. The
tester's hardware list is in [testers/themrsung](../../testers/themrsung.md), but which of those
devices was used is not stated, so it isn't guessed here.

## Key names

| Legend | Canonical name |
| --- | --- |
| 英数 | `KeyJISMacEnglish` |
| かな | `KeyJISMacKana` |
| 無変換 / 変換 | `KeyJISMuhenkan` / `KeyJISHenkan` |
| 半角/全角, `` ` `` | `KeyHankakuZenkaku` |
| `:` / `;` (JIS) | `KeyKe` / `KeyRe` |
| O / P | `KeyO` / `KeyP` |
| Shift | `KeyUniversalShift` |

## Repositories

| Repository | Commits | Note |
| --- | --- | --- |
| [team-mirae/jis-moonshot](https://github.com/team-mirae/jis-moonshot) | 36 (+2 inherited from jis-korean) | New fork, created in this window |
| [team-mirae/jis-korean](https://github.com/team-mirae/jis-korean) | 12 | Ports from jis-moonshot; v0.4.0 |
| [team-mirae/uim-mobile](https://github.com/team-mirae/uim-mobile) | 2 | New repository |
| [themrsung/keyboard-troubleshooting](https://github.com/themrsung/keyboard-troubleshooting) | 2 | This repository |
| [themrsung/fkeyime](https://github.com/themrsung/fkeyime) | 1 | Marked abandoned |

Looked at and found with no commits in the window: magic-keyboard, type-like-me, flick-korean,
hhkb-ekj-trilingual, hhkb-us-bilingual, ime-switcher-minecraft, jis-practice. Not counted: the
`themrsung/themrsung` profile repository (one commit, `qwer`, not about keyboards).

## Troubleshooting findings

These are the bugs and platform behaviours found, with their fixes.

### macOS: input method selectable but types nothing (unsigned bundle)

- **Where:** jis-moonshot
  [`b9d804e`](https://github.com/team-mirae/jis-moonshot/commit/b9d804ebd169079bfd9a31ec652f9de00f207be6)
  (`docs/troubleshooting/macos-unsigned-bundle.md`), ported to jis-korean in
  [`7f5ccfc`](https://github.com/team-mirae/jis-korean/commit/7f5ccfc9480f449fe6dc4824a557da9e35df29e5).
- **Symptom:** JIS Moonshot shows up in the input menu and can be selected, but types nothing in
  any mode or app. The predictive-typing consent alert never appears.
- **Evidence:** `imklaunchagent` logs `Refusing connection name for bundle: unrecognized
  'InputMethodConnectionName' value` for every app. `codesign -dv` shows `Signature=adhoc` with the
  executable's name as identifier, and `codesign --verify --deep --strict` fails.
- **Cause:** the bundle wasn't sealed, so `imklaunchagent` refused it. This is inferred: signing
  correctly fixed it with nothing else changed. **Why** the build came out unsigned is still open.
- **Fix:** `touch Info.plist && make`, verify with `codesign --verify --deep --strict`, then
  `make install`, remove and re-add the input source. In jis-korean, `make` now deletes the bundle
  when `codesign` fails, and `make install` refuses a bundle that doesn't verify. An ad-hoc sealed
  bundle (`SIGN_IDENTITY=-`) still passes.
- **Platform:** macOS 27.0 (Darwin 27.0.0). **Mac model and keyboard: not recorded.**

### Windows: sandboxed apps couldn't read the input method's settings

- **Where:** jis-moonshot
  [`13b4d1e`](https://github.com/team-mirae/jis-moonshot/commit/13b4d1e0437bebb2bfd9268e762b88e53e4134ec),
  ported to jis-korean in
  [`adbf40d`](https://github.com/team-mirae/jis-korean/commit/adbf40dd44d97f56799e49da1c8c526c9da5bc52).
- **Symptom:** AppContainer programs (the Start menu's search, Store apps) asked for
  predictive-typing consent every time, and ran on the default settings.
- **Cause:** `HKCU\Software` grants ALL APPLICATION PACKAGES read access but doesn't pass it on to
  child keys, so the TIP's own key (created by its first write) had no such grant.
- **Fix:** `settings.cpp` adds the read grant once per process, but only when the DACL lacks it, so
  keys made by earlier builds are fixed too.
- **Platform:** measured in jis-moonshot with `reg.exe` in an AppContainer (unreadable before,
  readable after). Windows version and PC: not recorded in this commit. The jis-korean port says
  it was **not built or measured** (it was written on macOS).

### Windows: classic controls show only an open composition's first character

- **Where:** jis-moonshot
  [`afc8ce8`](https://github.com/team-mirae/jis-moonshot/commit/afc8ce8479b7405bae86103ba207f114207179eb),
  documented in jis-korean in
  [`0e44ce9`](https://github.com/team-mirae/jis-korean/commit/0e44ce9cdd1d2deb513a034cbb2d9c9da2acce44).
- **Finding:** through the IMM compatibility layer, a Korean interim character reaches the control
  as a single character (`WM_IME_COMPOSITION`, `CS_INSERTCHAR`). So Edit and RichEdit controls
  show き for きのと, h for hello and 한 for 한하 until the text commits. The committed text is
  whole. TSF-native controls show all of it. The Microsoft Korean IME never shows more than one
  syllable, so it never runs into this.
- **Solution:** documented as a limit. Fixing it would take a candidate window of the shell's own.
  The typing tests now commit before checking, so every control is checked against the same text.
- **Platform:** Windows 11, `jk_testpad` (`edit`, `rich`, `tsf` targets). **PC and keyboard: not
  recorded.** Not re-measured in jis-korean.

### Windows: password fields typed US ANSI symbols on a JIS keyboard

- **Where:** jis-moonshot
  [`2da869d`](https://github.com/team-mirae/jis-moonshot/commit/2da869d9a465a3a46b1618d609f1e1860472053d).
- **Symptom:** in a password field, or in a program where JIS Moonshot is turned off, keys passed
  through to Windows' Korean layout, which has US ANSI symbols (Shift+2 → `@`).
- **Fix:** those keys now type ABC's layout from the engine's table (JIS English by default),
  composing nothing.
- **Still open:** in password boxes that Windows keeps every TIP out of, Windows' Korean layout
  still types. Nothing moved Korean input methods off that layout. Tried: TSF's substitute layout,
  `Keyboard Layout\Substitutes`, and adding a JIS layout to Korean's keyboards.
- **Platform: not recorded** (Windows version, PC and keyboard).

### Windows: Shift+F8 hanja list never opened with predictions off

- **Where:** jis-moonshot
  [`c0e8bb9`](https://github.com/team-mirae/jis-moonshot/commit/c0e8bb9690e4c7a621f2a08c7300f6f51ce7d069).
- **Cause:** the hanja list had moved from F7 to Shift+F8, but the shell still loaded the
  dictionary at the first F7.
- **Fix:** Shift+F8 loads it. Measured with `tools/type-test.ps1` on Windows 11, in all three
  controls. **PC and keyboard: not recorded.**
- **Note:** superseded a few minutes later. Hanja were removed entirely in
  [`cea280f`](https://github.com/team-mirae/jis-moonshot/commit/cea280f61bb7356b86649303a45bca337fbdde8b),
  and Shift+F8 is now the same as F8.

### Windows development: CRLF checkouts and tools that need a Unix shell

- **Where:** jis-moonshot
  [`2be48a7`](https://github.com/team-mirae/jis-moonshot/commit/2be48a7a537103b3df0e8267bdbfc4501d9485e6),
  ported to jis-korean in
  [`d6b361f`](https://github.com/team-mirae/jis-korean/commit/d6b361f6e0f2101f7ff9a6ca3d08cf94b1115767).
- **Symptom:** with `core.autocrlf`, data files, test corpora and sample texts were checked out as
  CRLF. The playground's ghost text stopped matching after the first line break, and its key counts
  included the `\r`. Also, `npm run wasm` used `cp` / `mkdir -p`, which cmd.exe doesn't have.
  `train_learned.py` assumed a Unix venv layout and that `os.execv` replaces the process.
- **Fix:** `.gitattributes` forces LF. Files are copied by a Node script. The training script
  handles `Scripts\python.exe`, `cargo.exe` and the way `execv` behaves on Windows.
- **Platform: Windows, version and PC not recorded.**

### CI: CodeQL's Swift job failed on every run since the fork

- **Where:** jis-moonshot
  [`a9e9457`](https://github.com/team-mirae/jis-moonshot/commit/a9e94570285b6287515fbc40b35fea11afe76e3f).
- **Cause:** `Package.swift` linked `build/full-english/`, a build variant the fork's Makefile no
  longer produces.
- **Fix:** link `build/full`. CI only, no hardware involved.

### Build: an example failed without the `predict` feature

- **Where:** jis-moonshot
  [`f46bc95`](https://github.com/team-mirae/jis-moonshot/commit/f46bc956e6aa8996f04e17db447e94e9ae35fdb9).
- **Fix:** the `first_key` example is gated on `predict`, so `cargo test --no-default-features`
  compiles again.

### JIS Kana: committing a prediction in katakana changed its hiragana

- **Where:** jis-moonshot
  [`59e56c4`](https://github.com/team-mirae/jis-moonshot/commit/59e56c4b2eded919ad3b1d21b8db61adffdf3e4c).
- **Symptom:** 私は committed as 私ハ in JIS Kana's katakana script. **Fix:** only the reading
  is converted, not the hiragana of a committed prediction.

### macOS: 英数 and かな run your own code, without Karabiner

- **Where:** this repository,
  [`a6fd3da`](https://github.com/themrsung/keyboard-troubleshooting/commit/a6fd3da)
  ([eisu-kana-keys-run-your-own-code](../../macos-input-method/eisu-kana-keys-run-your-own-code/README.md)).
  It's built into jis-moonshot's first commit,
  [`abd2e56`](https://github.com/team-mirae/jis-moonshot/commit/abd2e5658a03ef88bcae76ef305e0f627108d8c9)
  (the かな proxy input mode).
- **Finding:** 英数 (`KeyJISMacEnglish`) selects the primary Roman-script input source, and かな
  (`KeyJISMacKana`) selects the primary Japanese-script one. かな does nothing while a
  Japanese-script source is already selected. Make your input method's modes the primary sources,
  remove ABC (after adding ABC – Extended) and every other Japanese IME, and the activation
  callback receives both keys. No event tap and no permissions are needed.
- **Platform:** macOS 27, Apple Silicon. **Which keyboard and which Mac: not recorded** (the
  tester has several boards with 英数 / かな).
- **Open:** whether the proxy source flashes in the menu bar, and whether Ctrl+Space lands on it.

## Features and design changes

### jis-moonshot (new: Korean + English + Japanese kana on one JIS keyboard)

- **Fork**
  ([`abd2e56`](https://github.com/team-mirae/jis-moonshot/commit/abd2e5658a03ef88bcae76ef305e0f627108d8c9)):
  JIS keyboards only. Every key is read as Korean 2-set, English and JIS kana at once, and the
  predictions pick a reading. F6 and F7 switch to hiragana or katakana until the commit, and かな
  forces Korean. The Windows port is unbuilt. Minecraft is dropped. Released as v0.3.1, which
  includes [`b886240`](https://github.com/team-mirae/jis-moonshot/commit/b886240)
  (the F6 shell test now expects F6 to last until the commit).
- **Kanji predictions from Mozc's dictionary**
  ([`59e56c4`](https://github.com/team-mirae/jis-moonshot/commit/59e56c4b2eded919ad3b1d21b8db61adffdf3e4c)):
  word lattice plus POS bigram. 70% exact on Mozc's evaluation set, 79% in the top 3. F8 shows the
  conversions. Japanese readings are drawn in Japanese fonts, so kanji take their Japanese forms.
- **⌥ full-width and Japanese punctuation on macOS**
  ([`0d17725`](https://github.com/team-mirae/jis-moonshot/commit/0d177250ba5ee15724e634a9d9f0f56cb12780c3),
  [`9da6db5`](https://github.com/team-mirae/jis-moonshot/commit/9da6db542a83609b0dc9e23874c39f015ff6dcda)):
  ⌥ plus a digit or symbol types it full-width. ⌥ `, . / [ ]` type `、。・「」`. In Mode A,
  `⌥[` and `⌥]` type `『』`, and `« »` in the English modes.
- **Mode A without symbols**
  ([`8cf3cf1`](https://github.com/team-mirae/jis-moonshot/commit/8cf3cf1) planned,
  [`a79c3ec`](https://github.com/team-mirae/jis-moonshot/commit/a79c3ec74d8333cb028f8e123e0894f07d1bbec0)
  built): the 12 keys right of 0 type short runs of 2-set jamo instead of symbols, using ゛ (a real
  ㅇ) and ゜ (a syllable break). Shift+Q W E R T type plain consonants (the doubles moved to 1–5),
  and ㅒ ㅖ are on `:` (`KeyKe`) and `;` (`KeyRe`). This deliberately breaks standard 2-set, and the
  spec's core principle was rewritten to allow it. `learned.bin` was not retrained (the corpora
  weren't at hand).
- **Shift+O / Shift+P start a syllable on ㅇ, and `` ` `` / `~` restored**
  ([`c848a86`](https://github.com/team-mirae/jis-moonshot/commit/c848a86f68a7497dd9ead74664ecf75a80f7e56d)):
  Shift on every vowel key, `KeyO` and `KeyP` included, is Shift+vowel (간 ⇧ㅔ → 간에).
  `KeyHankakuZenkaku` types `` ` `` and `~` in every mode. The commit calls it "the HHKB's `` ` ``
  key; 半角/全角 on a full JIS board". It names keyboard types, not a measured unit. A particle
  typed right after an English word now gets the particle bonus. Version bumped to v0.4.0
  ([`8583c95`](https://github.com/team-mirae/jis-moonshot/commit/8583c95)). The shell tests follow
  the new keys
  ([`da6de62`](https://github.com/team-mirae/jis-moonshot/commit/da6de62)).
- **ㄶ read by sound**
  ([`b746119`](https://github.com/team-mirae/jis-moonshot/commit/b746119d987cabc071fa3b1f04b2470280250f13)):
  after a ㄴ final, ㅋ ㅌ ㅊ can also read as ㄶ plus ㄱ ㄷ ㅈ, so 안코 → 않고 and 만타 → 많다. This
  reading ranks above the literal one only when it's a known word.
- **Hanja removed; common Mozc words count as Japanese**
  ([`cea280f`](https://github.com/team-mirae/jis-moonshot/commit/cea280f61bb7356b86649303a45bca337fbdde8b)):
  the dictionary, the list and the API are gone. This was the owner's call, and the losses were
  accepted. A Mozc word with 3 or more kana and cost ≤ 4500 counts as known Japanese, so どようび
  reads as kana with 土曜日 listed.
- **Order-4 three-language key model for the kana reading**
  ([`2b5217d`](https://github.com/team-mirae/jis-moonshot/commit/2b5217d4d2097e1b80878fb385ba9782d5328286)):
  Witten-Bell n-grams over the 48 JIS keys for Korean, English and kana (about 5 MB, format JKR3).
  Accuracy on held-out text is 99.5%, 99.5% and 99.0%. Orders 3–7 were tried; higher orders only
  helped on trained words and cost 4–17× the entries. どようび, こんにちは and ありがとう now come
  first, and 한글, 안녕 and hello stay on top. Korean vs English still uses the older tables:
  the legacy ranker lost owner-text words with the new model.
- **Research notes (not used by the engine):**
  [first-key prior](https://github.com/team-mirae/jis-moonshot/commit/9ab0b64774a9b6f177d833ad3b013aac5e1bc60d):
  the first key press carries 0.34 of 1.58 bits about the language, so the note recommends folding
  it into a kana key model.
  [Typing speed as a sign of lazy typing](https://github.com/team-mirae/jis-moonshot/commit/e212fc58e138ab8c76c7300674c386eb84240764):
  not worth timing yet. Published studies find speed tracks skill, not carelessness, and the repo
  has no keystroke timing data.
- **Smaller changes:** the Windows indicator shows 한あ in Mode A
  ([`624c1ed`](https://github.com/team-mirae/jis-moonshot/commit/624c1ed9f3e6acb0e0bce22f5b83b57bc88ec455)).
  The each-jamo route types doubles and ㅒ ㅖ on the new keys
  ([`ac78661`](https://github.com/team-mirae/jis-moonshot/commit/ac78661231a56fd2cc35ef7ff1b191e813ffce2f)).
  The layout drawing was redrawn for Mode A plus kana with romaji, and the hanja note dropped
  (`f040d50`, `90feea5`, `143605d`, `89f5ef3`, `cb31517`, `50a542f`). A CI step name with a colon
  is now quoted (`cdfd822`). The rest are merges.

### jis-korean

- **Docs matched to the code**
  ([`61a9af8`](https://github.com/team-mirae/jis-korean/commit/61a9af8f323779405ca9ca614c3995ba95039d0d),
  PR #26): one release per version for all platforms, F8 retired, the legacy-predict build, web
  toolchain versions, and the macOS and Windows troubleshooting notes. Also inherited by
  jis-moonshot.
- **Ported from jis-moonshot, released as v0.4.0** (PR #27): the four fixes above (unsigned bundle,
  sandboxed settings, classic-control display, LF checkouts), ㄶ by sound
  ([`c7d6bdf`](https://github.com/team-mirae/jis-korean/commit/c7d6bdfa338dfffde1e90b022a65226bb5d5308d))
  with a type test (`bef0f8f`), and the particle bonus after English words
  ([`b72fc51`](https://github.com/team-mirae/jis-korean/commit/b72fc51174e3010703aa9e2657a99c0690917a01)).
  The particle bonus made no measured difference on the corpora, and it only guards close calls.
  Moonshot's lone Shift+vowel half was not ported: in JIS Korean it would turn ⇧L into 이 beside
  Latin text, where L is more likely a letter.
- **macOS dev VM**
  ([`319a124`](https://github.com/team-mirae/jis-korean/commit/319a1247282a0011f6a3e78b0118c5eddea6010c),
  branch `mac/dev-vm`, **not merged**): `mac/vm/jisvm` runs a digest-pinned macOS 27 Tart guest,
  installs builds into it, and drives its keyboard, mouse and screen over Virtualization.framework's
  VNC. Finding: vncdotool's `type` drops Shift there, so `jisvm type` holds Shift explicitly. The
  hardware here is a **virtual machine** with VNC keyboard input, not a physical keyboard.

### uim-mobile (new: trilingual touch keyboard for Android)

- [`16848ff`](https://github.com/team-mirae/uim-mobile/commit/16848ff83f142edcad442e083ea01dce706a5239),
  `f93e4bc`: a Rust engine with a C ABI and a thin Android shell. English uses QWERTY or a 20-key
  predictive layout. Korean uses an 8 × 4 flick grid on narrow screens and JIS Korean Mode A on wide
  ones. Japanese uses Gboard-style flick kana or JIS kana, with kana-kanji conversion over Mozc's
  dictionary. Design rule: bigger targets come from removing keys, and predictions never rewrite
  what was typed. MIT licence and README added.
- **Device: not recorded.** The commits mention phones, foldables and tablets as target form
  factors only. No measurement on a specific device is reported.

### fkeyime

- [`766c8e0`](https://github.com/themrsung/fkeyime/commit/766c8e0): marked abandoned. The
  successor is team-mirae/jis-moonshot.
