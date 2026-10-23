# Packaged apps don't see the user's HKCU options key

**Status:** worked around by setting options in HKLM (2026-10-17).

Source: FKeyIME, spec §8 ("US ANSI keyboards"), commit
[`aa6789f`](https://github.com/themrsung/fkeyime/commit/aa6789f).

FKeyIME reads its options from `HKCU\Software\fkeyime`, else `HKLM\Software\fkeyime`. Packaged
(Store) apps don't see the user's `HKCU\Software\fkeyime` and fall back to HKLM *(measured: Notepad
read `KeyboardLayout=0` with only HKCU set, while conhost read 1)*. HKLM's ACL grants ALL
APPLICATION PACKAGES read, so the options are set there.

Related, from FKeyIME spec §3 *(documented / measured)*: Store/AppContainer apps need the immersive
caps and an install path readable by ALL APPLICATION PACKAGES; code signing wasn't needed to load
(the unsigned DLL loaded and switched in Notepad 11.2607, `SearchHost.exe` and Settings).
JIS Korean's Windows README lists sandboxed Store apps maybe not reading its settings or training
file as *not measured yet*.
