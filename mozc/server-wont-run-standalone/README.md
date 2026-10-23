# The server refused to start, then ignored every key

**Status:** both solved (2026-10-17); the first with a known security gap, open until release.

Source: FKeyIME, [`docs/issues/conversion-server-crashes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/conversion-server-crashes.md)
("Earlier server problems"), spec §9, commit
[`7091f80`](https://github.com/themrsung/fkeyime/commit/7091f80).

## Refused to start

Same exit code as the watch dog crash, at once. Mozc's own client starts the server inside Mozc's
sandbox (a restricted token), and the server refuses to run without it. FKeyIME starts it
directly, so `mozc-fkeyime-unsandboxed-server.patch` lets it run without the sandbox thread token.
It then runs with the user's normal rights; FKeyIME's spec lists starting it through Mozc's sandbox
(`base/win32/win_sandbox.*`) or an equivalent restricted token as an open item before release.

## Ignored every key

New Mozc sessions start with the IME off. FKeyIME's client sends `TURN_ON_IME` after creating a
session.

## Other facts the client depends on (spec §6.4, §9)

- The pipe is a message-mode named pipe, `\\.\pipe\<prefix>.<key>.session`, carrying
  `commands::Input` / `Output` protobufs; the server doesn't authenticate clients, and the pipe's
  DACL already admits AppContainer apps at Low integrity.
- FKeyIME derives the key as the SHA-1 of the user's SID, as Mozc does, because AppContainer apps
  can't read Mozc's key file.
- AppContainer apps can't start processes, so they convert only while the server is already
  running (started by another app).
- `mozc-fkeyime-names.patch` renames the product, pipe prefix, mutex and event names, registry key
  and profile folder, so it never collides with a real Mozc install.
