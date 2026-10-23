# Windows Settings doesn't list the TIP under the language's keyboards

**Status:** open, narrowed (2026-10-18). After an MSI install in Windows Sandbox the TIP is listed
under all three languages, but with **Remove** only, no keyboard options. On the owner's PC
(development install) it isn't listed at all.

Source: FKeyIME, [`docs/issues/settings-doesnt-list-fkeyime.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/settings-doesnt-list-fkeyime.md),
commits [`4005aa7`](https://github.com/themrsung/fkeyime/commit/4005aa7),
[`8f5d9f8`](https://github.com/themrsung/fkeyime/commit/8f5d9f8),
[`bb21778`](https://github.com/themrsung/fkeyime/commit/bb21778),
[`215dffc`](https://github.com/themrsung/fkeyime/commit/215dffc),
[`ac48d61`](https://github.com/themrsung/fkeyime/commit/ac48d61),
[`9b65909`](https://github.com/themrsung/fkeyime/commit/9b65909).

## Symptom

Settings → Time & language → Language & region → 한국어 ⋯ → Language options → Installed keyboards
listed only "Microsoft 입력기". FKeyIME KO wasn't there, so its keyboard options (meant to open the
TIP's settings window through `ITfFnConfigure`) couldn't be reached. FKeyIME KO was in the user's
language list and in the taskbar's input menu *(measured: the page read with UI Automation)*.

## Registry differences found first

Under `HKLM\SOFTWARE\Microsoft\CTF\TIP\<CLSID>\LanguageProfile\0x00000412\<profile>`, compared with
the Microsoft IME: no `Display Description`, `IconFile` pointing at a DLL with no icon resource,
and `Enable` 1 where the Microsoft IME has 0.

## What was tried on the owner's PC, each followed by reading the Settings page

| Change | Listed? |
| --- | --- |
| `SetLanguageProfileDisplayName` with a string resource, and an icon in the DLL | No |
| No substitute layout (every profile had named the Japanese layout `0x04110411`; `RegisterProfile` keeps an old value, so it was deleted) | No |
| Per-user `InstallLayoutOrTip` for the three profiles: returned success, but no per-user `HKCU\Software\Microsoft\CTF\TIP` entry appeared (the Microsoft IMEs have one) | No |
| TIP-level `Enable = "1"` through the legacy `ITfInputProcessorProfiles::Register`, as Mozc calls it | No |
| Test only: per-profile `Enable` values removed (Mozc has none), then restored | No |
| With the owner's OK, the TSF key exported first: the EN and KO profile keys deleted so only JA remained under the CLSID, like Mozc's single profile; restored afterwards by re-registering | No |

Both display strings load (`SHLoadIndirectString`: "FKeyIME JA", "Mozc").

**A third-party IME is listed** *(measured)*: with Mozc 3.35.6354 (built locally, `Mozc64.msi`)
installed, Japanese → Installed keyboards showed "Mozc 입력기" with its own keyboard options; FKeyIME
JA, in the same list, wasn't shown. So the cause is specific to FKeyIME or that PC. Side effect:
`msiexec /x … /qb` on Mozc rebooted the PC without warning (exit 1641); the source says always pass
`/norestart`.

## Windows Sandbox (24H2, build 26100), FKeyIME's own MSI

- First pass: FKeyIME KO **listed**, with Remove only.
- Third pass: listed under Korean, Japanese and English, each with Remove only. The TIP's log had
  no `DllGetClassObject` from Settings, so Settings decides about keyboard options without loading
  the TIP *(inferred; the log also stays empty when no app has used the TIP yet)*.
- No Microsoft documentation on how Settings decides was found (searched 2026-10-18).

The source's remaining hypotheses for the owner's PC: its development install, the profiles first
entering the language list through `Set-WinUserLanguageList`, or 25H2. Its recorded next idea:
install Mozc in the Sandbox next to FKeyIME and diff what Settings could read (`CTF`,
`Control Panel\International`, the package's file properties). Not done.

## Workaround in use

The settings window is opened from the Start menu shortcut the MSI adds, or by running the
settings executable. `ITfFnConfigure::Show` itself works (measured through COM).
