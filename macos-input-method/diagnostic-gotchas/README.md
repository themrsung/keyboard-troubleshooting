# Diagnostic gotchas on macOS

Four that cost time while debugging the input method. Source: JIS Korean,
[`docs/troubleshooting/macos-input-method-not-launching.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-input-method-not-launching.md),
"Diagnostic recipes"; `mac/README.md`, "Notes".

- **`log` is a zsh builtin.** `log show …` in zsh runs the builtin (`log: too many arguments`, or
  silently empty in a pipeline). Write `/usr/bin/log`.
- **`pgrep -f JISKorean.app` matches your own shell** when the command line contains that string.
  Use `pgrep -f 'MacOS/JISKorean$'`. Reproduced on Linux below.
- **`com.apple.HIToolbox`'s `AppleEnabledInputSources` isn't the live state** for third-party
  input methods: it lacked JIS Korean while the input menu and TIS had it. Ask TIS from a fresh
  process.
- **Most text-input log lines are `<private>`.** Filter by process and read the shape of the
  sequence.

## Reproduction: `pgrep -f` matching the shell that runs it

Tested 2026-10-23 on Linux with `pgrep` from procps-ng 4.0.4 and bash; no `JISKorean` process
exists there. macOS's `pgrep` wasn't available to test.

```sh
bash -c 'pgrep -fl JISKorean.app; echo "exit $?"'
bash -c 'pgrep -fl "MacOS/JISKorean$"; echo "exit $?"'
```

Result:

```
1169 bash
1172 bash
exit 0
exit 1
```

The first form found two `bash` processes (the shell running the command, and its parent, whose
command lines both contain `JISKorean.app`) and exited 0 with no `JISKorean` running. The anchored
form found nothing and exited 1. (The numbers are process ids and will differ.)
