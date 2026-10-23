# The conversion server aborts every 3 minutes

**Status:** solved with a Mozc patch; regression test in FKeyIME (2026-10-17).

Source: FKeyIME, [`docs/issues/conversion-server-crashes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/conversion-server-crashes.md),
spec §9 ("Watch dog"), commit [`33209e2`](https://github.com/themrsung/fkeyime/commit/33209e2).

## Symptom

The event log showed `fkeyime_mozc_server.exe` crashing: exception `0xC0000409` in `ucrtbase.dll`
at offset `0xa527e`, which is `abort()`. Conversion kept working because the TIP restarted the
server on the next Space; it showed only as a short delay.

## Cause *(measured)*

Both crashes (18:01 and 18:57) came 183–184 s after the server started. Every 180 s Mozc's session
watch dog connects to its own server with Mozc's client, and that client only accepts a server at
Mozc's install path (`SystemUtil::GetServerPath`). The renamed server runs from FKeyIME's folder,
so the Cleanup call and three pings failed and the watch dog called `LOG(FATAL)`.

Reproduced in 15 s with `--watch_dog_interval=10`.

## Fix

`third_party/patches/mozc-fkeyime-server-path.patch` in FKeyIME: when the process is the server
(`fkeyime_mozc_server.exe`), its own folder is the server directory. `tools/test-mozc-server.ps1`
runs the server with a 10 s watch dog for 30 s: it fails on the unpatched server (exit
`0xC0000409` after 15 s) and passes on the patched one, which also survived 45 s and still
converted.
