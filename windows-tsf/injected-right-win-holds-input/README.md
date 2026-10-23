# After a test injected Right Win, mouse, trackpad and Tab stopped working

**Status:** solved by restarting the Start menu process; the test was removed (2026-10-17).

Source: FKeyIME, [`docs/issues/start-menu-holds-input.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/start-menu-holds-input.md),
commit [`aa6789f`](https://github.com/themrsung/fkeyime/commit/aa6789f).

## Symptom

The USB mouse, the pointing stick and the trackpad stopped responding, and Tab didn't move focus,
from any keyboard. Keys still reached the app in front.

## Cause *(measured)*

A probe case ("TAP cycle with Right Win") injected Right Win taps. They opened the Start menu, and
its process (`StartMenuExperienceHost`) stayed in front, covering the screen under the cursor and
holding the input, after the visible menu had been closed with Escape. No stuck modifiers, no
cursor clipping. (A hung Settings window at the same time was unrelated.)

## Fix

```powershell
Stop-Process -Name StartMenuExperienceHost -Force
```

Windows starts it again at once, and input came back. The Right Win case was removed from the
probe; the source's rule is never to inject Win keys on a real PC, only in a VM.
