# Apps running during an install don't load the TIP, or keep the old build

**Status:** solved by restarting the apps (or signing out) and by watching the registry for
setting changes (2026-10-17).

Source: FKeyIME, [`docs/issues/apps-dont-load-fkeyime.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/apps-dont-load-fkeyime.md),
[`docs/issues/settings-need-app-restart.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/settings-need-app-restart.md),
[`docs/issues/development-notes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/development-notes.md),
commits [`7be6e46`](https://github.com/themrsung/fkeyime/commit/7be6e46), [`4b3d43f`](https://github.com/themrsung/fkeyime/commit/4b3d43f),
[`a079a15`](https://github.com/themrsung/fkeyime/commit/a079a15).

## 1. Korean and kana typed English letters in some apps

**Symptom.** The taskbar showed FKeyIME KO or JA and the F-keys switched it, but Notepad, Claude,
Opera, Edge and Windows Terminal typed English letters in Korean and Japanese (US symbols in
Korean, JIS in Japanese): Windows' plain layouts were typing.

**Cause** *(measured)*. These apps had been running through many reinstalls that day, including a
rename of the project. They switched to the TIP's language but never asked its DLL for its COM
object: no `DllGetClassObject` in the log, no DLL in their loaded modules. A fresh Win32 window
and a fresh WPF app (PowerShell ISE) loaded it at once; Notepad typed Korean and kana after a
restart.

**What made it diagnosable.** Logging `DllGetClassObject` and `CreateInstance` once per process
(no text) to `%ProgramData%\fkeyime\fkeyime.log` (commit `7be6e46`). An app that never logs
them never tried to load the TIP: "never loaded" rather than "activation failed".

## 2. A changed setting didn't reach running apps

**Symptom.** After the keyboard option was set back to JIS, Shift+2 still typed `@` in open
apps; a new Notepad window typed `"`.

**Cause** *(measured)*. The TIP re-read its options only in `OnSetFocus`, which TSF calls when
the TIP's thread manager gains focus, which rarely happens on a window switch: the log had no
`OnSetFocus` from the open apps at all. An earlier check that "a running Notepad picks up the
change" passed only because it opened a new window. And Claude, Discord, Explorer and Search were
running an older DLL loaded before the build with the option.

**Fix** (`4b3d43f`). `RegNotifyChangeKeyValue` on both option keys (HKCU and HKLM), and the
signal is checked without waiting on every key (`OnTestKeyDown`, `OnKeyDown`,
`OnPreservedKey`). Measured with a probe case that changes the option inside one running window,
in a Win32 Edit and a RichEdit.

## 3. The DLL file is locked by processes that loaded it

The development install script moves the loaded DLL aside (`fkeyime.dll.old-*`) and copies the
new one (`a079a15`). Processes that had the old one keep running it until they restart, which is
case 1 again.

## Where it stands

A running app keeps the TIP build it loaded. The spec requires the installer to ask users to
restart apps or sign out after an install or update.
