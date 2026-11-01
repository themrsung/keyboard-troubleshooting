# Make 英数 (Eisu) and かな (Kana) run your own code on macOS, with no Karabiner and no permissions

**Status:** workaround, in daily use on the tester's Mac (macOS 27, Apple Silicon; see
[testers/themrsung](../../testers/themrsung.md)). A working example ships in
[team-mirae/jis-moonshot](https://github.com/team-mirae/jis-moonshot).

**Short answer:** register an input source in the Roman script and one in the Japanese script,
each the *primary* source of its script, and make sure no other input source competes with them.
macOS then sends 英数 to the first and かな to the second on its own. Your input method sees the
switch in its activation callback, where it can run any code you like. You don't need Karabiner,
Accessibility or Input Monitoring, and you don't need an event tap.

Keywords: Mac JIS keyboard, Eisu key, Eisū, Eisuu, 英数キー, Kana key, かなキー, LANG1, LANG2,
macOS key code 102 and 104, remap Eisu or Kana without Karabiner, custom input method,
InputMethodKit, `IMKInputController`, `kTextServiceInputModePropertyTag`,
`tsInputModePrimaryInScriptKey`, `tsInputModeScriptKey`, input source switching.

## Key names

| Legend | Canonical name | macOS key code | HID |
| --- | --- | --- | --- |
| 英数 | `KeyJISMacEnglish` | 102 | LANG2 (0x91) |
| かな | `KeyJISMacKana` | 104 | LANG1 (0x90) |

## How macOS routes the two keys

These rules were worked out while building JIS Korean and JIS Moonshot (see
[eisu-selects-abc](../eisu-selects-abc/README.md) and the comments in jis-moonshot's
[`mac/Info.plist`](https://github.com/team-mirae/jis-moonshot/blob/b8862407a7aec88bc4aaf4410587c7babacec4ca/mac/Info.plist#L66-L91)):

- **英数** selects the primary input source of the Roman script (`smRoman`). Apple's **ABC** is
  Roman, and when it is enabled 英数 goes to ABC rather than to your input method (measured).
  **ABC – Extended** doesn't take 英数 that way (measured).
- **かな** selects the primary input source of the Japanese script (`smJapanese`). It **does
  nothing while a Japanese-script source is already selected** (measured in jis-moonshot), and it
  goes to whichever Japanese input method is primary, so any other Japanese input method can take
  it.
- macOS keeps at least one plain keyboard layout enabled, for password fields, and input method
  modes don't count as one. This is why ABC – Extended has to be added before ABC can be removed.

## Steps

1. In System Settings → Keyboard → Input Sources → Edit…, add English → **ABC – Extended**.
2. Remove **ABC**. Steps 1 and 2 are the same as in [eisu-selects-abc](../eisu-selects-abc/README.md).
3. Register a custom **English** input source: `tsInputModeScriptKey` = `smRoman`,
   `tsInputModePrimaryInScriptKey` = true, `TISIntendedLanguage` = `en`.
4. Register a custom **Japanese** input source: `tsInputModeScriptKey` = `smJapanese`,
   `tsInputModePrimaryInScriptKey` = true, `TISIntendedLanguage` = `ja`.
5. **Remove every other Japanese input method** (Apple's Japanese, Google Japanese Input, ATOK, …).
   They compete for かな. Also, if one of them is selected, かな does nothing.
6. In both sources' activation hook (`onEnable()` in the tester's setup), do whatever you want the
   key to do.

The sources in steps 3 and 4 can be two input methods, or two input modes of one input method
(entries in `ComponentInputModeDict` → `tsInputModeListKey`). JIS Moonshot uses modes.

### Where the hook is in InputMethodKit

When the user picks an input mode, by key or from the menu, the controller gets
`setValue(_:forTag:client:)` with `tag == kTextServiceInputModePropertyTag` and the mode's
`TISInputSourceID` as the value. For a separate input method, `activateServer(_:)` is called when
it becomes active. `onEnable()` stands for either.

```swift
override func setValue(_ value: Any!, forTag tag: Int, client sender: Any!) {
    if tag == kTextServiceInputModePropertyTag, let id = value as? String {
        switch id {
        case "com.example.inputmethod.EisuKey": onEisu(client: sender as? IMKTextInput)
        case "com.example.inputmethod.KanaKey": onKana(client: sender as? IMKTextInput)
        default: break
        }
    }
    super.setValue(value, forTag: tag, client: sender)
}
```

## Working example: JIS Moonshot

Pinned at commit
[`b886240`](https://github.com/team-mirae/jis-moonshot/tree/b8862407a7aec88bc4aaf4410587c7babacec4ca)
(2026-11-01):

- **かな proxy:** the input mode `me.sjun.inputmethod.JISMoonshot.KanaKey` is the only
  Japanese-script source, and it is primary
  ([`mac/Info.plist`](https://github.com/team-mirae/jis-moonshot/blob/b8862407a7aec88bc4aaf4410587c7babacec4ca/mac/Info.plist#L71-L91)).
  It never stays selected. `setValue(_:forTag:client:)` reroutes it straight to the Korean mode
  (or forces Korean there)
  ([`mac/Sources/InputController.swift`](https://github.com/team-mirae/jis-moonshot/blob/b8862407a7aec88bc4aaf4410587c7babacec4ca/mac/Sources/InputController.swift#L200-L211)).
  Its own Japanese kana mode is declared in the **Korean** script on purpose, so that かな keeps
  working while it is selected.
- **英数:** the English modes are added at build time as Roman-script modes, one of them primary
  ([`mac/tools/add-english-mode.sh`](https://github.com/team-mirae/jis-moonshot/blob/b8862407a7aec88bc4aaf4410587c7babacec4ca/mac/tools/add-english-mode.sh)).
  英数 selects it once ABC has been swapped for ABC – Extended.
- Its design notes are in
  [`docs/moonshot.md` §7](https://github.com/team-mirae/jis-moonshot/blob/b8862407a7aec88bc4aaf4410587c7babacec4ca/docs/moonshot.md#7-platforms).

## Not tested yet

- Whether a proxy source that reroutes at once flashes in the menu bar (open in jis-moonshot).
- Whether Ctrl+Space (`KeyUniversalControl` + `KeySpacebar`, select previous input source) lands
  on a proxy source (open in jis-moonshot).

## Related

- [eisu-selects-abc](../eisu-selects-abc/README.md): why ABC has to go, and why it can't simply be
  removed.
- [katakana-lost-by-macos](../katakana-lost-by-macos/README.md): the Windows JIS カタカナ key, which
  macOS discards or turns into かな.
- [tis-enable-disable](../tis-enable-disable/README.md): selecting input sources from code on
  macOS 27.
- [reinstall-stops-launching](../reinstall-stops-launching/README.md): after you change the
  `Info.plist` modes, remove and re-add the input source.
