# Which Japanese and language keycodes macOS acts on

QMK (and VIA) can send every HID keyboard usage, but macOS turns only some of the Japanese and
language keys into key presses. Tested on macOS 27, mostly from a Hansung TFG Magnetox XF stored as
JIS. The candidates for 英数 were each tapped alone with macOS's Japanese (Kana) input selected,
watching whether the key reached the event system (an input method's key tap) and what it did:

| Keycode | HID usage | Canonical name | On a Mac |
|---|---|---|---|
| `KC_LNG1` (`KC_HAEN`) | 0x90 | `KeyJISMacKana` (also `KeyKTSHangulToggle`, same keycode) | かな (key code 104): selects Japanese |
| `KC_LNG2` (`KC_HANJ`) | 0x91 | `KeyJISMacEnglish` (also `KeyKTSHanja`, same keycode) | 英数 (key code 102): selects the English input source |
| `KC_INT1` (`KC_RO`) | 0x87 | `KeyRo` | ろ key (key code 94): `\ _` in JIS English, ろ in Kana. Needs a keyboard stored as JIS. |
| `KC_INT3` (`KC_JYEN`) | 0x89 | `KeyLongKatakana` | ¥ key (key code 93): `¥ \|` in JIS English (seen as `\ \|` in one test), ー in Kana. Needs a keyboard stored as JIS. |
| `KC_INT2` (`KC_KANA`) | 0x88 | `KeyJISKLangKorean` | カタカナ/ひらがな: macOS turns it into かな (104, acts as `KeyJISMacKana`); telling it apart needs a tool that reads the keyboard itself |
| `KC_INT4` 変換, `KC_INT5` 無変換 | 0x8A, 0x8B | `KeyJISHenkan`, `KeyJISMuhenkan` | Sent by the keyboard, but no key press reaches apps |
| `KC_LNG3`, `KC_LNG4`, `KC_LNG5` | 0x92–0x94 | `KeyLangThree`, `KeyLangFour`, `KeyLangFive` | Sent by the keyboard, but no key press reaches apps |
| `KC_GRV` (半角/全角's position on JIS) | 0x35 | `KeyHankakuZenkaku` | `` ` `` and `~`, not a width toggle |

So for "go to English" on a Mac, only `KC_LNG2` (`KeyJISMacEnglish`) works, and only as a plain key: as the tap of a
mod-tap it can arrive with a modifier and be ignored (see
[hansung/mod-tap-rshift-bug](../../hansung/mod-tap-rshift-bug/README.md)).

"Sent by the keyboard" means a program reading the keyboard at the HID level (IOHIDManager) saw the
usage go down and up, while no key event followed. Earlier notes elsewhere said macOS turns 変換 and
無変換 into 英数; that didn't happen here.
