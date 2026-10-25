# Lone Right Win / Right Ctrl / Right Alt taps never reach a TIP

**Status:** not fixable in a TIP, as measured. FKeyIME's escape hatch uses ``Alt+` ``,
``Alt+Shift+` `` and Menu instead (2026-10-17).

Source: FKeyIME, [`docs/issues/modifier-taps-unreachable.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/modifier-taps-unreachable.md),
spec §8 ("Escape hatch"), commit [`aa6789f`](https://github.com/themrsung/fkeyime/commit/aa6789f).

## What was tried *(measured with `fkeyime_probe`)*

| Key | Key event sink | TSF preserved key (also with `TF_MOD_ON_KEYUP`) |
| --- | --- | --- |
| Right Alt (`KeyRightAuxiliary`) | Never called (Alt is a system key) | Never fired; its key-up put the window in menu mode |
| Right Win (`KeyRightPrimary`) | Not seen; the Start menu opened | Never fired |
| Right Ctrl (`KeyRightControl`) | Not seen | Never fired |
| Menu (`KeyWINMenu`) | Called, but eating the key didn't stop the context menu | **Fires.** TSF-aware controls: no context menu. Classic Win32 Edit: the menu still opens, even with key-down and key-up both eaten (cause not found) |

A `Scancode Map` remap to F-keys would work, but the owner rejected it: a required remap defeats the
purpose of an escape hatch. Injecting Right Win caused
[injected-right-win-holds-input](../injected-right-win-holds-input/README.md).

## ``Alt+` `` under the Japanese layout *(measured)*

Under the US and Korean layouts `` ` `` is `VK_OEM_3`, and ``Alt+` `` works as a preserved key.
Under the Japanese layout the `` ` `` key is 半角/全角 (`KeyHankakuZenkaku`; `VK_OEM_AUTO` / `VK_OEM_ENLW`) and ``Alt+` ``
is `VK_KANJI`, which Windows also uses for its Japanese on/off hotkey. No preserved key matches it,
but it reaches the key event sink, so FKeyIME catches it there by scan code (`0x29`) with Alt down.
Moving Windows' hotkey wasn't needed: with it restored, the cycle still passed.

## Keys rejected for app conflicts (owner)

Ctrl+Tab, Ctrl+Space, Shift+Space, Ctrl+Shift+digit, Alt+digit, and ``Ctrl+Shift+` `` (VS Code's
new terminal).
