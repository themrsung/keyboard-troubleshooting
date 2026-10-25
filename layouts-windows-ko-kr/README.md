# Layout proposals for Windows (ko-KR)

Layouts for Windows with the Microsoft IME Korean. New layouts should follow the
[principles](PRINCIPLES.md). For macOS, see [`layouts/`](../layouts/README.md).

| Layout | Keyboard | How |
|---|---|---|
| [windows-104-key-golden](windows-104-key-golden/README.md) | Full-size US (Keychron C2 Pro): **the golden layout**, in progress | Firmware (VIA protocol), from the Windows defaults |

Try layouts on a Mac with [windows-tester](../utils/windows-tester/README.md).

The drawings come from the same renderer as the macOS ones
([layouts/render](../layouts/README.md#the-drawings)), with dubeolsik legends in place of JIS
Korean's Mode A, and Kana for reference.

## Key names

The files in this directory call keys by their Windows / US legends. Their
[canonical names](../conventions/keynames/REV1-20261025/KEYNAMES.md) are:

| Name used here | Canonical name |
|---|---|
| Fn, either end of the bottom row (`MO(3)`, the Windows side's Fn layer) | `KeyMomentaryLayerThree` |
| Right Fn with 한자 on a tap (`LT(3,KC_LNG2)`) | `HoldTap(KeyMomentaryLayerThree, KeyKTSHanja)` |
| Left Alt with 無変換 on a tap (`LALT_T(KC_INT5)`) | `HoldTap(KeyLeftAuxiliary, KeyJISMuhenkan)` |
| Control left of A (Caps Lock's place) | `KeyLeftControl` |
| Left Control, the stock bottom-left corner (5,0) | `KeyUSLeftControl` (that position) |
| Right Control | `KeyRightControl`; on the golden layout it sits right of right Win (5,12), the `KeyWINMenu` position |
| Alt / Win, left and right | `KeyLeftAuxiliary` / `KeyRightAuxiliary`, `KeyLeftPrimary` / `KeyRightPrimary` |
| Control, Alt, Win (System), Shift, either side | `KeyUniversalControl`, `KeyUniversalAuxiliary`, `KeyUniversalPrimary`, `KeyUniversalShift` |
| 한/영 (`VK_HANGUL`) | `KeyKTSHangulToggle`; 한/영 on Right Alt (Type 1) is a Windows behaviour of `KeyRightAuxiliary` |
| 한자 (`VK_HANJA`, USB LANG2) | `KeyKTSHanja`; 한자 on Right Control (Type 1) is a Windows behaviour of `KeyRightControl` |
| 無変換 / 変換 | `KeyJISMuhenkan` / `KeyJISHenkan` |
| カタカナ/ひらがな, カタカナ (`KC_INT2`) | `KeyJISKLangKorean` |
| ¥, ー (`KC_INT3`) | `KeyLongKatakana` |
| む (`KC_NUHS`, JIS's ] key); US `\` | `KeyMu` |
| ろ (`KC_INT1`) | `KeyRo` |
| Caps Lock, Print Screen, Scroll Lock, Pause | `KeyCapsLock`, `KeyPrintScreen`, `KeyScrollLock`, `KeyPause` |
| Backspace, Delete, Insert | `KeyDeleteLeft`, `KeyDeleteRight`, `KeyInsert` |
| Home, End, Page Up, Page Down, the arrows | `KeyHome`, `KeyEnd`, `KeyPageUp`, `KeyPageDown`, `KeyUpArrow` … |
| Keypad *, /, −, +, Enter | `KeyNumpadMultiply`, `KeyNumpadDivide`, `KeyNumpadMinus`, `KeyNumpadPlus`, `KeyNumpadEnter` |
| F1 … F12 | `KeyFunctionOne` … `KeyFunctionTwelve` |
| Letters, digits; `[ ; ' , . / - =` | `KeyQ` …, `KeyOne` …; `KeyDakuten`, `KeyRe`, `KeyKe`, `KeyNe`, `KeyRu`, `KeyMe`, `KeyHo`, `KeyHe` |
| Volume down / up, mute, eject, Play/Pause, previous / next track | `KeyVolumeDown`, `KeyVolumeUp`, `KeyMute`, `KeyEject`, `KeyMediaPlayPause`, `KeyMediaPreviousTrack`, `KeyMediaNextTrack` |
| Screen brightness down / up | `KeyBrightnessDown`, `KeyBrightnessUp` |
| Task View, File Explorer, Screenshot, Cortana (Keychron 0x7F07–0x7F0A) | `KeyWINTaskView`, `KeyWINFileExplorer`, `KeyWINScreenshot`, `KeyWINCortana` |
| Mission Control, Launchpad, ⌥, ⌘ (Keychron 0x7F00–0x7F05, Mac side) | `KeyMACMissionControl`, `KeyMACLaunchpad`, `KeyLeftAuxiliary` / `KeyRightAuxiliary`, `KeyLeftPrimary` / `KeyRightPrimary` |
| Backlight controls (`RGB_*`), NKRO (`NK_TOGG`), the RHC slots' hardware controls | `KeyKeyboardHardwareControl` |
| Transparent (`KC_TRNS`) | `KeyPassthrough` |

"Fn+X" means `KeyX` pressed while `KeyMomentaryLayerThree` is held.
