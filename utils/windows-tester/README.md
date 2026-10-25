# windows-tester

A Mac app for trying Windows layouts without a Windows machine. While its window is focused, it
shows every key and combination as Windows would receive it (scan code, virtual-key code, window
message) and simulates the Microsoft IME Korean (dubeolsik), with a plain edit control showing the
result. It's for developers, so the UI is a log.

```sh
utils/windows-tester/build.sh          # build/WindowsTester.app: swiftc, ad-hoc signed, then the self-test
open utils/windows-tester/build/WindowsTester.app
```

No Xcode project. Build it yourself, and delete `build/` when you're done: it's ignored by git.
It needs no permissions, because it only reads keys sent to its own window.

## What it simulates

- **Keys:** macOS key codes mapped to Windows scan codes (set 1) and VKs, with ⌘ as Windows and ⌥
  as Alt. `WM_SYSKEYDOWN` for Alt chords and F10, lone Alt (menu bar) and lone Windows (Start),
  Num Lock turning the keypad into navigation keys, and the combinations Windows itself takes.
- **The Korean keyboard type** (the menu at the top): Type 1 turns Right Alt into 한/영 and Right
  Control into 한자; Type 2 needs the dedicated keys; Type 3 uses Shift+Space and Ctrl+Space.
  USB LANG1 / LANG2 (かな / 英数 on a Mac) are 한/영 / 한자 on every type.
- **The IME:** 한/영 toggles Korean; letters compose dubeolsik syllables, the app getting
  `VK_PROCESSKEY` and `WM_IME_*` messages; a final consonant moves to the next syllable when a
  vowel follows; Backspace takes back one jamo; any other key, or a Ctrl / Alt / Windows chord,
  commits the syllable first. 한자 is logged, not converted. Since JIS Korean is a superset of
  dubeolsik, a layout that types correctly here is ready for JIS Korean for Windows too.

## Key names

Each log line gives the key as printed on a PC keyboard, then its canonical name from
[KEYNAMES.md](../../conventions/keynames/REV1-20261025/KEYNAMES.md) (the key pressed: Right Alt
acting as 한/영 is still `KeyRightAuxiliary`). The names this README and the log use, where they
aren't obvious:

| Here | Canonical name |
|---|---|
| 한/영 (USB LANG1, かな on a Mac) | `KeyKTSHangulToggle` |
| 한자 (USB LANG2, 英数 on a Mac) | `KeyKTSHanja` |
| Right Alt, Right Control | `KeyRightAuxiliary`, `KeyRightControl` |
| Left Alt, Left / Right Windows | `KeyLeftAuxiliary`, `KeyLeftPrimary` / `KeyRightPrimary` |
| Left Control | `KeyLeftControl` (macOS can't tell a PC's bottom-row `KeyUSLeftControl` from it) |
| Print Screen, Scroll Lock, Pause (kVK F13–F15) | `KeyPrintScreen`, `KeyScrollLock`, `KeyPause` |
| Insert (Help on a Mac), Delete, Backspace | `KeyInsert`, `KeyDeleteRight`, `KeyDeleteLeft` |
| Num Lock (keypad Clear on a Mac) | `KeyWINNumlock` |
| Keypad 5 with Num Lock off, "(nothing)" / `VK_CLEAR` | `KeyClear` |
| Menu | `KeyWINMenu` |
| Fn (Mac) | `KeyMACGlobe` |
| ¥ (JIS), ろ (JIS), ISO § | `KeyLongKatakana`, `KeyRo`, `KeyISOBackslash` |
| Enter, Space, `` ` ``, `\ (₩)` | `KeyISOEnter`, `KeySpacebar`, `KeyHankakuZenkaku`, `KeyMu` |
| Next / Previous Track (fast forward / rewind folded in) | `KeyMediaNextTrack` / `KeyMediaPreviousTrack` |
| a keyboard's Fn (`MO()`) | `KeyMomentaryLayerN` |

## Limits

- **macOS hides some PC keys behind others:** Print Screen, Scroll Lock and Pause arrive as F13–F15,
  Insert as Help, and Num Lock as keypad Clear. The log says so on those keys.
- **macOS takes some combinations before any app:** ⌘Tab (Win+Tab), ⌘Space (Win+Space, the
  Windows language switch), Ctrl+arrows, the screenshot keys, and whatever is set as the input-source
  shortcut. Set macOS to ABC while testing, so a Mac input method doesn't act on the language keys.
- **A keyboard's Fn never reaches any computer,** so `MO()` layers only show as the keys they send.
- **From memory, not yet checked against Windows:** Esc and Caps Lock during composition (here Esc
  commits, and Caps Lock types Latin letters in Korean mode), a lone consonant followed by another
  (here each stays separate, no ㄳ), Type 3's keys, and the VKs of ¥ and ろ on the Korean layout.
  Confirm on Windows before relying on them, and fix the simulator when they differ.
