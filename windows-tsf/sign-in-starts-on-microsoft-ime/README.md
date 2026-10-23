# After a reboot, the session starts on the Microsoft Korean IME

**Status:** open (last measured 2026-10-18). The default input method override doesn't decide it
on the owner's PC (measured twice).

Source: FKeyIME, [`docs/issues/sign-in-starts-on-microsoft-ime.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/sign-in-starts-on-microsoft-ime.md),
commits [`8004c29`](https://github.com/themrsung/fkeyime/commit/8004c29), [`3aa40b0`](https://github.com/themrsung/fkeyime/commit/3aa40b0),
[`215dffc`](https://github.com/themrsung/fkeyime/commit/215dffc), [`ac48d61`](https://github.com/themrsung/fkeyime/commit/ac48d61); spec §3.

## Symptom

After restarting the PC, FKeyIME wasn't active. F18 / F20 went through the AutoHotkey script to
the Microsoft IMEs until the owner picked FKeyIME (Win+Space, or FKeyIME ENG in the taskbar's
input menu). From then on everything worked.

## First occurrence and the first fix (`8004c29`)

The session started with the first input method in the language list: ko (Microsoft Korean IME
first), ja, en-US *(measured)*. Fix applied: the default input method override set to FKeyIME EN.

```powershell
Set-WinDefaultInputMethodOverride -InputTip "0409:{66749D2A-1770-43D3-A269-A051B5BC1AAA}{8F61A2C0-75BC-4042-B739-CC7D63B542E5}"
```

It was marked solved without a reboot to confirm it. The source calls that a mistake.

## Second occurrence (`3aa40b0`, reboot at 21:50, 2026-10-17)

State measured right after, unchanged in between:

| | Value |
| --- | --- |
| Language list | ko: Microsoft Korean IME, then FKeyIME KO; ja: Microsoft Japanese IME, then FKeyIME JA; en-US: FKeyIME EN only |
| Override | FKeyIME EN (`Get-WinDefaultInputMethodOverride`, and `InputMethodOverride` under `HKCU\Control Panel\International\User Profile`) |
| `HKCU\Keyboard Layout\Preload` | 1 `00000412`, 2 `00000409`, 3 `00000411` |
| Language bar | `IsLegacyLanguageBar` False, `IsLegacySwitchingMode` False |
| AutoHotkey | The FKeyIME-aware script, as a logon task; it does nothing at startup |

FKeyIME's log: no process asked for FKeyIME for about 5 minutes after boot; the first entry was
`SearchHost.exe DllGetClassObject` at 304.9 s, then the owner's picks. So Windows didn't try and
fail to load it; it chose the Microsoft IME *(measured: absence of log entries; the mapping to the
clock is inferred)*.

## Third occurrence (`215dffc`, unplanned reboot at 01:33, 2026-10-18)

A Mozc uninstall rebooted the PC. Same settings. No log entry at all from boot to 01:37:31 while
the owner was using the PC *(measured)*.

## Related: setting the override from an installer (`ac48d61`)

`InstallLayoutOrTip` with `ILOT_DEFPROFILE` returned success but left the override empty
*(measured in Windows Sandbox)*. The MSI's user step now writes `InputMethodOverride` itself, as
`Set-WinDefaultInputMethodOverride` does; measured set on install and cleared on uninstall.

## Cause

Not known. Hypotheses the source lists, none tested:

1. Windows restores the input method active when the previous session ended, and the override
   applies only when there's nothing to restore.
2. The override is read only when the default language's first input method is used, and the
   first language wins.
3. The override applies to new apps, not the shell processes that start before it's read.

Tests the source lists as next, not done: move en-US to the top of the list and reboot; keep the
order, switch to FKeyIME EN before shutting down, reboot. Each needs the owner's OK on that PC, or
a VM.
