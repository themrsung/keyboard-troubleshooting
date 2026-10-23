# An AutoHotkey script's hook takes the F-keys before the TIP

**Status:** solved in the script, in three rounds (2026-10-17).

Source: FKeyIME, [`docs/issues/autohotkey-takes-the-f-keys.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/autohotkey-takes-the-f-keys.md),
[`docs/api.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/api.md), spec §3 and §6.1,
commits [`7652657`](https://github.com/themrsung/fkeyime/commit/7652657),
[`a079a15`](https://github.com/themrsung/fkeyime/commit/a079a15),
[`0691dd6`](https://github.com/themrsung/fkeyime/commit/0691dd6). The script is
hhkb-ekj-trilingual v1.5.2's, which switched the Microsoft IMEs with F16–F20.

## Round 1: the hook wins

With the v1.5.2 script running, F18–F20 never reached the TIP *(measured in M0)*: another program's
low-level keyboard hook gets the keys first, and a TIP only sees keys while one of its own profiles
is active.

Fix (`a079a15`): FKeyIME exports an API (`FKeyImeQueryWindow`, `FKeyImeQueryThread`, reading a
session-wide shared-memory table with one slot per thread that has an FKeyIME profile active). The
script asks whether FKeyIME is active in the focused window and lets the keys through if it is.
Measured with the probe's `--handoff`: 200/200 presses to FKeyIME, the API right 200/200, and
100/100 to AutoHotkey with a Microsoft IME, over 50 rounds.

## Round 2: switching to Korean landed back in FKeyIME

With a Microsoft IME chosen, the script switches language, and Windows picks that language's
**last-used** input method, which can be FKeyIME's. The first F-key after leaving FKeyIME landed
back in it *(measured)*. Fix (`a079a15`): if FKeyIME is active right after the switch, the script
selects the Microsoft IME explicitly.

## Round 3: one F-key pulled the whole session back to Microsoft

That correction is session-wide. One F-key in a window without FKeyIME (Notepad, during a Hanja
test) moved the whole session to the Microsoft IMEs; every window stayed there, FKeyIME never
loaded in the owner's apps again, and the script kept taking the keys *(measured)*.

Fix (`0691dd6`): the script reads the session's input method from its own thread
(`ITfInputProcessorProfileMgr::GetActiveProfile`, which follows session changes, measured), and
Win+Space decides:

- FKeyIME chosen: the script never takes F16–F20. A window still on a Microsoft IME is moved to
  FKeyIME's profile for the key, and the key is sent again once FKeyIME is active there.
- A Microsoft IME chosen: v1.5.2's switching.

Measured with the deployed script: FKeyIME 120/120, Microsoft chosen 60/60 to AutoHotkey, a stuck
window taken over by FKeyIME 30/30 (`fkeyime_probe.exe --handoff 30`).

After a reboot this depends on which input method the session starts on:
[sign-in-starts-on-microsoft-ime](../sign-in-starts-on-microsoft-ime/README.md).
