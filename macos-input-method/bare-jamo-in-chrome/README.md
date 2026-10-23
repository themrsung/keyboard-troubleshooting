# Fields commit bare jamo (`ㅂㅏㄷㅏ` for `바다`), mostly in Chrome

**Status:** fixed in two steps (2026-10-23); confirmed by typing in Chrome after the second. Two
look-alike cases outside the input method stay as they are.

Source: JIS Korean, [`docs/troubleshooting/macos-bare-jamo-in-chrome.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-bare-jamo-in-chrome.md),
commits [`0d51744`](https://github.com/team-mirae/jis-korean/commit/0d51744),
[`d8d9577`](https://github.com/team-mirae/jis-korean/commit/d8d9577),
[`e236c57`](https://github.com/team-mirae/jis-korean/commit/e236c57), and
[`b433fed`](https://github.com/team-mirae/jis-korean/commit/b433fed) for the earlier select change.
macOS 27.0.

## Symptom

With a Korean mode current, some fields typed the jamo apart (`다락방` → `ㄷㅏㄹㅏ…`,
`바다사자` → `ㅂㅏㄷㅏㅅㅏㅈㅏ`). Per field, not per app, and it stuck: one Chrome tab or the
omnibox composed while another field, or the same field later, kept committing bare jamo.

## The diagnostic that localizes it

JIS Korean's engine puts an implied ㅇ on a vowel with no initial (`ㅏ` → `아`). So a bare `ㅏ` on
screen is not something the engine built and committed early: if the engine had seen the keys and
committed after every one, the result would be `ㅂ아ㄷ아…`. A bare `ㅏ` means the key never went
through the engine, and the Korean mode's keyboard layout (which carries jamo legends for Keyboard
Viewer) typed it. See [repro/](repro/README.md), which checks this against the engine.

## Attempt 1 (`0d51744`): keep each field's engine on the current mode

Cause found then: カタカナ / F18 switched the last activated controller, which in Chrome is often
not the field being typed in. That field's engine stayed in JIS English while the Korean layout
typed its keys as jamo. Fix: each controller resyncs to the current mode on its next key, the key
tap targets the controller that last got a key, and selections made outside JIS Korean update the
current mode. **Didn't end it.**

## Attempt 2 (`d8d9577`): re-sync the layout too

Cause found then: `overrideKeyboard(withKeyboardNamed:)` names the layout **per client process,
not per field**, and macOS drops the override when the input method deactivates in that app.
Chrome's omnibox and page are separate IMK controllers that activate out of order. One field could
name the Korean layout for the whole process while another field's engine, on an English mode,
passed its letters on unconsumed; the Korean layout typed them. Three selection races fed the
same mechanism:

- an out-of-order activation could revert the current mode to the source being left;
- AppKit suspends distributed notifications for an app that isn't active (an input method never
  is), so under the default coalescing macOS's "selected source changed" notice could be held back;
- the current mode started at Mode A at launch whatever was selected, and an install restarts the
  input method.

Fix: `syncMode` re-names the field's layout when the app's last-named layout differs; the layout
is tracked per app and forgotten on deactivate; a requested selection counts as made until macOS
reports it (2 s cap); the current mode starts from the selected source; the notification is
observed with `.deliverImmediately`; the switch key acts on the field in the frontmost app. Also
moved off the key path: the suggestion list's caret query, which was a blocking IPC into Chrome's
page process on every key. **Didn't end it either.**

## Attempt 3 (`e236c57`): select through the app's session

With the diagnostic log on, after カタカナ switched Chrome to Korean, Chrome's caret moved several
characters while the input method logged no `key in …` line at all, not even for ¥ (which the
engine always consumes in Korean). Every `key in` line was from an English mode. Switching to
English (英数) didn't break delivery. So after the switch into Korean, Chrome had stopped sending
keys to the input method and typed them through the layout itself.

Cause: the switch keys selected the target with `TISSelectInputSource` from the input method's own
process. The code already noted that doing this inside `handle(_:client:)` could cut the session
off (Terminal then got the keys itself, and printed F18): commit `b433fed` had only moved the call
to after the key. IMK's own way for an input method to change its mode is
`-[IMKTextInput selectInputMode:]` (Swift `selectMode(_:)`), through the session; JIS Korean had
never used it.

Also found in the log: a late notice of the previous 英数 selection arrived before the async select
ran, and the mode bounced A → A_QWERTY → A, because the pending selection was only recorded inside
the async block.

Fix: with one of JIS Korean's modes selected and the field's session at hand, the switch keys use
`client.selectMode(sourceID)`; `TISSelectInputSource` stays only when coming from another input
source and for the public API. The pending selection is recorded synchronously
(`InputModes.expect`). Confirmed by typing in Chrome: `selected A in the session in
com.google.Chrome`, then `consumed true, engine mode 0` for every key, no bare jamo.

## Two cases that look the same and aren't the input method's

Both are keys that never reach any input method:

- **Password fields.** macOS bypasses input methods for secure text entry; the layout types every
  key. Apple's Korean input method does the same.
- **Chrome 152–156, a field that was ever a password.** Chromium returns a nil
  `NSTextInputContext` once a field has had `TEXT_INPUT_FLAG_HAS_BEEN_PASSWORD` (Chromium issue
  567321058), even after it turns back into a normal field. Fixed in Chrome 157; reloading the page
  recreates the field.

## Telling the cases apart (the source's method)

```sh
defaults write me.sjun.inputmethod.JISKorean DiagnosticLog -bool true   # logs no text
```

Type a few keys in the failing field and read `~/Library/Logs/JISKorean.log`. `key in <app>:
consumed true, engine mode 0, layout JISKorean, current A` per key means the engine has them. Lines
with `consumed false` and an English engine mode or layout are the per-app desync. No `key in`
line at all while bare jamo appear means the key never reached the input method (password field,
or Chrome 152–156). `activated in …` and `layout resync … ->` lines show the decisions as fields
activate.

## Limit recorded by the source

The fixes in attempts 1 and 2 came from code analysis, the implied-ㅇ diagnostic and the log; the
end-user symptom could not be driven from that session (a terminal-spawned test app never becomes
frontmost). Attempt 3 was confirmed by the user typing in Chrome.
