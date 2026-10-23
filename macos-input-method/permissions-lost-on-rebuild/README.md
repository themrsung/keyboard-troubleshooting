# Input Monitoring and Accessibility are lost on every rebuild

**Status:** solved by signing with an Apple Development certificate when one is in the keychain
(2026-10-22). Ad hoc builds still need the grants again each time.

Source: JIS Korean, commit [`ac9a0b7`](https://github.com/team-mirae/jis-korean/commit/ac9a0b7),
`mac/README.md`.

## Symptom

After each rebuild, the HID listener and the key tap waited for permissions that had already been
granted.

## Cause, as recorded

The permissions macOS grants follow the code signature. Ad hoc signed, every build is a new app
to macOS.

## Fix

`mac/Makefile` picks an `Apple Development:` identity from `security find-identity -v -p
codesigning` (or `SIGN_IDENTITY`), else signs ad hoc. JIS Korean now asks for the two permissions
the first time only (an input menu item, "Allow カタカナ and F18 Everywhere…", asks again), and logs
both states while it waits.
