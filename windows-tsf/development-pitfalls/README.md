# Development pitfalls (Windows TIPs)

Each cost a build, an install or a test run. Source: FKeyIME,
[`docs/issues/development-notes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/development-notes.md),
[`installer/sandbox/README.md`](https://github.com/themrsung/fkeyime/blob/440d74e/installer/sandbox/README.md),
and the commits named below. Mozc's build pitfalls are in
[../../mozc/bazel-build-on-windows](../../mozc/bazel-build-on-windows/README.md).

## Toolchain

- `Launch-VsDevShell.ps1` wants `amd64`, not `x64`; VsDevCmd looks for `vswhere` on `PATH`; native
  stderr must not abort the script on PowerShell 5.1. FKeyIME's `tools/dev.ps1` handles all three.

## Development install script

| Pitfall | Commit | What was done |
| --- | --- | --- |
| `regsvr32 /u` left the empty `CTF\TIP` category keys and the 32-bit (`WOW6432Node`) CLSID key behind *(measured)* | [`fc0c24b`](https://github.com/themrsung/fkeyime/commit/fc0c24b) | Deleted explicitly on uninstall |
| `Get-WinUserLanguageList`'s list came through `foreach` as a single object, so the lookup of the ko/ja entries never matched: no profiles added, only an empty en-US language | [`402e58b`](https://github.com/themrsung/fkeyime/commit/402e58b) | Iterate over `.ToArray()`; verified on the owner's PC |
| A process with the DLL loaded keeps the file open | [`a079a15`](https://github.com/themrsung/fkeyime/commit/a079a15) | Move the old DLL aside (`fkeyime.dll.old-*`), copy the new one; those processes keep the old build until they restart |
| An open settings window stopped the install the same way | [`8f5d9f8`](https://github.com/themrsung/fkeyime/commit/8f5d9f8) | Moved aside like the DLL |
| `-Option` failed when the options key already existed | [`aa6789f`](https://github.com/themrsung/fkeyime/commit/aa6789f) | Fixed |

## MSI and its user step

- `Start-Process` added a trailing space to the argument, so the settings executable's mode check
  didn't match `--user-install` and the MSI step would have done nothing. The check trims trailing
  spaces now ([`8f5d9f8`](https://github.com/themrsung/fkeyime/commit/8f5d9f8)).
- `InstallLayoutOrTip` with `ILOT_DEFPROFILE` returned success and left the default input method
  override empty *(measured in the Sandbox)*; the value is written directly
  ([`ac48d61`](https://github.com/themrsung/fkeyime/commit/ac48d61)).
- The final page's 370-character text was cut off with "…" (owner); shortened
  ([`ac48d61`](https://github.com/themrsung/fkeyime/commit/ac48d61)).
- `msiexec /x … /qb` (uninstalling Mozc) rebooted the PC without warning, exit 1641
  ([`215dffc`](https://github.com/themrsung/fkeyime/commit/215dffc)). Every msiexec call in the
  Sandbox kit passes `/norestart`.

## Windows Sandbox

- With `vGPU` on, the Sandbox stayed black on the owner's PC while holding the keyboard and mouse
  (Ctrl+Alt+Break released them). The `.wsb` sets `<vGPU>Disable</vGPU>`.
- The Sandbox runs the host's servicing base, which can differ from the host: 24H2 (26100) on a
  25H2 (26200) host.
- The check script looks for the Settings window titled 설정 too, and is kept ASCII for PowerShell
  5.1 ([`9b65909`](https://github.com/themrsung/fkeyime/commit/9b65909)).

## Testing

- The probe's stdout is buffered when redirected; find its window by title instead of reading its
  handle from the output.
- Pressing a key on the real keyboard during a probe run spoils it: one 50-round run gave 77/100
  while the owner pressed a key.
- Injected keys don't reproduce everything: the US layout's LANG1/LANG2 key-up form needed the real
  keyboard ([lang1-lang2-per-layout](../lang1-lang2-per-layout/README.md)); the source's rule after
  [injected-right-win-holds-input](../injected-right-win-holds-input/README.md) is to inject Win
  keys only in a VM.
- A Mozc test that picked a non-first candidate changed later runs
  ([../../mozc/learning-changes-test-results](../../mozc/learning-changes-test-results/README.md)).

## Escapes mangled in written files

Typing escapes (`\n`, `\u`) through shell heredocs got mangled several times; the source's rule is
to write patch scripts to files. Three commits fixed paths in docs that had lost characters:
[`d799711`](https://github.com/themrsung/fkeyime/commit/d799711) ("the M0 log path, whose
backslashes had become form feeds": `%ProgramData%keyidekeyide.log` for
`%ProgramData%\fkeyide\fkeyide.log`), [`506847d`](https://github.com/themrsung/fkeyime/commit/506847d)
(the Mozc pipe name `\\.\pipe\…` had lost its backslashes),
[`9660bc0`](https://github.com/themrsung/fkeyime/commit/9660bc0) (`@…keyime.dll` for
`@…\fkeyime.dll`) and [`6f23b78`](https://github.com/themrsung/fkeyime/commit/6f23b78). The
mechanism for the `\f` cases is reproduced in [repro-form-feed](repro-form-feed/README.md); which
tool wrote the mangled text isn't recorded.
