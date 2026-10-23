# KC_HANJ, KC_HAEN and KC_KANA on a Mac

QMK names the language keys after Korean and Windows keyboards. On a Mac they mean something else:

| QMK name | Alias | HID usage | Named for | On a Mac |
|---|---|---|---|---|
| `KC_HAEN` | `KC_LNG1` | 0x90 (LANG1) | 한/영, Korean's Hangul/English | **かな**, Japanese |
| `KC_HANJ` | `KC_LNG2` | 0x91 (LANG2) | 한자, Korean's Hanja | **英数**, English |
| `KC_KANA` | `KC_INT2` | 0x88 (International2) | Windows JIS カタカナ/ひらがな | becomes かな, unless something reads the keyboard itself |
| `KC_JYEN` | `KC_INT3` | 0x89 (International3) | JIS ¥ | ¥ key |
| `KC_RO` | `KC_INT1` | 0x87 (International1) | JIS ろ | ろ key |

So a Korean-style "한/영 right of Space" (`KC_HAEN`) is Japanese かな on a Mac, and "한자" is 英数.
Hansung's web driver labels them 한영 and 한자, which reads the same way.

Pick by what the Mac does, not by the name. See
[japanese-keycodes-on-macos](../japanese-keycodes-on-macos/README.md) for which of them macOS
acts on at all.
