# Reproduction: `\f` in a Windows path becomes a form feed

What this checks: that a Windows path containing `\f` (as in `\fkeyime`) written through a writer
that interprets backslash escapes comes out with U+000C (form feed) in place of `\f`, which
renders as nothing and leaves `%ProgramData%keyidekeyide.log`, the text FKeyIME's commit
`d799711` fixed. Which writer produced the original isn't recorded; this only shows the mechanism.

Tested 2026-10-23 on Linux, bash 5 (`printf` builtin) and Python 3.

```sh
printf '%s\n' 'Raw log: `%ProgramData%\fkeyide\fkeyide.log`.' > intended.md
printf 'Raw log: `%%ProgramData%%\fkeyide\fkeyide.log`.\n' > via-printf-format.md
python3 -c 'open("via-python.md","w").write("Raw log: `%ProgramData%\fkeyide\fkeyide.log`.\n")'
cat -A intended.md via-printf-format.md via-python.md
grep -lP '\x0c' *.md
```

Result:

```
Raw log: `%ProgramData%\fkeyide\fkeyide.log`.$
Raw log: `%ProgramData%^Lkeyide^Lkeyide.log`.$
Raw log: `%ProgramData%^Lkeyide^Lkeyide.log`.$
via-printf-format.md
via-python.md
```

`^L` is the form feed. The path passed as a `%s` argument stayed intact; the path inside the
`printf` format string and inside a non-raw Python string lost its `\f`. `grep -P '\x0c'` finds the
damaged files.
