# HHKB Professional BT Keymap (US ANSI)

Left to right, row by row from top to bottom. Probably also applies to other HHKB US layouts.

Measured on macOS Golden Gate 27, with Mac Mode.

## DIP Switches

| SW | State | Note |
|---|---|---|
| 1 | OFF | Mac Mode\* |
| 2 | ON | Mac Mode\* |
| 3 | OFF | |
| 4 | OFF | |
| 5 | OFF | |
| 6 | ON | |

\*Mac Mode requires switches 1 and 2 to be OFF and ON (see sticker below keyboard; differs from model to model)

## Legend

| Symbol | Meaning |
|---|---|
| ▽ | Passthrough (`KeyPassthrough`) |
| ■ | Signal does not reach the computer |
| ∈ | Key is the accessor of that layer (e.g. Shift for the Shift layer) |

**Name** and **Fn name** are the [canonical key
names](../../conventions/keynames/REV1-20261025/KEYNAMES.md) of the key and of what it sends with
Fn; an empty Fn name is ▽. Shift shows the character typed, not a key. The US-prefixed names are
aliases: `KeyUSMinus` = `KeyHo`, `KeyUSEquals` = `KeyHe`, `KeyUSBackslash` = `KeyMu`, `KeyUSGrave` =
`KeyHankakuZenkaku`, `KeyUSLeftBracket` = `KeyDakuten`, `KeyUSRightBracket` = `KeyHandakuten`,
`KeyUSSemicolon` = `KeyRe`, `KeyUSApostrophe` = `KeyKe`, `KeyUSEnter` = `KeyISOEnter`, `KeyUSComma`
= `KeyNe`, `KeyUSPeriod` = `KeyRu`, `KeyUSSlash` = `KeyMe`.

## Number Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| Esc | `KeyEscape` | ▽ | Power | `KeySystemPower` |
| One(1) | `KeyOne` | ExclamationMark(!) | F1 | `KeyFunctionOne` |
| Two(2) | `KeyTwo` | At(@) | F2 | `KeyFunctionTwo` |
| Three(3) | `KeyThree` | Sharp(#) | F3 | `KeyFunctionThree` |
| Four(4) | `KeyFour` | Dollar($) | F4 | `KeyFunctionFour` |
| Five(5) | `KeyFive` | Percent(%) | F5 | `KeyFunctionFive` |
| Six(6) | `KeySix` | Caret(^) | F6 | `KeyFunctionSix` |
| Seven(7) | `KeySeven` | Ampersand(&) | F7 | `KeyFunctionSeven` |
| Eight(8) | `KeyEight` | Asterisk(*) | F8 | `KeyFunctionEight` |
| Nine(9) | `KeyNine` | OpeningParenthesis(() | F9 | `KeyFunctionNine` |
| Zero(0) | `KeyZero` | ClosingParenthesis()) | F10 | `KeyFunctionTen` |
| Hyphen(-) | `KeyUSMinus` | Underscore(_) | F11 | `KeyFunctionEleven` |
| Equals(=) | `KeyUSEquals` | Plus(+) | F12 | `KeyFunctionTwelve` |
| Backslash(\\) | `KeyUSBackslash` | VerticalBar(\|) | Insert | `KeyInsert` |
| Backtick(\`) | `KeyUSGrave` | Tilde(~) | DeleteForward | `KeyDeleteRight` |

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
| OpeningSquareBracket([) | `KeyUSLeftBracket` | OpeningCurlyBracket({) | UpArrow | `KeyUpArrow` |
| ClosingSquareBracket(]) | `KeyUSRightBracket` | ClosingCurlyBracket(}) | ▽ |  |
| DeleteLeft(Backspace) | `KeyDeleteLeft` | ▽ | NumLock | `KeyWINNumlock` |

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
| Semicolon(;) | `KeyUSSemicolon` | Colon(:) | LeftArrow | `KeyLeftArrow` |
| Apostrophe(') | `KeyUSApostrophe` | Quotation(") | RightArrow | `KeyRightArrow` |
| Return(Enter) | `KeyUSEnter` | ▽ | NumpadEnter | `KeyNumpadEnter` |

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
| Comma(,) | `KeyUSComma` | OpeningPointyBracket(<) | End | `KeyEnd` |
| Period(.) | `KeyUSPeriod` | ClosingPointyBracket(>) | PageDown | `KeyPageDown` |
| Slash(/) | `KeyUSSlash` | QuestionMark(?) | DownArrow | `KeyDownArrow` |
| RShift | `KeyRightShift` | ∈ | ▽ |  |
| Fn(■) | `KeyHHKBUSFunction` | Fn(■) | Fn(∈■) | `KeyHHKBUSFunction` |

## Modifier Row

| Key | Name | Shift | Fn | Fn name |
|---|---|---|---|---|
| LOpt | `KeyLeftAuxiliary` | ▽ | ▽ |  |
| LCmd | `KeyLeftPrimary` | ▽ | ▽ |  |
| Space | `KeySpacebar` | ▽ | ▽ |  |
| RCmd | `KeyRightPrimary` | ▽ | ▽ |  |
| ROpt | `KeyRightAuxiliary` | ▽ | ▽ |  |
