# Enabling, disabling and selecting input sources from code (macOS 27)

**Status:** observations, each with the workaround the project took.

Source: JIS Korean, commits [`3feec68`](https://github.com/team-mirae/jis-korean/commit/3feec68),
[`0a466c2`](https://github.com/team-mirae/jis-korean/commit/0a466c2),
[`b433fed`](https://github.com/team-mirae/jis-korean/commit/b433fed),
[`e8b47b0`](https://github.com/team-mirae/jis-korean/commit/e8b47b0),
[`e236c57`](https://github.com/team-mirae/jis-korean/commit/e236c57);
[`macos-katakana-and-eisu.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-katakana-and-eisu.md),
[`macos-input-method-not-launching.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-input-method-not-launching.md).

| Observation | Where | Taken as |
| --- | --- | --- |
| `TISEnableInputSource` / `TISDisableInputSource` return `noErr` on macOS 27.0.1, but the change doesn't persist (also not in `com.apple.HIToolbox`) | `0a466c2` | Add and remove input sources in System Settings; `TISSelectInputSource` works |
| Disable then enable back to back: the system could take the pair as no change, and running apps stayed cut off until every mode was toggled by hand | `3feec68` | `register.swift` waits 1 s on the run loop after each step; reselecting retries for 10 s and says which source needs selecting if it fails |
| The programmatic disable/enable pair never posts `AppleEnabledInputSourcesChangedNotification` (only observer registrations seen in `distnoted`); removing and re-adding in System Settings does | `e8b47b0` | Running apps need the re-add, a relaunch or a logout after an update ([reinstall-stops-launching](../reinstall-stops-launching/README.md)) |
| `TISSelectInputSource` from the input method's own process, inside the key handler, could cut the app's session off (Terminal printed F18) | `b433fed` | Moved after the key; the field switches in place first |
| The same call, even after the key, left Chrome typing through the layout without asking the input method | `e236c57` | `-[IMKTextInput selectInputMode:]` through the session when one of the input method's own modes is selected ([bare-jamo-in-chrome](../bare-jamo-in-chrome/README.md)) |
| `defaults read com.apple.HIToolbox AppleEnabledInputSources` lacked JIS Korean while the menu and TIS had it | not-launching doc | Ask TIS from a fresh process (`TISCreateInputSourceList(nil, false)`) |
