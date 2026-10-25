# Keynames

- Current version: **VERSION REV1-20261025**
- Legacy versions: None (this is the first)

The name of keys. What they are referred to. Mainly for AI AGENTS, humans can read if you want to.

This repository is JIS-centric, HHKB JIS-centric, and labels keys based on the HHKB JIS layout. For example, LControl is in the A-Row.

Where legends collide between layouts, rather than using one which would favor another, the Japanese Kana position is used as its canonical name.

For layout-specific names such as `Colon` or `Control`, prepend prefix of the layout.

- `US` for US ANSI.
- `Japanese` for JIS, in the context of Japanese Kana labels.
- `JIS` for JIS, in the context of symbol mapping.
- `JISK` for JIS Korean, in the context of reserved keys for JIS Korean.
- `WIN` for Windows-specific labels.
- `ISO` for ISO, in the context of key shapes.
- `UK`, `ES`, `CH`, etc. in the context of locale-specific ISO key labels.

Please use only alphabets (A-Z, a-z) for the canonical labels, in camel case, starting with the prefix `Key`.

## Reading the tables

- **Legends** are the key's unshifted legend. **Legend on JIS Korean** is
  [JIS Korean](https://github.com/team-mirae/jis-korean)'s Mode A, as drawn in
  [hhkb-jis-golden](../../../layouts/hhkb-jis-golden/README.md). N/A means the layout has no such
  key, or the key has no legend (layer keys).
- **Keycode** is the QMK keycode. N/A means the key never reaches the computer as a keycode (the
  HHKB's Fn, see [fn-layer-is-firmware-only](../../../hhkb/fn-layer-is-firmware-only/README.md)).
- A key can be in more than one table: `KeyMu` is both a JIS key and an A-Row key.
- The same data, with each key's HID usage and the browser's `KeyboardEvent.code` added, is in
  [keynames.js](keynames.js), [keynames.ts](keynames.ts) and [Keynames.java](Keynames.java). Each has
  `resolve(name)`, which takes a canonical name or an alias from [Aliases](#aliases).

## Alphabetical

Also called:
- QWERTY area
- QWERTY zone
- Letter area
- ASDF...HJKL area
- QWER...VBNM area
- Letter keys
- Roman keys
- Romaji keys
- Latin keys

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyQ` | Q | ㅂ | ㅂ | た | `KC_Q` |  |
| `KeyW` | W | ㅈ | ㅈ | て | `KC_W` |  |
| `KeyE` | E | ㄷ | ㄷ | い | `KC_E` |  |
| `KeyR` | R | ㄱ | ㄱ | す | `KC_R` |  |
| `KeyT` | T | ㅅ | ㅅ | か | `KC_T` |  |
| `KeyY` | Y | ㅛ | ㅛ | ん | `KC_Y` |  |
| `KeyU` | U | ㅕ | ㅕ | な | `KC_U` |  |
| `KeyI` | I | ㅑ | ㅑ | に | `KC_I` |  |
| `KeyO` | O | ㅐ | ㅐ | ら | `KC_O` |  |
| `KeyP` | P | ㅔ | ㅔ | せ | `KC_P` |  |
| `KeyA` | A | ㅁ | ㅁ | ち | `KC_A` |  |
| `KeyS` | S | ㄴ | ㄴ | と | `KC_S` |  |
| `KeyD` | D | ㅇ | ㅇ | し | `KC_D` |  |
| `KeyF` | F | ㄹ | ㄹ | は | `KC_F` |  |
| `KeyG` | G | ㅎ | ㅎ | き | `KC_G` |  |
| `KeyH` | H | ㅗ | ㅗ | く | `KC_H` |  |
| `KeyJ` | J | ㅓ | ㅓ | ま | `KC_J` |  |
| `KeyK` | K | ㅏ | ㅏ | の | `KC_K` |  |
| `KeyL` | L | ㅣ | ㅣ | り | `KC_L` |  |
| `KeyZ` | Z | ㅋ | ㅋ | つ | `KC_Z` |  |
| `KeyX` | X | ㅌ | ㅌ | さ | `KC_X` |  |
| `KeyC` | C | ㅊ | ㅊ | そ | `KC_C` |  |
| `KeyV` | V | ㅍ | ㅍ | ひ | `KC_V` |  |
| `KeyB` | B | ㅠ | ㅠ | こ | `KC_B` |  |
| `KeyN` | N | ㅜ | ㅜ | み | `KC_N` |  |
| `KeyM` | M | ㅡ | ㅡ | も | `KC_M` |  |

## Numerical

Also called:
- Numbers
- 1234567890
- Numerals

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyOne` | 1 | 1 | ㅃ | ぬ | `KC_1` | Digit1, One |
| `KeyTwo` | 2 | 2 | ㅉ | ふ | `KC_2` | Digit2, Two |
| `KeyThree` | 3 | 3 | ㄸ | あ | `KC_3` | Digit3, Three |
| `KeyFour` | 4 | 4 | ㄲ | う | `KC_4` | Digit4, Four |
| `KeyFive` | 5 | 5 | ㅆ | え | `KC_5` | Digit5, Five |
| `KeySix` | 6 | 6 | ㅟ | お | `KC_6` | Digit6, Six |
| `KeySeven` | 7 | 7 | ㅝ | や | `KC_7` | Digit7, Seven |
| `KeyEight` | 8 | 8 | ㅚ | ゆ | `KC_8` | Digit8, Eight |
| `KeyNine` | 9 | 9 | ㅢ | よ | `KC_9` | Digit9, Nine |
| `KeyZero` | 0 | 0 | ㅘ | わ | `KC_0` | Digit0, Zero |

## JIS Keys

Also called:
- Japanese Keys

Keys a US ANSI board doesn't have, or that JIS names differently. `KeyJISMuhenkan`'s and `KeyJISHenkan`'s
positions are the Windows JIS ones (either side of Space); macOS drops both
([japanese-keycodes-on-macos](../../../qmk/japanese-keycodes-on-macos/README.md)).

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyLongKatakana` | N/A | N/A | — | ー | `KC_INT3` | Yen, ¥, JapaneseBackslash, JIS Yen, International3, KC\_JYEN |
| `KeyMu` | \\ | ₩ | \] | む | `KC_NUHS` (or `KC_BSLS`) | JapaneseMu, Mu, JIS ClosingSquareBracket, US Backslash, Won, UK Hash, Non-US Hash |
| `KeyRo` | N/A | N/A | \\ | ろ | `KC_INT1` | JapaneseRo, Ro, JIS Backslash, Underscore (on Mac), International1 |
| `KeyJISKLangKorean` | N/A | N/A | カタカナ | 半角/全角 | `KC_INT2` | PC Katakana, LangKorean, LangKo, Windows JIS カタカナ/ひらがな, HHKB JIS 半/全 position, International2, KC\_KANA |
| `KeyJISMacEnglish` | 英数 | 英数 | 英数 | 英数 | `KC_LNG2` | Eisuu, MacRomaji, LangEn, Lang2, KC\_HANJ (named for Korean 한자) |
| `KeyJISMacKana` | かな | かな | かな | かな | `KC_LNG1` | Kana, LangJa, Lang1, KC\_HAEN (named for Korean 한/영) |
| `KeyJISMuhenkan` | 無変換 | 無変換 | 無変換 | 無変換 | `KC_INT5` | Muhenkan, NonConvert, International5 |
| `KeyJISHenkan` | 変換 | 変換 | 変換 | 変換 | `KC_INT4` | Henkan, Convert, International4 |

## Function Row

Also called:
- F-Row
- F-Keys
- FKeys

On the HHKB, Esc is in the Number Row, left of `KeyOne`, and F1–F12 are on the Fn layer. F13–F24
are on few keyboards, but QMK and macOS know them.

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyEscape` | Esc | Esc | Esc | Esc | `KC_ESC` | Escape |
| `KeyFunctionOne` | F1 | F1 | F1 | F1 | `KC_F1` | F1 |
| `KeyFunctionTwo` | F2 | F2 | F2 | F2 | `KC_F2` | F2 |
| `KeyFunctionThree` | F3 | F3 | F3 | F3 | `KC_F3` | F3 |
| `KeyFunctionFour` | F4 | F4 | F4 | F4 | `KC_F4` | F4 |
| `KeyFunctionFive` | F5 | F5 | F5 | F5 | `KC_F5` | F5 |
| `KeyFunctionSix` | F6 | F6 | F6 | F6 | `KC_F6` | F6 |
| `KeyFunctionSeven` | F7 | F7 | F7 | F7 | `KC_F7` | F7 |
| `KeyFunctionEight` | F8 | F8 | F8 | F8 | `KC_F8` | F8 |
| `KeyFunctionNine` | F9 | F9 | F9 | F9 | `KC_F9` | F9 |
| `KeyFunctionTen` | F10 | F10 | F10 | F10 | `KC_F10` | F10 |
| `KeyFunctionEleven` | F11 | F11 | F11 | F11 | `KC_F11` | F11 |
| `KeyFunctionTwelve` | F12 | F12 | F12 | F12 | `KC_F12` | F12 |
| `KeyFunctionThirteen` | F13 | F13 | F13 | F13 | `KC_F13` | F13 |
| `KeyFunctionFourteen` | F14 | F14 | F14 | F14 | `KC_F14` | F14 |
| `KeyFunctionFifteen` | F15 | F15 | F15 | F15 | `KC_F15` | F15 |
| `KeyFunctionSixteen` | F16 | F16 | F16 | F16 | `KC_F16` | F16 |
| `KeyFunctionSeventeen` | F17 | F17 | F17 | F17 | `KC_F17` | F17 |
| `KeyFunctionEighteen` | F18 | F18 | F18 | F18 | `KC_F18` | F18 |
| `KeyFunctionNineteen` | F19 | F19 | F19 | F19 | `KC_F19` | F19 |
| `KeyFunctionTwenty` | F20 | F20 | F20 | F20 | `KC_F20` | F20 |
| `KeyFunctionTwentyOne` | F21 | F21 | F21 | F21 | `KC_F21` | F21 |
| `KeyFunctionTwentyTwo` | F22 | F22 | F22 | F22 | `KC_F22` | F22 |
| `KeyFunctionTwentyThree` | F23 | F23 | F23 | F23 | `KC_F23` | F23 |
| `KeyFunctionTwentyFour` | F24 | F24 | F24 | F24 | `KC_F24` | F24 |

## Number Row

Also called:
- N-Row
- N-Keys

Superset of `Numerical`.

`KeyHankakuZenkaku` is the full-size JIS (and US) key left of `KeyOne`. The HHKB JIS has no key
there; its 半/全 key is in the Modifier row, as `KeyJISKLangKorean`.

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyHankakuZenkaku` | \` | \` | \` | 半角/全角 | `KC_GRV` | Grave, Accent, Tilde, Backtick, Zenkaku, Hankaku |
| [`Numerical`](#numerical) | | | | | | |
| `KeyHo` | - | - | ! | ほ | `KC_MINS` | Minus, Hyphen, Dash |
| `KeyHe` | = | = | ( | へ | `KC_EQL` | Caret, Equals, JapaneseCaret, JISCaret |
| `KeyLongKatakana` | N/A | N/A | — | ー | `KC_INT3` | Yen, ¥, JapaneseBackslash, JIS Yen, International3, KC\_JYEN |
| `KeyDeleteLeft` | Backspace | Backspace | Backspace | Backspace | `KC_BSPC` | Backspace, BS, Delete (on Mac) |

## Q-Row

Also called:
- R2

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyTab` | Tab | Tab | Tab | Tab | `KC_TAB` | Tab |
| `KeyQ` | Q | ㅂ | ㅂ | た | `KC_Q` |  |
| `KeyW` | W | ㅈ | ㅈ | て | `KC_W` |  |
| `KeyE` | E | ㄷ | ㄷ | い | `KC_E` |  |
| `KeyR` | R | ㄱ | ㄱ | す | `KC_R` |  |
| `KeyT` | T | ㅅ | ㅅ | か | `KC_T` |  |
| `KeyY` | Y | ㅛ | ㅛ | ん | `KC_Y` |  |
| `KeyU` | U | ㅕ | ㅕ | な | `KC_U` |  |
| `KeyI` | I | ㅑ | ㅑ | に | `KC_I` |  |
| `KeyO` | O | ㅐ | ㅐ | ら | `KC_O` |  |
| `KeyP` | P | ㅔ | ㅔ | せ | `KC_P` |  |
| `KeyDakuten` | \[ | \[ | ' | ゛ | `KC_LBRC` | JapaneseDakuten, JIS At, At, US OpeningSquareBracket |
| `KeyHandakuten` | \] | \] | \[ | ゜ | `KC_RBRC` | JapaneseHandakuten, JIS OpeningSquareBracket, US ClosingSquareBracket |
| `KeyISOEnter` | Enter | Enter | Enter | Enter | `KC_ENT` | Enter, Return |

## A-Row

Also called:
- HHKB Control Row
- US Caps Lock Row

`KeyLeftControl` is the Control in Caps Lock's place (HHKB). The Caps Lock function is
`KeyCapsLock`, in [Generic keys](#generic-keys).

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyLeftControl` | Control | Control | Control | Control | `KC_LCTL` | HHKB Control, Control, US Caps Lock position |
| `KeyA` | A | ㅁ | ㅁ | ち | `KC_A` |  |
| `KeyS` | S | ㄴ | ㄴ | と | `KC_S` |  |
| `KeyD` | D | ㅇ | ㅇ | し | `KC_D` |  |
| `KeyF` | F | ㄹ | ㄹ | は | `KC_F` |  |
| `KeyG` | G | ㅎ | ㅎ | き | `KC_G` |  |
| `KeyH` | H | ㅗ | ㅗ | く | `KC_H` |  |
| `KeyJ` | J | ㅓ | ㅓ | ま | `KC_J` |  |
| `KeyK` | K | ㅏ | ㅏ | の | `KC_K` |  |
| `KeyL` | L | ㅣ | ㅣ | り | `KC_L` |  |
| `KeyRe` | ; | ; | ~ | れ | `KC_SCLN` | JIS Semicolon, Semicolon, JapaneseSemicolon, JapaneseRe |
| `KeyKe` | ' | ' | : | け | `KC_QUOT` | JIS Colon, US Apostrophe, JapaneseColon, JapaneseKe |
| `KeyMu` | \\ | ₩ | \] | む | `KC_NUHS` (or `KC_BSLS`) | JapaneseMu, Mu, JIS ClosingSquareBracket, US Backslash, Won, UK Hash, Non-US Hash |
| `KeyISOEnter` | Enter | Enter | Enter | Enter | `KC_ENT` | Enter, Return |

## Z-Row

Also called:
- Shift row

`KeyISOBackslash` is only on ISO boards, between Left Shift and Z.

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyLeftShift` | Shift | Shift | Shift | Shift | `KC_LSFT` | LShift, Left Shift, LShft |
| `KeyISOBackslash` | N/A | N/A | N/A | N/A | `KC_NUBS` | Non-US Backslash, ISO Backslash, UK Backslash, 102nd key, the key left of Z on ISO |
| `KeyZ` | Z | ㅋ | ㅋ | つ | `KC_Z` |  |
| `KeyX` | X | ㅌ | ㅌ | さ | `KC_X` |  |
| `KeyC` | C | ㅊ | ㅊ | そ | `KC_C` |  |
| `KeyV` | V | ㅍ | ㅍ | ひ | `KC_V` |  |
| `KeyB` | B | ㅠ | ㅠ | こ | `KC_B` |  |
| `KeyN` | N | ㅜ | ㅜ | み | `KC_N` |  |
| `KeyM` | M | ㅡ | ㅡ | も | `KC_M` |  |
| `KeyNe` | , | , | , | ね | `KC_COMM` | Comma |
| `KeyRu` | . | . | . | る | `KC_DOT` | Period, Dot |
| `KeyMe` | / | / | · | め | `KC_SLSH` | Slash |
| `KeyRo` | N/A | N/A | \\ | ろ | `KC_INT1` | JapaneseRo, Ro, JIS Backslash, Underscore (on Mac), International1 |
| `KeyUpArrow` | ↑ | ↑ | ↑ | ↑ | `KC_UP` | Up, Up Arrow |
| `KeyRightShift` | Shift | Shift | Shift | Shift | `KC_RSFT` | RShift, Right Shift, RShft |

## Modifier row

Also called:
- Modi-row
- M-Row

`KeyUSLeftControl`, `KeyWINMenu` and `KeyRightControl` are not on the HHKB; they're the bottom-row
keys of full-size boards.

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyHHKBLeftFunction` | Fn | Fn | Fn | Fn | N/A | Left Function, LeftFn, Fn1 |
| `KeyJISKLangKorean` | N/A | N/A | カタカナ | 半角/全角 | `KC_INT2` | PC Katakana, LangKorean, LangKo, Windows JIS カタカナ/ひらがな, HHKB JIS 半/全 position, International2, KC\_KANA |
| `KeyLeftAuxiliary` | ⌥ | ⌥ | ⌥ | ⌥ | `KC_LALT` | LeftOpt, LeftAlt, LOpt, LAlt, LAux |
| `KeyLeftPrimary` | ⌘ | ⌘ | ⌘ | ⌘ | `KC_LGUI` | LeftCommand, LCmd, LeftWin, LWin, LGUI |
| `KeyJISMacEnglish` | 英数 | 英数 | 英数 | 英数 | `KC_LNG2` | Eisuu, MacRomaji, LangEn, Lang2, KC\_HANJ (named for Korean 한자) |
| `KeySpacebar` | Space | Space | Space | Space | `KC_SPC` | Spacebar, Space |
| `KeyJISMacKana` | かな | かな | かな | かな | `KC_LNG1` | Kana, LangJa, Lang1, KC\_HAEN (named for Korean 한/영) |
| `KeyRightPrimary` | ⌘ | ⌘ | ⌘ | ⌘ | `KC_RGUI` | RightCommand, RCmd, RightWin, RWin, RGUI |
| `KeyRightAuxiliary` | ⌥ | ⌥ | ⌥ | ⌥ | `KC_RALT` | RightOpt, RightAlt, ROpt, RAlt, RAux, AltGr |
| `KeyHHKBRightFunction` | Fn | Fn | Fn | Fn | N/A | Right Function, RightFn, Fn1 |
| `KeyLeftArrow` | ← | ← | ← | ← | `KC_LEFT` | Left, Left Arrow |
| `KeyDownArrow` | ↓ | ↓ | ↓ | ↓ | `KC_DOWN` | Down, Down Arrow |
| `KeyRightArrow` | → | → | → | → | `KC_RGHT` | Right, Right Arrow |
| `KeyUSLeftControl` | Control | Control | Control | Control | `KC_LCTL` | LCtrl, Left Control, LCtl |
| `KeyWINMenu` | Menu | Menu | Menu | Menu | `KC_APP` | Application, App, Context Menu |
| `KeyRightControl` | Control | Control | Control | Control | `KC_RCTL` | RCtrl, Right Control, RCtl |

## Generic keys

Also called:
- Generics

Keys by what they do rather than where they are. Layer keys only exist in firmware (QMK, VIA), so
they have no legend or HID usage.

- `KeyMomentaryNextLayer` turns on the layer above the base layer while held: a plain function
  layer, for when which layer is the base isn't fixed. `MO(NEXT)` isn't a real QMK keycode; write it
  as `MO(n + 1)`, where `n` is the base layer.
- `KeyNoOp` does nothing, on purpose, and stays that way.
- `KeyPassthrough` does whatever the key does on the layer below (QMK's transparent, ▽ in the
  key-legend drawings).
- `KeyReservedForFutureUse` does nothing for now (it sends `KC_NO`), but is kept free for a later
  assignment: don't put anything else on it, and don't read it as a deliberate no-op.
- `KeyKeyboardHardwareControl` is any key set aside for changing the keyboard's own state:
  Bluetooth pairing, backlight or RGB, profile switching, pointing-stick speed, entering the
  bootloader. Its signal never reaches the computer directly, so it has no keycode or HID usage
  here; what it does depends on the keyboard and its firmware.

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyMomentaryLayerZero` | N/A | N/A | N/A | N/A | `MO(0)` | MO(0), Momentary layer 0 |
| `KeyMomentaryLayerOne` | N/A | N/A | N/A | N/A | `MO(1)` | MO(1), Momentary layer 1 |
| `KeyMomentaryLayerTwo` | N/A | N/A | N/A | N/A | `MO(2)` | MO(2), Momentary layer 2 |
| `KeyMomentaryLayerThree` | N/A | N/A | N/A | N/A | `MO(3)` | MO(3), Momentary layer 3 |
| `KeyMoveToLayerZero` | N/A | N/A | N/A | N/A | `TO(0)` | TO(0), Move to layer 0 |
| `KeyMoveToLayerOne` | N/A | N/A | N/A | N/A | `TO(1)` | TO(1), Move to layer 1 |
| `KeyMoveToLayerTwo` | N/A | N/A | N/A | N/A | `TO(2)` | TO(2), Move to layer 2 |
| `KeyMoveToLayerThree` | N/A | N/A | N/A | N/A | `TO(3)` | TO(3), Move to layer 3 |
| `KeyToggleLayerZero` | N/A | N/A | N/A | N/A | `TG(0)` | TG(0), Toggle layer 0 |
| `KeyToggleLayerOne` | N/A | N/A | N/A | N/A | `TG(1)` | TG(1), Toggle layer 1 |
| `KeyToggleLayerTwo` | N/A | N/A | N/A | N/A | `TG(2)` | TG(2), Toggle layer 2 |
| `KeyToggleLayerThree` | N/A | N/A | N/A | N/A | `TG(3)` | TG(3), Toggle layer 3 |
| `KeyMomentaryNextLayer` | N/A | N/A | N/A | N/A | `MO(NEXT)` | MO(NEXT), Function layer, Fn layer, Momentary next layer |
| `KeyNoOp` | N/A | N/A | N/A | N/A | `KC_NO` | KC\_NO, XXXXXXX, No-op, No operation, Disabled |
| `KeyPassthrough` | N/A | N/A | N/A | N/A | `KC_TRNS` | KC\_TRNS, \_\_\_\_\_\_\_, Transparent, Passthrough, ▽ |
| `KeyReservedForFutureUse` | N/A | N/A | N/A | N/A | `KC_NO` | Reserved, RFU, Reserved for future use |
| `KeyKeyboardHardwareControl` | N/A | N/A | N/A | N/A | N/A | Hardware control, Keyboard control, Bluetooth pairing, Backlight, RGB, Profile switch, Pointing-stick speed, QK\_BOOT, Bootloader |
| `KeyCapsLock` | Caps Lock | Caps Lock | Caps Lock | Caps Lock | `KC_CAPS` | CapsLock, Caps |
| `KeyPrintScreen` | PrtSc | PrtSc | PrtSc | PrtSc | `KC_PSCR` | Print Screen, PrtSc, F13 (on Mac) |
| `KeyScrollLock` | ScrLk | ScrLk | ScrLk | ScrLk | `KC_SCRL` | Scroll Lock, ScrLk, F14 (on Mac) |
| `KeyPause` | Pause | Pause | Pause | Pause | `KC_PAUS` | Pause, Break, PauseBreak, F15 (on Mac) |
| `KeyVolumeUp` | Vol+ | Vol+ | Vol+ | Vol+ | `KC_VOLU` | Volume Up |
| `KeyVolumeDown` | Vol− | Vol− | Vol− | Vol− | `KC_VOLD` | Volume Down |
| `KeyMute` | Mute | Mute | Mute | Mute | `KC_MUTE` | Mute |
| `KeyMediaPlayPause` | ▶︎❚❚ | ▶︎❚❚ | ▶︎❚❚ | ▶︎❚❚ | `KC_MPLY` | Play/Pause, Play |
| `KeyMediaNextTrack` | ▶︎▶︎ | ▶︎▶︎ | ▶︎▶︎ | ▶︎▶︎ | `KC_MNXT` | Next Track |
| `KeyMediaPreviousTrack` | ◀︎◀︎ | ◀︎◀︎ | ◀︎◀︎ | ◀︎◀︎ | `KC_MPRV` | Previous Track |
| `KeyEject` | ⏏ | ⏏ | ⏏ | ⏏ | `KC_EJCT` | Eject |
| `KeyBrightnessUp` | ☀+ | ☀+ | ☀+ | ☀+ | `KC_BRIU` | Brightness Up |
| `KeyBrightnessDown` | ☀− | ☀− | ☀− | ☀− | `KC_BRID` | Brightness Down |
| `KeySystemPower` | Power | Power | Power | Power | `KC_PWR` | Power |

## Navigation keys

Also called:
- Navkeys
- Nav island

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyInsert` | Insert | Insert | Insert | Insert | `KC_INS` | Ins, Help (on Mac) |
| `KeyHome` | Home | Home | Home | Home | `KC_HOME` | Home |
| `KeyPageUp` | Page Up | Page Up | Page Up | Page Up | `KC_PGUP` | PgUp |
| `KeyDeleteRight` | Delete | Delete | Delete | Delete | `KC_DEL` | Delete, Del, Forward Delete, DeleteForward |
| `KeyEnd` | End | End | End | End | `KC_END` | End |
| `KeyPageDown` | Page Down | Page Down | Page Down | Page Down | `KC_PGDN` | PgDn |

## Numpad keys

### Key table

| Repository canonical name | Legend on QWERTY | Legend on Korean 2-set | Legend on JIS Korean | Legend on Japanese Kana | Keycode | Also called |
|---|---|---|---|---|---|---|
| `KeyWINNumlock` | Num Lock | Num Lock | Num Lock | Num Lock | `KC_NUM` | Num Lock, NumLk, Clear (on Mac) |
| `KeyNumpadDivide` | / | / | / | / | `KC_PSLS` | Numpad Slash, KP / |
| `KeyNumpadMultiply` | \* | \* | \* | \* | `KC_PAST` | Numpad Asterisk, KP \* |
| `KeyNumpadMinus` | - | - | - | - | `KC_PMNS` | Numpad Subtract, KP - |
| `KeyNumpadPlus` | + | + | + | + | `KC_PPLS` | Numpad Add, KP + |
| `KeyNumpadEnter` | Enter | Enter | Enter | Enter | `KC_PENT` | KP Enter, Enter (keypad) |
| `KeyNumpadSeven` | 7 | 7 | 7 | 7 | `KC_P7` | Numpad7, KP 7 |
| `KeyNumpadEight` | 8 | 8 | 8 | 8 | `KC_P8` | Numpad8, KP 8 |
| `KeyNumpadNine` | 9 | 9 | 9 | 9 | `KC_P9` | Numpad9, KP 9 |
| `KeyNumpadFour` | 4 | 4 | 4 | 4 | `KC_P4` | Numpad4, KP 4 |
| `KeyNumpadFive` | 5 | 5 | 5 | 5 | `KC_P5` | Numpad5, KP 5 |
| `KeyNumpadSix` | 6 | 6 | 6 | 6 | `KC_P6` | Numpad6, KP 6 |
| `KeyNumpadOne` | 1 | 1 | 1 | 1 | `KC_P1` | Numpad1, KP 1 |
| `KeyNumpadTwo` | 2 | 2 | 2 | 2 | `KC_P2` | Numpad2, KP 2 |
| `KeyNumpadThree` | 3 | 3 | 3 | 3 | `KC_P3` | Numpad3, KP 3 |
| `KeyNumpadZero` | 0 | 0 | 0 | 0 | `KC_P0` | Numpad0, KP 0 |
| `KeyNumpadDecimal` | . | . | . | . | `KC_PDOT` | Numpad Period, KP . |
| `KeyNumpadEquals` | = | = | = | = | `KC_PEQL` | Numpad Equals, KP = |
| `KeyNumpadComma` | , | , | , | , | `KC_PCMM` | JIS Numpad Comma, KP , |

## Aliases

Aliases used to refer to the same key position/keycode.

### Key table

| Repository canonical name | Accepted canonical alternative names |
|---|---|
| `KeyHo` | `KeyUSMinus`, `KeyJISMinus` |
| `KeyHe` | `KeyUSEquals`, `KeyJISCaret` |
| `KeyHankakuZenkaku` | `KeyUSTilde`, `KeyUSGrave` |
| `KeyLongKatakana` | `KeyJISYen` |
| `KeyDakuten` | `KeyUSLeftBracket`, `KeyJISAt` |
| `KeyHandakuten` | `KeyUSRightBracket`, `KeyJISLeftBracket` |
| `KeyISOEnter` | `KeyUSEnter` |
| `KeyRe` | `KeyUSSemicolon`, `KeyJISSemicolon` |
| `KeyKe` | `KeyUSApostrophe`, `KeyJISColon` |
| `KeyMu` | `KeyUSBackslash`, `KeyJISRightBracket` |
| `KeyNe` | `KeyUSComma` |
| `KeyRu` | `KeyUSPeriod` |
| `KeyMe` | `KeyUSSlash` |
| `KeyRo` | `KeyJISBackslash` |
