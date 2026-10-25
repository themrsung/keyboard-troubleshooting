# HHKB Hybrid Type S Keymap (JIS)

Left to right, row by row from top to bottom. Probably also applies to other HHKB JIS layouts.

Measured on macOS Golden Gate 27, with Mac Mode.

**Every key but LeftFn is configurable via keymap tool.**

## DIP Switches

| SW | State | Note |
|---|---|---|
| 1 | ON | Mac Mode |
| 2 | OFF | |
| 3 | OFF | |
| 4 | OFF | |
| 5 | ON | Swap Opt and Command; was remapped by keymap anyway |
| 6 | OFF | |

## Legend

| Symbol | Meaning |
|---|---|
| ▽ | Passthrough (`KeyPassthrough`) |
| ■ | Signal does not reach the computer |
| ☐ | Signal does not reach the computer as configured, but can be reconfigured to reach the computer |
| ∈ | Key is the accessor of that layer (e.g. Shift for the Shift layer) |

**Name** and **Fn name** are the [canonical key
names](../../conventions/keynames/REV1-20261025/KEYNAMES.md) of the key and of what it sends with
Fn; an empty Fn name is ▽. Shift shows the character typed, not a key. The two halves of the ISO
Enter are one key, `KeyISOEnter`.

## Number Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| Esc | `KeyEscape` | ▽ | Power | `KeySystemPower` |
| One(1) | `KeyOne` | ExclamationMark(!) | F1 | `KeyFunctionOne` |
| Two(2) | `KeyTwo` | Quotation(") | F2 | `KeyFunctionTwo` |
| Three(3) | `KeyThree` | Sharp(#) | F3 | `KeyFunctionThree` |
| Four(4) | `KeyFour` | Dollar($) | F4 | `KeyFunctionFour` |
| Five(5) | `KeyFive` | Percent(%) | F5 | `KeyFunctionFive` |
| Six(6) | `KeySix` | Ampersand(&) | F6 | `KeyFunctionSix` |
| Seven(7) | `KeySeven` | Apostrophe(') | F7 | `KeyFunctionSeven` |
| Eight(8) | `KeyEight` | OpeningParenthesis(() | F8 | `KeyFunctionEight` |
| Nine(9) | `KeyNine` | ClosingParenthesis()) | F9 | `KeyFunctionNine` |
| Zero(0) | `KeyZero` | ▽ | F10 | `KeyFunctionTen` |
| Hyphen(-) | `KeyHo` | Equals(=) | F11 | `KeyFunctionEleven` |
| Caret(^) | `KeyHe` | Tilde(~) | F12 | `KeyFunctionTwelve` |
| LongKatakana(ー) | `KeyLongKatakana` | VerticalBar(\|) | Insert | `KeyInsert` |
| Backspace | `KeyDeleteLeft` | ▽ | DeleteForward | `KeyDeleteRight` |

## Q Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| Tab | `KeyTab` | ▽ | CapsLock | `KeyCapsLock` |
| Q | `KeyQ` | ▽ | BluetoothConnect | `KeyKeyboardHardwareControl` |
| W | `KeyW` | ▽ | ▽ |  |
| E | `KeyE` | ▽ | ▽ |  |
| R | `KeyR` | ▽ | ▽ |  |
| T | `KeyT` | ▽ | ▽ |  |
| Y | `KeyY` | ▽ | ▽ |  |
| U | `KeyU` | ▽ | ▽ |  |
| I | `KeyI` | ▽ | PrintScreen | `KeyPrintScreen` |
| O | `KeyO` | ▽ | ScrollLock | `KeyScrollLock` |
| P | `KeyP` | ▽ | PauseBreak | `KeyPause` |
| At(@) | `KeyDakuten` | Backtick(\`) | UpArrow | `KeyUpArrow` |
| OpeningSquareBracket([) | `KeyHandakuten` | OpeningCurlyBracket({) | ▽ |  |
| UpperRowOfIsoEnter | `KeyISOEnter` | ▽ | NumpadEnter | `KeyNumpadEnter` |

## A Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| LControl | `KeyLeftControl` | ▽ | ▽ |  |
| A | `KeyA` | ▽ | VolumeDown | `KeyVolumeDown` |
| S | `KeyS` | ▽ | VolumeUp | `KeyVolumeUp` |
| D | `KeyD` | ▽ | Mute | `KeyMute` |
| F | `KeyF` | ▽ | Eject | `KeyEject` |
| G | `KeyG` | ▽ | ▽ |  |
| H | `KeyH` | ▽ | NumpadAsterisk | `KeyNumpadMultiply` |
| J | `KeyJ` | ▽ | NumpadSlash | `KeyNumpadDivide` |
| K | `KeyK` | ▽ | Home | `KeyHome` |
| L | `KeyL` | ▽ | PageUp | `KeyPageUp` |
| Semicolon(;) | `KeyRe` | Plus(+) | LeftArrow | `KeyLeftArrow` |
| Colon(:) | `KeyKe` | Asterisk(*) | RightArrow | `KeyRightArrow` |
| ClosingSquareBracket(]) | `KeyMu` | ClosingCurlyBracket(}) | ▽ |  |
| LowerRowOfIsoEnter | `KeyISOEnter` | ▽ | NumpadEnter | `KeyNumpadEnter` |

## Z Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| LShift | `KeyLeftShift` | ∈ | ▽ |  |
| Z | `KeyZ` | ▽ | ▽ |  |
| X | `KeyX` | ▽ | ▽ |  |
| C | `KeyC` | ▽ | ▽ |  |
| V | `KeyV` | ▽ | ▽ |  |
| B | `KeyB` | ▽ | ▽ |  |
| N | `KeyN` | ▽ | NumpadPlus | `KeyNumpadPlus` |
| M | `KeyM` | ▽ | NumpadMinus | `KeyNumpadMinus` |
| Comma(,) | `KeyNe` | OpeningPointyBracket(<) | End | `KeyEnd` |
| Period(.) | `KeyRu` | ClosingPointyBracket(>) | PageDown | `KeyPageDown` |
| Slash(/) | `KeyMe` | QuestionMark(?) | DownArrow | `KeyDownArrow` |
| Ro(ろ) | `KeyRo` | ▽ | ▽ |  |
| UpArrow | `KeyUpArrow` | ▽ | RShift | `KeyRightShift` |
| RShift | `KeyRightShift` | ∈ | ▽ |  |

**Note on Ro(ろ):** On macOS, the Ro key prints only Underscore(_) by default, in both the normal and Shift layers. The keycap legend is PC-centric and assumes the normal layer prints Backslash(\\), which on macOS requires a software remap (e.g. Karabiner-Elements). The key is therefore listed by its Japanese IME reading, and Shift is kept as passthrough.

## Modifier Row

This is the setup I use.

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| LeftFn(■) | `KeyHHKBLeftFunction` | LeftFn(■) | LeftFn(∈■) | `KeyHHKBLeftFunction` |
| LangKo | `KeyJISKLangKorean` | ▽ | ▽ |  |
| LOpt | `KeyLeftAuxiliary` | ▽ | ▽ |  |
| LCmd | `KeyLeftPrimary` | ▽ | ▽ |  |
| LangEn | `KeyJISMacEnglish` | ▽ | ▽ |  |
| Space | `KeySpacebar` | ▽ | ▽ |  |
| LangJa | `KeyJISMacKana` | ▽ | ▽ |  |
| RCmd | `KeyRightPrimary` | ▽ | ▽ |  |
| ROpt | `KeyRightAuxiliary` | ▽ | ▽ |  |
| RightFn(☐) | `KeyHHKBRightFunction` | RightFn(☐) | RightFn(∈☐) | `KeyHHKBRightFunction` |
| LeftArrow | `KeyLeftArrow` | ▽ | DeleteForward | `KeyDeleteRight` |
| DownArrow | `KeyDownArrow` | ▽ | RCmd | `KeyRightPrimary` |
| RightArrow | `KeyRightArrow` | ▽ | RControl | `KeyRightControl` |
