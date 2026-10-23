# Loading the dictionary blocked the first focus

**Status:** solved in JIS Korean's Windows shell.

Source: JIS Korean, [`docs/troubleshooting/windows-tsf-notes.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/windows-tsf-notes.md),
last section.

Parsing the embedded hanja dictionary took 80–110 ms and the predictor 16–31 ms per process
*(measured)*, on activation, in every app's process. Both now load on a thread-pool thread when
the TIP activates; the first key waits only if they aren't ready yet.

The macOS shell had a related key-path cost, fixed in JIS Korean
[`d8d9577`](https://github.com/team-mirae/jis-korean/commit/d8d9577): the suggestion list asked
for the caret rectangle on every key, a blocking IPC into Chrome's page process; it moved off the
key path.
