# Keyboard Viewer showed ABC's legends; the menu-bar badge differed from Apple's

**Status:** Keyboard Viewer: the IMK call is what spec §8.1 now describes as in use; the history
has no later note of Keyboard Viewer itself being checked. Icon: "close enough and accepted"
(2026-10-19).

Source: JIS Korean, [`docs/troubleshooting/macos-input-method-not-launching.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-input-method-not-launching.md)
(sections on Keyboard Viewer and the icon), commit
[`d8d9577`](https://github.com/team-mirae/jis-korean/commit/d8d9577), spec §8.1. macOS 27.0.

## Keyboard Viewer

| Tried | Result |
| --- | --- |
| `TISSetInputMethodKeyboardLayoutOverride` from the input method's process on every activation | Returned `noErr` (logged ten times), no visible effect; Keyboard Viewer followed the client's layout |
| A hidden layout bundle in `~/Library/Keyboard Layouts` (`TSMInvisibleKey`) | Tried once (16:06), removed again by later installs; no result recorded |
| `-[IMKTextInput overrideKeyboardWithKeyboardNamed:]` with a layout generated from the engine's legends, bundled in `Contents/Resources` next to a `…KeyboardLayouts-Info.plist` (the arrangement Apple's Korean input method uses with `2SetHangul`) | Written, then commented out to log only on a mistaken theory that it stalled the input method; not exercised that day because of the launch problem |

Observed along the way: right after `TISRegisterInputSource` the bundled layout was listed
(`…keylayout.JISKorean`, not selectable) and on a later rescan it was gone, three times that day.

Later, the override is in use and turned out to be per client process, not per field: that was
one cause of [bare-jamo-in-chrome](../bare-jamo-in-chrome/README.md). The generated layouts keep
the Cmd, Ctrl and Option (`KeyUniversalPrimary`, `KeyUniversalControl`,
`KeyUniversalAuxiliary`) layers identical to ABC so shortcuts don't change (`0d51744`).

## Menu-bar and System Settings badge

Tried in order, each with a reinstall and the source re-added (the menu agent caches the icon from
registration/enable time):

1. Outlined template 한 as `tsInputMethodIconFileKey` → outline badge.
2. Filled badge with the glyph cut out, pixel-close to Apple's `2SetKorean.tiff` → drawn differently.
3. `TISIconLabels` only, no icon file → closer, not identical.
4. One input mode in `ComponentInputModeDict` with mode-level `TISIconLabels` and icon keys, as
   Apple's Korean does → accepted.
5. Icon keys naming `icon.png` while only `icon.tiff` ships (Apple's own mismatch).

Result: accepted; System Settings' badge stays a little lighter than Apple's. Left unexplored:
whether System Settings draws Apple-signed input methods differently.

Side effect of step 4: the selected source id became `me.sjun.inputmethod.JISKorean.2Set`, so
anything comparing the current id to `me.sjun.inputmethod.JISKorean` (a Hammerspoon hotkey, for
example) has to use the new id or a prefix.
