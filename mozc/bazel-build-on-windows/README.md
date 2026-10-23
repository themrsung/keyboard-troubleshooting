# Building Mozc with Bazel on Windows

**Status:** builds, with the workarounds below (2026-10-17).

Source: FKeyIME, [`docs/toolchain.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/toolchain.md),
[`docs/issues/development-notes.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/development-notes.md),
commit [`a31488c`](https://github.com/themrsung/fkeyime/commit/a31488c). i7-1165G7, 16 GB RAM,
Mozc `0136c357`.

## Symlinks

Mozc's `.bazelrc` sets `startup --windows_enable_symlinks`. Bazel then failed after 25 s with
`createSymbolicLinkW failed (permission denied). Either Windows developer mode or admin privileges
are required.` The startup flag `--nowindows_enable_symlinks` makes Bazel copy instead, without a
system change, and the build worked:

```powershell
bazelisk --nowindows_enable_symlinks build package --config release_build
```

Developer Mode would also do it; the source leaves that to the owner, as a system setting.

## The server's output folder

`//server:mozc_server_win` builds in a transitioned configuration, so `bazel info bazel-bin` points
at the wrong folder. FKeyIME's build script asks `bazel cquery --output=files` for the file.

## Patches rejected by `git apply`

Patch files written by PowerShell got CRLF line endings, and `git apply` rejected them. FKeyIME
set `*.patch` to `eol=lf` in `.gitattributes` and writes patches from Git Bash. Reproduced in
[repro-crlf-patch](repro-crlf-patch/README.md).

## Measured build times

| Step | Time |
| --- | --- |
| Fetch (blobless clone, 201 MB tree) | 11 s |
| `update_deps.py` (Bazel 9.0.2, LLVM 20.1.1, MSYS2, Ninja, Qt 6.9.1 sources; 992 MB cache) | 11 min |
| `build_qt.py` (two CMake/Ninja stages, MSVC 19.44) | 17 min 43 s |
| `bazelisk build package` (5,115 actions, clang-cl; about 2,500 warnings, no errors) | 28 min |
| The server alone, warm cache | about 1 min |

Output `Mozc64.msi`, 26.4 MB. Qt is needed only for `mozc_tool`, not the server *(inferred from the
BUILD files)*. Disk: everything under `third_party/mozc` and Bazel's output base
(`%USERPROFILE%\_bazel_<user>`); `bazel clean --expunge` frees the latter.
