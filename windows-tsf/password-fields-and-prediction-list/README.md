# A certificate program's password box showed readings in the prediction list

**Status:** mitigated in layers in JIS Korean's Windows shell (2026-10-21).

Source: JIS Korean, [`docs/troubleshooting/windows-tsf-notes.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/windows-tsf-notes.md),
`windows/README.md` ("Passwords and screen recording").

## Symptom (owner, 2026-10-21)

In a certificate program's password box, the prediction list showed readings of the password; a
screen recording would have captured it.

## What Windows does *(measured)*

Fields marked as passwords get no TIP at all: an `ES_PASSWORD` Edit and a TSF RichEdit with
`IS_PASSWORD` never sent the TIP a key (`type-test.ps1 -Filter password`). The certificate
program's box isn't marked, so to Windows it's ordinary text.

## What was done

- The list window is excluded from capture (`SetWindowDisplayAffinity`, `WDA_EXCLUDEFROMCAPTURE`).
- Marked fields are passed through by the shell too, in case one reaches it (input scope, disabled
  keyboard, a password character on an Edit or RichEdit) *(not measured: Windows caught every case
  that could be built)*.
- Unmarked ones can't be detected: ABC (한/영), or the indicator's "Off in <program>". The shell
  starts off in the local agents of certificate programs found on a test PC (CrossCert UniSign,
  DreamSecurity MagicLine4NX, SignKorea; `kOffByDefault` in `windows/src/settings.cpp`). Measured:
  UniSign accepts its certificate password in ABC.
- Considered and left out: a notice while the screen is recorded (Windows has no API saying the
  screen is captured, guessing from program names misfires, and the list is already out of
  captures).

FKeyIME's spec §3 records the same Windows behaviour from its side: password fields, the secure
desktop (UAC, sign-in) and some legacy contexts don't load TIPs.
