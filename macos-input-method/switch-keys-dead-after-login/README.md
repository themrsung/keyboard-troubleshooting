# After a login, カタカナ and F18 do nothing until the input method is selected once

**Status:** solved with a login agent (2026-10-23), verified from a cold start.

Source: JIS Korean, commit [`a311669`](https://github.com/team-mirae/jis-korean/commit/a311669).

## Symptom

After logging in, カタカナ (`KeyJISKLangKorean`) and the Korean Key (F18, `KeyFunctionEighteen`) did
nothing until JIS Korean was picked from the input menu once.

## Cause

The key tap and the HID listener (see [korean-key-in-iterm](../korean-key-in-iterm/README.md),
[katakana-lost-by-macos](../katakana-lost-by-macos/README.md)) run inside the input method's
process. macOS starts that process only once JIS Korean is selected in some app, and after a login
the selected source was whatever was last (ABC or US).

## Fix

`make install ENGLISH=1` installs a login agent
(`~/Library/LaunchAgents/me.sjun.inputmethod.JISKorean.login.plist`, from `tools/login-agent.plist`)
that runs `open -g -b me.sjun.inputmethod.JISKorean` at load, the same LaunchServices path the text
system uses. Korean-only builds and uninstall remove it.

Verified: with the input method stopped, kicking the agent started it with the tap and the listener
on.
