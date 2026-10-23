# Mozc (as a conversion server for another TIP)

FKeyIME converts kana to kanji by talking to a renamed, bundled `mozc_server` over Mozc's session
pipe, with its own small client (its "Option B"). These are the problems that setup met, from
FKeyIME's history and docs up to [`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e)
(2026-10-17/18), Mozc at the commit FKeyIME pins (`0136c357`, "3.35.6354"), on Windows 11 Pro 25H2.

- [server-watchdog-abort](server-watchdog-abort/README.md): the server aborted every 180 s
  because Mozc's watch dog checks the server's install path.
- [server-wont-run-standalone](server-wont-run-standalone/README.md): the server refused to start
  outside Mozc's sandbox, then ignored every key.
- [bazel-build-on-windows](bazel-build-on-windows/README.md): symlinks, the transitioned output
  folder, and CRLF patches. Has a reproduction of the CRLF case.
- [learning-changes-test-results](learning-changes-test-results/README.md): picking a non-first
  candidate in a test changed the order for later runs.
