# iTerm keeps F18; Caps Lock as the switch key was tried and dropped

**Status:** solved with a system-wide key tap (Accessibility); Caps Lock switching removed
(2026-10-22).

Source: JIS Korean, commits [`b433fed`](https://github.com/team-mirae/jis-korean/commit/b433fed),
[`2baa7b5`](https://github.com/team-mirae/jis-korean/commit/2baa7b5),
[`e9c14a8`](https://github.com/team-mirae/jis-korean/commit/e9c14a8),
[`4402ed9`](https://github.com/team-mirae/jis-korean/commit/4402ed9),
[`9a50937`](https://github.com/team-mirae/jis-korean/commit/9a50937); spec §8.2.1.

## Symptom

The Korean Key (F18, `KeyFunctionEighteen`, from a key remapped with Karabiner or firmware)
switched English → Korean everywhere except iTerm, which keeps F1–F19 to itself: F18 never reached
the input method there.
Separately, Terminal printed F18 when the input source was selected from inside the key handler
(`b433fed`; see [bare-jamo-in-chrome](../bare-jamo-in-chrome/README.md)).

## What was tried

| Commit | Change | Result |
| --- | --- | --- |
| `2baa7b5` | Caps Lock (`KeyCapsLock`) in an English mode goes to Korean. Caps Lock reaches the input method as a modifier change (`flagsChanged`), which iTerm passes on. Capitals from Shift only. Unmapped key codes logged per app (showed which keys an app passes on). | Switched. The lock still toggled (noted as harmless then: no mode typed capitals from it), and the English layouts lost their Caps Lock layer |
| `e9c14a8` | Plain Caps Lock never locks: turned straight back off through the HID system. With Shift/Option/Ctrl/Cmd (`KeyUniversalShift`, `KeyUniversalAuxiliary`, `KeyUniversalControl`, `KeyUniversalPrimary`) it's a real Caps Lock. | The English layouts got their Caps Lock layer back. The press reaches the input method only after macOS has toggled the lock, so the lock is set back rather than the press swallowed |
| `4402ed9` | Plain Caps Lock restores the lock's previous state instead, ignoring the echo of its own change (one echo per change, within 0.5 s). | — |
| `9a50937` | Dropped Caps Lock switching. A key tap (`CGEventTap`, Accessibility) catches F18 and カタカナ (`KeyJISKLangKorean`) before any app sees them, so they work in iTerm and from other input sources. Caps Lock is a normal Caps Lock again. | Works. Until both permissions are granted, F18 works only in apps that pass it on |

Reason recorded for dropping Caps Lock: macOS toggles its light before an input method hears of
it.

The tap lives in the input method's process, which brought the next two issues:
[switch-keys-dead-after-login](../switch-keys-dead-after-login/README.md) and
[permissions-lost-on-rebuild](../permissions-lost-on-rebuild/README.md).
