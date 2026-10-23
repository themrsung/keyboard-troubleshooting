# Windows TSF text input processors

Problems met while building two TSF text input processors (TIPs) on Windows 11 Pro 25H2 (build
26200): [FKeyIME](https://github.com/themrsung/fkeyime) (English / Korean / Japanese switched with
F17–F20, kanji through a bundled Mozc server) and the Windows shell of
[JIS Korean](https://github.com/team-mirae/jis-korean) (`windows/`). Collected from FKeyIME's
history and `docs/issues/` up to [`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e)
(2026-10-18), and JIS Korean's `docs/troubleshooting/windows-tsf-notes.md` and history up to
[`72dcc4b`](https://github.com/team-mirae/jis-korean/commit/72dcc4b). The owner's PC: HHKB Studio
JIS. *Measured*, *inferred* and *hypothesis* are as the source recorded them.

## Loading, installing, settings

- [running-apps-keep-old-tip](running-apps-keep-old-tip/README.md): apps running during an
  install never load the TIP, or keep the old build; settings read only on focus. Solved.
- [sign-in-starts-on-microsoft-ime](sign-in-starts-on-microsoft-ime/README.md): after a reboot the
  session starts on the Microsoft Korean IME, override or not. **Open.**
- [settings-doesnt-list-tip](settings-doesnt-list-tip/README.md): Windows Settings doesn't list the
  TIP under the language's keyboards, or lists it without keyboard options. **Open.**
- [packaged-apps-read-hklm](packaged-apps-read-hklm/README.md): packaged apps don't see the user's
  `HKCU\Software\<tip>` key.
- [substitute-layout-ignored](substitute-layout-ignored/README.md): a profile's substitute layout
  doesn't change which layout types.

## Compositions and keys

- [imm-layer-ends-korean-composition](imm-layer-ends-korean-composition/README.md): classic apps
  end a Korean composition at once unless it's an interim character; what works for a long one.
- [syllable-doubled-after-profile-switch](syllable-doubled-after-profile-switch/README.md):
  switching profile right after a commit delivers a syllable twice.
- [eaten-key-never-reaches-app](eaten-key-never-reaches-app/README.md): a key eaten in
  `OnTestKeyDown` and handed back later is lost.
- [korean-openclose-compartment](korean-openclose-compartment/README.md): Windows closes the
  Korean open/close compartment when a Korean profile activates.
- [modifier-keys-and-compositions](modifier-keys-and-compositions/README.md): Shift ended
  compositions; an app ending one on Alt left the caret inside it.
- [modifier-taps-unreachable](modifier-taps-unreachable/README.md): lone Right Win / Ctrl / Alt
  taps never reach a TIP; Menu half works; ``Alt+` `` under the Japanese layout.
- [lang1-lang2-per-layout](lang1-lang2-per-layout/README.md): 英数 / かな (LANG2 / LANG1) arrive
  differently under the US layout.
- [low-level-hook-takes-f-keys](low-level-hook-takes-f-keys/README.md): an AutoHotkey script's
  hook takes the F-keys first; three rounds of fixes.

## Privacy, performance, environment

- [password-fields-and-prediction-list](password-fields-and-prediction-list/README.md): a
  certificate program's password box showed readings in the prediction list.
- [dictionary-load-blocks-first-focus](dictionary-load-blocks-first-focus/README.md): parsing the
  dictionary on activation delayed the first focus.
- [injected-right-win-holds-input](injected-right-win-holds-input/README.md): a test injecting
  Right Win left the Start menu holding mouse and Tab input.
- [parsec-from-mac](parsec-from-mac/README.md): over Parsec from a Mac, F18–F20, 英数, かな and
  Ctrl never reach Windows. **Open.**
- [development-pitfalls](development-pitfalls/README.md): toolchain, install script, MSI, Sandbox
  and test pitfalls.

Mozc-specific issues are in [../mozc](../mozc/README.md); keyboard-on-laptop and USB dock issues
met during the same work are in [../hardware](../hardware/README.md).
