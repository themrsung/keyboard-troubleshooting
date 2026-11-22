# MONGDOL 87: plain US ANSI, with 한/영 right of Space

A VIA keymap for the owner's **MONGDOL 87** (SPM Works, US ANSI tenkeyless, stock firmware,
`36B0:3198` over USB, reports as "MONGDOL 87"). It takes the board back to a plain US ANSI keyboard,
instead of the JIS emulation in
[layouts/us-ansi-87-key-to-jis](../../layouts/us-ansi-87-key-to-jis/README.md): there's no カタカナ,
英数, ¥ or ろ, and 한/영 sits right of Space.

The file is [mongdol_87_us_ansi.layout.json](mongdol_87_us_ansi.layout.json). It is that layout's
[mongdol_87.layout.json](../../layouts/us-ansi-87-key-to-jis/mongdol_87.layout.json) with only the
changes below; every other key is as before.

## Bottom row

Left to right, on layer 0 (Windows mode) and layer 1 (Mac mode). Fn is layer 2 from layer 0, and
layer 3 from layer 1.

| Key | Canonical name | Before | Now | Does |
|---|---|---|---|---|
| Bottom-left | `KeyUSLeftControl` | `LT(2,KC_KANA)` | `MO(2)` / `MO(3)` | Fn while held |
| Second | `KeyLeftPrimary` | `KC_LALT` | `KC_LALT` | ⌥ (unchanged) |
| Left of Space | `KeyLeftAuxiliary` | `MT(MOD_LGUI,KC_HANJ)` | `KC_LGUI` | ⌘ |
| Space | `KeySpacebar` | `KC_SPC` | `KC_SPC` | Space (unchanged) |
| Right of Space | `KeyRightAuxiliary` | `KC_HAEN` | `KC_HAEN` | 한/영 (`KeyKTSHangulToggle`, `KC_LNG1`; unchanged) |
| Next | `KeyRightPrimary` | `KC_RGUI` | `KC_RGUI` | ⌘ (unchanged) |
| Next | `KeyWINMenu` | `KC_RALT` | `KC_RALT` | ⌥ (unchanged) |
| Rightmost | `KeyRightControl` | `MO(2)` / `MO(3)` | `KC_RCTL` | Right Control |

So the row reads Fn, ⌥, ⌘, Space, 한/영, ⌘, ⌥, Control.

- **Fn** is only bottom-left now. The rightmost key is a plain Control, which can be held with other
  keys. Caps Lock also stays Control (`KC_LCTL`, HHKB style).
- **한/영 on macOS:** `KC_LNG1` is the same usage as かな (`KeyJISMacKana`), and macOS treats it
  that way: it selects the primary Japanese-script input source (see
  [eisu-kana-keys-run-your-own-code](../../macos-input-method/eisu-kana-keys-run-your-own-code/README.md)).
  What it does with only Korean and ABC installed **hasn't been checked**. On Windows it's
  `VK_HANGUL`.

## Fn layer (layer 2)

The JIS escapes on the three keys right of Space are removed: ¥ (`KC_JYEN`), `/` (`KC_SLSH`) and ろ
(`KC_RO`) are now `KC_TRNS`, so those keys do the same with Fn as without. The rest of layer 2
(F13–F24, media, mouse keys, lighting) is unchanged. Layer 3 is the board's stock Mac Fn layer and
isn't changed.

## How to load

1. Open [usevia.app](https://usevia.app) in Chrome, and authorize the MONGDOL 87.
2. **Save + Load → Save** first, to keep the keymap the board has now.
3. **Save + Load → Load**, and pick
   [mongdol_87_us_ansi.layout.json](mongdol_87_us_ansi.layout.json).

On the Mac, store the board as **ANSI**. This Mac already does: `12696-14000-0` = 40 in
`/Library/Preferences/com.apple.keyboardtype` (checked 2026-11-04).

## Tested

Not yet: the file was made from the old keymap with the changes above, and hasn't been loaded onto
the board or pressed through.
