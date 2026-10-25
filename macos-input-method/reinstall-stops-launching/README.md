# After a reinstall, the input method never launches in running apps

**Status:** cause confirmed for the first form (2026-10-19). The milder form after every update is
still there: running apps need the input source removed and re-added, a relaunch, or a logout.

Source: JIS Korean, [`docs/troubleshooting/macos-input-method-not-launching.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-input-method-not-launching.md),
commits [`3feec68`](https://github.com/team-mirae/jis-korean/commit/3feec68),
[`d8d9577`](https://github.com/team-mirae/jis-korean/commit/d8d9577),
[`e8b47b0`](https://github.com/team-mirae/jis-korean/commit/e8b47b0),
[`a311669`](https://github.com/team-mirae/jis-korean/commit/a311669). macOS 27.0, ad hoc signed builds.

## Symptom

- With JIS Korean selected, typing gave Latin letters (the previous layout, ABC).
- No `JISKorean` process, no crash report, nothing in the input method's own log.
- The input menu's JIS Korean section was greyed out with a dotted placeholder.
- `make install`, `make uninstall && make && make install`, switching with F18
  (`KeyFunctionEighteen`, through Hammerspoon) or Ctrl+Space (`KeyUniversalControl` +
  `KeySpacebar`): none helped.

## How a launch looks when it works (from the unified log)

The source reconstructed the chain from `imklaunchagent`'s log, since no public document says who
launches an input method: a client app's text session activates the selected source and asks
`imklaunchagent` for the input method's XPC endpoint; with no endpoint, `imklaunchagent` launches
the bundle through LaunchServices (`launchViaCSUA`), launchd spawns it, and the input method's
`IMKServer` registers its endpoint. When the input method dies, `imklaunchagent` logs
`IMDiedCallback … exitStatus (15)` (SIGTERM from `killall` in `make install`).

## What happened

Ten installs in a row (`rm -rf` then `cp -R`, back to back) launched fine. The one that broke it
was `make uninstall`, then a full rebuild (about a minute), then `make install`: the bundle in
`~/Library/Input Methods` was absent for about a minute while the source was enabled and selected.
LaunchServices logged the bundle id as unregistered, and the menu agent rebuilt the input menu.
After that, selecting JIS Korean never produced an endpoint request in `imklaunchagent` at all.

## What was checked and ruled out

| Suspect | Result |
| --- | --- |
| Code signing / Gatekeeper (`spctl -a` said rejected; amfid logged ad hoc) | `open -b me.sjun.inputmethod.JISKorean` launched the same bundle; amfid and syspolicyd allowed it |
| Four LaunchServices registrations for the bundle id (two of them stale paths) | Launches had worked with them present; cleaning them with `lsregister` changed nothing |
| Crash at launch | No reports anywhere; launchd never spawned the process |
| The Keyboard Viewer layout, `TISIconLabels`, per-app settings code in the build | The last working build already had them |
| `overrideKeyboard(withKeyboardNamed:)` stalling the input method | Runs in `activateServer`, so it can't prevent a launch |
| `imklaunchagent`'s "Refusing connection name for bundle: unrecognized 'InputMethodConnectionName' value" | Also logged right before successful launches; Apple's own names have the same shape |
| A leftover launchd endpoint | `launchctl print gui/$(id -u)` had none |
| Source not enabled | A fresh process's `TISCreateInputSourceList(nil, false)` listed it as enabled and selectable |
| Hammerspoon holding a stale reference | Its select returned `true` and the selection changed system-wide |

Probes: selecting JIS Korean from Hammerspoon (twice) changed the system-wide selection, but no
process appeared and `imklaunchagent` logged nothing; `CursorUIViewService` logged that the input
mode of the selected source was nil at that moment.

## Cause, as recorded

*Measured:* after the long gap, a select never reached `imklaunchagent`. *Inferred* (consistent
with every observation, not proven by one line): each process caches the input-source catalog and
updates it on notifications. When the bundle vanished, running processes dropped the source.
`TISRegisterInputSource` (what `make install` runs) rebuilt the on-disk cache, so new processes
saw it, but it doesn't tell running processes to reload. Earlier the same day, removing and
re-adding the source in System Settings had been followed by normal launches. The source left two
neighbouring hypotheses open: the stale party being `imklaunchagent`'s own table, or
`TextInputSwitcher`'s.

Confirmed at 17:15: after re-adding the source by hand, System Settings worked but TextEdit
(running for two days) still typed ABC and never asked for the endpoint. Quitting and reopening
TextEdit gave 안녕. So re-registering, and removing and re-adding, didn't refresh apps that were
running when the bundle vanished; relaunching the app or logging out did.

## Fixes that shipped (commit `d8d9577`) and what they did

- **B, atomic install** (`mac/Makefile`): the new bundle is copied to `.JISKorean.app.new` and
  swapped in with `mv`, so the path is never absent. This stops the first form.
- **C, re-toggle after registering** (`mac/tools/register.swift`): snapshot whether the source was
  enabled and selected, then disable, settle, enable and reselect it. Earlier, in
  [`3feec68`](https://github.com/team-mirae/jis-korean/commit/3feec68): back to back, the system
  could take the off/on pair as no change, leaving running apps cut off until the user toggled
  every mode by hand; each step now waits 1 s on the run loop, and reselecting retries for 10 s.

What C does not do (2026-10-23, from watching `distnoted` through a real `make install` and a
standalone `register.swift` run): only observer *registrations* of
`AppleEnabledInputSourcesChangedNotification` were seen, never a *posted* one. The programmatic
disable/enable pair doesn't send the broadcast that makes running apps reload their catalog.
Removing and re-adding the source in System Settings does. So after every update, apps that were
already running keep their binding to the replaced process until the source is re-added, the app
is relaunched, or the user logs out. Not reproduced by live typing in that session (see the
caveat below); concluded from the install's `distnoted` and `imklaunchagent` evidence.

[`a311669`](https://github.com/team-mirae/jis-korean/commit/a311669) corrected the README's
"after later installs it reloads by itself" to say the same.

## Caveat recorded for anyone repeating the probes

A select only makes the frontmost app activate the input method, and only once that app has a
focused text field and gets a key. A select from a script with no keystroke proves nothing either
way. A terminal-spawned test app never became frontmost in that session.

## Commands the source used

```sh
/usr/bin/log show --last 30m --info --predicate 'process == "imklaunchagent"' --style compact
open -b me.sjun.inputmethod.JISKorean; sleep 3; cat ~/Library/Logs/JISKorean.log; pkill -f 'MacOS/JISKorean$'
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump \
  | grep -B3 -A3 'me.sjun.inputmethod.JISKorean' | grep -E '^path:'
```

See also [diagnostic-gotchas](../diagnostic-gotchas/README.md) and
[tis-enable-disable](../tis-enable-disable/README.md).
