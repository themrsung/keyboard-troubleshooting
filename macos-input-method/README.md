# macOS input method (InputMethodKit)

Problems met while building the macOS shell of [JIS Korean](https://github.com/team-mirae/jis-korean)
(`mac/`, an InputMethodKit input method in Swift), with what was tried and how it ended. Collected
from JIS Korean's commit history and its `docs/troubleshooting/` up to commit
[`72dcc4b`](https://github.com/team-mirae/jis-korean/commit/72dcc4b) (2026-10-23). Seen on macOS 27.0
and 27.0.1. *Measured*, *inferred* and *hypothesis* are as the source recorded them.

- [reinstall-stops-launching](reinstall-stops-launching/README.md): after a reinstall the input
  method never launches in apps that were already running; why an update still needs the input
  source removed and re-added.
- [bare-jamo-in-chrome](bare-jamo-in-chrome/README.md): fields commit `ㅂㅏㄷㅏ` instead of `바다`;
  two causes in JIS Korean, two outside it. Has a reproduction of the diagnostic.
- [katakana-lost-by-macos](katakana-lost-by-macos/README.md): macOS discards the Windows JIS
  カタカナ key (or turns it into かな); reading it at the HID level, and every problem that had.
- [eisu-selects-abc](eisu-selects-abc/README.md): with Apple's ABC enabled, 英数 goes to ABC
  instead of the input method's own English mode.
- [korean-key-in-iterm](korean-key-in-iterm/README.md): iTerm keeps F1–F19, so F18 never reaches
  the input method; Caps Lock as the switch key was tried three ways and dropped.
- [switch-keys-dead-after-login](switch-keys-dead-after-login/README.md): system-wide keys caught
  inside the input method's process do nothing until the input method has been selected once.
- [permissions-lost-on-rebuild](permissions-lost-on-rebuild/README.md): Input Monitoring and
  Accessibility grants are lost on every ad hoc signed build.
- [tis-enable-disable](tis-enable-disable/README.md): `TISEnableInputSource` /
  `TISDisableInputSource` on macOS 27, and selecting from the input method's own process.
- [keyboard-viewer-and-icon](keyboard-viewer-and-icon/README.md): Keyboard Viewer kept showing
  ABC's legends; the menu-bar badge never quite matched Apple's.
- [press-and-hold-take-back](press-and-hold-take-back/README.md): press and hold needed the app
  to take back a typed letter; iTerm2 and Discord didn't.
- [diagnostic-gotchas](diagnostic-gotchas/README.md): `log` in zsh, `pgrep -f`, the HIToolbox
  plist and `<private>` log lines. Has a reproduction for `pgrep -f`.

Related, already in this repository: [hhkb/studio-jis-stored-as-ansi](../hhkb/studio-jis-stored-as-ansi/README.md)
and [via/keycap-legend-language-and-jis](../via/keycap-legend-language-and-jis/README.md).

One more note from the history, without further detail there: JIS Korean's English mode on macOS
started as a workaround, because switching from English to Korean through Hammerspoon "could
switch back by itself" (commit message of
[`cd71e0d`](https://github.com/team-mirae/jis-korean/commit/cd71e0d)).
