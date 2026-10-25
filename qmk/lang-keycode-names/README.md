# KC_HANJ, KC_HAEN and KC_KANA on a Mac

QMK names the language keys after Korean and Windows keyboards. On a Mac they mean something else:

| QMK name | Alias | HID usage | Canonical name | Named for | On a Mac |
|---|---|---|---|---|---|
| `KC_HAEN` | `KC_LNG1` | 0x90 (LANG1) | `KeyKTSHangulToggle` (same keycode as `KeyJISMacKana`) | 한/영, Korean's Hangul/English | **かな**, Japanese (acts as `KeyJISMacKana`) |
| `KC_HANJ` | `KC_LNG2` | 0x91 (LANG2) | `KeyKTSHanja` (same keycode as `KeyJISMacEnglish`) | 한자, Korean's Hanja | **英数**, English (acts as `KeyJISMacEnglish`) |
| `KC_KANA` | `KC_INT2` | 0x88 (International2) | `KeyJISKLangKorean` | Windows JIS カタカナ/ひらがな | becomes かな (acts as `KeyJISMacKana`), unless something reads the keyboard itself |
| `KC_JYEN` | `KC_INT3` | 0x89 (International3) | `KeyLongKatakana` | JIS ¥ | ¥ key |
| `KC_RO` | `KC_INT1` | 0x87 (International1) | `KeyRo` | JIS ろ | ろ key |

So a Korean-style "한/영 right of Space" (`KeyKTSHangulToggle`, `KC_HAEN`) is Japanese かな
(`KeyJISMacKana`) on a Mac, and "한자" (`KeyKTSHanja`) is 英数 (`KeyJISMacEnglish`): each pair shares
one keycode.
Hansung's web driver labels them 한영 and 한자, which reads the same way.

Pick by what the Mac does, not by the name. See
[japanese-keycodes-on-macos](../japanese-keycodes-on-macos/README.md) for which of them macOS
acts on at all.
