# keyboard-troubleshooting

Notes on keyboard problems, firmware quirks and layout setups, each with what was tried, what was
measured and what works. Most come from setting up keyboards for
[JIS Korean](https://github.com/team-mirae/jis-korean), a Korean input method built around JIS
keyboards, on macOS: getting カタカナ, 英数, かな, ¥ and ろ onto keyboards that don't have them.

Each issue, suggestion or proposal has its own folder inside its category.

## hhkb/ — HHKB

- [fn-layer-is-firmware-only](hhkb/fn-layer-is-firmware-only/README.md): the HHKB's Fn never reaches
  the computer, so a remapper can't move it; it can only build a second Fn layer of its own.
- [studio-jis-stored-as-ansi](hhkb/studio-jis-stored-as-ansi/README.md): a JIS HHKB stored by
  macOS as ANSI, so the keys that need a JIS keyboard type are lost.

## via/ — VIA

- [any-key-rejects-layer-tap](via/any-key-rejects-layer-tap/README.md): VIA's Any key wouldn't
  take `LT(x,y)` for a Hansung keyboard; writing the keycode over raw HID worked.
- [raw-hid-keymap-editing](via/raw-hid-keymap-editing/README.md): `viahid`, a small macOS tool
  that reads and writes a VIA keyboard's keymap without the VIA app.
- [keycap-legend-language-and-jis](via/keycap-legend-language-and-jis/README.md): an ANSI board
  started working as JIS on macOS right after VIA's keycap legend language was set to Japanese.

## qmk/ — QMK keycodes

- [japanese-keycodes-on-macos](qmk/japanese-keycodes-on-macos/README.md): which of QMK's Japanese
  and language keycodes macOS acts on, and which it drops.
- [lang-keycode-names](qmk/lang-keycode-names/README.md): `KC_HANJ`, `KC_HAEN` and `KC_KANA` are
  named for Korean and Windows, and arrive on a Mac as 英数, かな and カタカナ.

## hansung/ — Hansung (한성컴퓨터) keyboards

- [mod-tap-rshift-bug](hansung/mod-tap-rshift-bug/README.md): mod-tap keys add right Shift when
  held and send their modifier when tapped. Layer-tap is fine.
- [web-driver-internals](hansung/web-driver-internals/README.md): what Hansung's web driver
  (app.superstore.co.kr) is built on: VIA's raw-HID protocol with vendor commands.
- [via-definition-magnetox-xf](hansung/via-definition-magnetox-xf/README.md): a VIA definition for
  the TFG Magnetox XF, converted from Hansung's own, and the converter.

## layouts/ — layout proposals

- [us-ansi-104-key-to-jis](layouts/us-ansi-104-key-to-jis/README.md): a full-size US board (TFG
  Magnetox XF) with JIS's keys in firmware alone, no mod-tap.
- [us-ansi-87-key-to-jis](layouts/us-ansi-87-key-to-jis/README.md): a tenkeyless US board (MONGDOL
  87) with JIS's keys in firmware, tap vs hold on two layers.
- [hhkb-pro-bt-us-to-jis](layouts/hhkb-pro-bt-us-to-jis/README.md): an HHKB Professional BT (US)
  with JIS's keys through Karabiner-Elements.
- [macbook-us-to-jis](layouts/macbook-us-to-jis/README.md): a MacBook's built-in US keyboard with
  JIS's keys through Karabiner-Elements.

## macos-input-method/ — macOS input methods (InputMethodKit)

From [JIS Korean](https://github.com/team-mirae/jis-korean)'s macOS shell: an input method that
stops launching after a reinstall, fields committing bare jamo in Chrome, the カタカナ key macOS
discards, 英数 going to ABC, switch keys in iTerm and after login, signing and permissions, TIS
calls on macOS 27, Keyboard Viewer and the menu-bar badge, and diagnostic gotchas.
[Index](macos-input-method/README.md).

## windows-tsf/ — Windows TSF text input processors

From [FKeyIME](https://github.com/themrsung/fkeyime) and JIS Korean's Windows shell: apps that
keep an old TIP, sign-in starting on the Microsoft IME, Settings not listing the TIP, the IMM
compatibility layer and Korean compositions, keys lost between `OnTestKeyDown` and `OnKeyDown`,
modifier taps a TIP never sees, LANG1/LANG2 per layout, an AutoHotkey hook taking the F-keys,
password fields, Parsec, and development pitfalls. [Index](windows-tsf/README.md).

## mozc/ — Mozc as a conversion server

From FKeyIME: the server's watch dog aborting it, running it outside Mozc's sandbox, building Mozc
with Bazel on Windows, and learning that changes test results. [Index](mozc/README.md).

## hardware/ — hardware met while debugging input methods

A keyboard resting on a laptop's keys (hypothesis), and a USB mouse behind a USB-C dock.
[Index](hardware/README.md).

## testers/

People who can test on their own hardware, with what they have:
[themrsung](testers/themrsung.md).

## Background: keyboard types on macOS

macOS stores a type for each keyboard it has seen, in `/Library/Preferences/com.apple.keyboardtype`
(`product-vendor-country` = 40 ANSI, 41 ISO, 42 JIS), set by Keyboard Setup Assistant (System
Settings → Keyboard → Change Keyboard Type…). The type decides how macOS reads keys that differ
between the families: on a keyboard stored as ANSI, the JIS-only keys (¥ `0x89`, ろ `0x87`) can be
dropped. A keyboard modified by Karabiner-Elements reaches macOS through Karabiner's virtual
keyboard (`593-1452-0`), which has a type of its own; Karabiner's "Virtual Keyboard: JIS" setting
doesn't set it.

```sh
defaults read /Library/Preferences/com.apple.keyboardtype
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype -dict-add "593-1452-0" -int 42
```

Keyboard Setup Assistant asks for the key right of the left Shift and the key left of the right
Shift. Pressing Z and then ろ makes it pick JIS, which is how a remapped ANSI board with ろ on a
layer gets stored as JIS. Built-in keyboards have no entry and take their type from the hardware.
