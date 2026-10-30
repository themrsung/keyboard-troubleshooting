# RealForce Compact (JIS): JIS Korean's bottom row, with Karabiner-Elements

A Karabiner-Elements rule for a **RealForce Compact** (Topre, JIS tenkeyless, stock firmware, USB
`0853:0200`, reports as "RealForce Compact"), for macOS. The board's firmware is left stock, and
Karabiner-Elements does the remapping: Control left of A, and a bottom row with one key per
language (カタカナ, 英数, かな) either side of ⌥ / ⌘, as on the
[golden layout](../../layouts/hhkb-jis-golden/README.md).

The file is [realforce-compact-jis.json](realforce-compact-jis.json), a complex modification with
one rule. Every manipulator has a `device_if` on `0853:0200`, so no other keyboard is affected.

## The keys

| RealForce key | Canonical name | Karabiner `from` | Sends | Canonical name |
|---|---|---|---|---|
| Caps Lock, left of A | `KeyCapsLock` | `caps_lock` | Left Control | `KeyLeftControl` |
| Ctrl, bottom left | `KeyUSLeftControl` | `left_control` | カタカナ (to Korean) | `KeyJISKLangKorean` |
| Win | `KeyLeftPrimary` | `left_command` | Left ⌥ | `KeyLeftAuxiliary` |
| Alt | `KeyLeftAuxiliary` | `left_option` | Left ⌘ | `KeyLeftPrimary` |
| 無変換 | `KeyJISMuhenkan` | `japanese_pc_nfer` | 英数 (to English) | `KeyJISMacEnglish` |
| Space | `KeySpacebar` | — | unchanged | `KeySpacebar` |
| 変換 | `KeyJISHenkan` | `japanese_pc_xfer` | かな (to Japanese) | `KeyJISMacKana` |
| カナ | `KeyJISKLangKorean` | `japanese_pc_katakana` | Right ⌘ | `KeyRightPrimary` |
| Alt, right | `KeyRightAuxiliary` | — | unchanged, Right ⌥ | `KeyRightAuxiliary` |
| Menu | `KeyWINMenu` | `application` | Caps Lock | `KeyCapsLock` |
| Ctrl, right | `KeyRightControl` | — | unchanged | `KeyRightControl` |
| ろ | `KeyRo` | `international1` | `\`, and `_` with Shift (below) | `KeyRo` |

So the bottom row reads カタカナ, ⌥, ⌘, 英数, Space, かな, ⌘, ⌥, Caps Lock, Control. The board has no
right Win key; the [keyboard-health-check](../../utils/keyboard-health-check/README.md) log of
this board, before the rule, shows every other key above with its HID usage.

- **ろ** types `\` by sending ⌥¥ (`left_option` + `international3`), the Mac JIS way to type a
  backslash; with Shift the rule doesn't match, and ろ types its own `_`. It's off while a Japanese
  input source or JIS Korean (`me.sjun.inputmethod.JISKorean`) is selected, where ろ keeps its own
  meaning.
- **Pause → Play/Pause** isn't in this rule: the owner's "Pause → Play/Pause, on every keyboard"
  rule, with no device condition, covers this board too (see
  [hhkb-studio-jis](../hhkb-studio-jis/README.md#karabiner-elements-for-fn2--i-and-p)).

## How to use

1. **Let Karabiner-Elements modify the board:** in Settings → Devices, turn on "RealForce Compact".
   Its presses then come from `Karabiner DriverKit VirtualHIDKeyboard`.
2. **Store the virtual keyboard as JIS** (Settings → Virtual Keyboard → Keyboard type: JIS), so ¥
   and ろ type.
3. **Import the rule:** copy [realforce-compact-jis.json](realforce-compact-jis.json) into
   `~/.config/karabiner/assets/complex_modifications/`, then Settings → Complex Modifications →
   Add predefined rule, and enable it. **Back up `~/.config/karabiner/karabiner.json` first.**

On Windows nothing changes: Karabiner-Elements is macOS only, and the board sends its stock keys
(変換 is `VK_CONVERT` there, not 한/영).

## Tested

Set up on macOS 27.0.1 (Apple Silicon) with Karabiner-Elements 16.3.0 on 2026-10-30: the rule
passes `karabiner_cli --lint-complex-modifications`, Karabiner loaded it, and its log shows the board
grabbed. **The keys haven't been pressed through yet;** check each with the health check (pick
"All keyboards") before relying on it.
