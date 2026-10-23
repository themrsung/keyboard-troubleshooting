# Layout principles

These are guidelines, not a set of strict rules, but please try to design around them.

## Limitations

- **This design assumes an operating system and input method that can turn a spare key, such as
  カタカナ, into a language key of its own**, for example macOS with
  [JIS Korean](https://github.com/team-mirae/jis-korean). Without one, the language keys don't all
  work: macOS by itself discards カタカナ.
- **The layouts here are designed and tested on macOS.** For other platforms, create a new
  directory next to this one, such as `layouts-windows/` or `layouts-arch-linux/`.

Each principle ends with how the golden layout, [hhkb-jis-golden](hhkb-jis-golden/README.md),
meets it.

## 1. Idempotency

A distinct action should produce a consistent result, regardless of how many times it has been
typed.

- **Exception 1:** when there are simply too few keys to map actions to, a toggle becomes
  necessary.
- **Exception 2:** existing convention. For example, 한/영 as an English–Korean toggle is
  acceptable: existing typists always keep it in mind while typing, so it adds no cognitive load.

### The golden layout

- **One key per language, no toggle.** カタカナ always goes to Korean, 英数 always to English, かな
  always to Japanese. Pressing one twice, or after any other key, ends in the same place, so the
  typist never has to check which input source is active before typing.
- **The language keys are set on every layer** (Standard, Fn1, Fn2 and Fn3), so holding Fn1 or Fn2
  doesn't change what they do.
- **The gesture pads have separate on and off keys** (Fn2+A–F on, Fn2+Z–V off) rather than one toggle
  per pad.
- **Pointing-stick speed has absolute steps** (Fn2+1–4) next to the relative ones (Fn2+G / B,
  faster and slower). The relative keys aren't idempotent, but they're never the only way to set a
  speed.

## 2. Conservation

Something that works on a conventional layout should also work on the custom layout, either the
same way or in some modified way.

### The golden layout

- **Every key of a stock HHKB Studio JIS is where it was,** except the bottom row. Every character,
  including ¥ and ろ, types from its own key, as printed.
- **Everything in the stock Fn layer is still on Fn1:** F1–F12, Insert, Delete, Caps Lock, the
  arrows and Home / End / Page keys, volume, keypad keys and Power.
- **The bottom row only adds.** Opt, ⌘ and Fn1 stay on both sides; 英数 and かな are the keys a
  Mac JIS keyboard already has. The one key given up is 半/全, now カタカナ: macOS doesn't use 半/全,
  and a MacBook JIS has no such key.
- **The gesture pads are off, not gone.** A conventional keyboard has no pads, so off is the
  conventional state, and each pad is one chord away (Fn2+A–F).

## 3. Consistency

No one who would be reading this uses just one keyboard with just one computer, so layouts need to
be consistent. Assume switching between layouts and operating systems.

- **Reference:** for the layouts in this repository, the golden reference is always the HHKB Studio
  JIS.

### The golden layout

It's the reference, so it's consistent by definition. What the other layouts copy from it:

- **The bottom row's order:** Fn, カタカナ, ⌥, ⌘ and 英数 left of Space, かな right of Space. Few
  keyboards other than HHKBs have five keys left of Space, even JIS ones with four, so the dedicated
  Fn is the first to go: it moves onto the カタカナ key as a hold (87-key), onto 🌐 (MacBook), or off
  the left side (HHKB US). The rest keep their order.
- **The Fn layer:** the HHKB one, on the 104-key, HHKB US and MacBook layouts too.
- **Control left of A.**
- **The same keycode for Korean:** the change from F18 to カタカナ means the Studio now sends the key
  every other layout here already sends (0x88, `KC_INT2` in firmware or `japanese_pc_katakana` in
  Karabiner), so every board switches to Korean the same
  way.
- **No stray input by default:** with the pads off, the Studio behaves like every other keyboard
  when a hand brushes its case.

## 4. Compatibility

While the layouts here are designed for macOS, they shouldn't exclude other operating systems. The
basics should still work, usually defined as:

- At least one modifier key of each type (Control, Alt/Option, System, and Fn) visible and
  realistically reachable in every layer.
- **Exception:** a modifier's own layer. For example, a held Fn key doesn't have to expose another
  Fn key, as it would serve no purpose.

### The golden layout

- **Every modifier on every layer:**

  | Layer | Control | Alt/Option | System (⌘/Windows) | Fn |
  |---|---|---|---|---|
  | Standard | left of A | Opt, both sides | ⌘, both sides | Fn1, both ends; Fn2 below Space |
  | Fn1 | left of A, and right Control on → | Opt, both sides | ⌘, both sides, and right ⌘ on ↓ | Fn2 (its own layer is the exception) |
  | Fn2 | left of A | Opt, both sides | ⌘, both sides | Fn1, both ends (the exception again) |

- **Standard keycodes only.** Everything the keyboard sends is an ordinary USB key: カタカナ is the
  Windows JIS カタカナ/ひらがな key, which Windows knows natively, and 英数 / かな are the keys a
  Mac JIS keyboard sends. F18, which it replaces, meant nothing to any OS without a remapper.
- **The rest of the board is a stock JIS keyboard,** which every major OS supports.

## 5. Several points of access

Assume firmware or software will break. It is better to have multiple ways of reaching the same key
or key combination than to rely on one.

### The golden layout

- **Keys reachable two ways:**
  - Delete: Fn1+BS or Fn1+←.
  - Right ⌘: its own key or Fn1+↓.
  - Right Shift: its own key or Fn1+↑.
  - The arrows: their own keys or the Fn1 cluster on the right.
  - Fn1: both ends of the bottom row.
  - The gesture pads: Fn2 or the keymap tool.
- **The language keys work while either Fn is held,** so a stuck or half-pressed Fn doesn't take
  them away.
- **Firmware first, software on top.** The keymap lives in the keyboard, so it works on any computer
  without a remapper. Only two keys lean on software: Fn1+I and Fn1+P become ⌘⇧4 and Play/Pause
  through Karabiner-Elements, and without it they still send Print Screen and Pause.
- **If JIS Korean breaks,** macOS discards カタカナ, but 英数 and かな still switch to English and
  Japanese natively, so the keyboard never leaves you stuck in one language.

## General tips

For your own sake, and easier development, try to avoid:

- **Using non-standard keys as a state trigger.** For example, F18 as the only way into Korean
  needed middleware on every keyboard whose firmware can't be remapped to F18, including older
  HHKBs: the HHKB Hybrid Type-S can't be remapped beyond F12, so F13–F24 can't be reached in
  firmware alone. Apps take these keys too: iTerm keeps F1–F19, so F18 never reached the input
  method ([korean-key-in-iterm](../macos-input-method/korean-key-in-iterm/README.md)), and on
  Windows an AutoHotkey hook took the F-keys
  ([low-level-hook-takes-f-keys](../windows-tsf/low-level-hook-takes-f-keys/README.md)). A standard
  key such as カタカナ avoids this.
- **Working around uncooperative software.** Engineering your own solution is cheap now with good
  prompting of agentic coding models, especially when you can dogfood it live. A keyboard input
  method or layout is the prime example.
- **Working against key labels.** If you use mechanical keyboards, a blank keycap set is
  recommended. A wrong label takes much longer to get used to, even if your muscle memory is good
  and adaptive.

And try to:

- **Look it up before assuming something will work.** Support can be recent, even on the golden
  layout's own hardware: the HHKB Studio Keymap Tool only added F20–F24 in version 1.1.2. From its
  update history:

  > May 28, 2026, 1.1.2
  > - Expanded the range of assignable keys (added F20–F24 keys).
  > - Added a feature to check for updates at application startup.
  > - Changed the specification so that Fn keys can only be assigned on the default layer.
  > - Changed the specification so that Fn keys assigned on the default layer cannot be modified
  >   on other layers.

- **Test your idea first: will it actually work, reliably, and the way you expect?** A keycode the
  firmware accepts isn't one it handles correctly: Hansung's mod-tap adds right Shift when held and
  sends its modifier when tapped, while its layer-tap works
  ([mod-tap-rshift-bug](../hansung/mod-tap-rshift-bug/README.md)). Try a mechanism on the real
  board, in the real apps, for a while, before designing a layout around it.
- **Check how macOS stored the keyboard before debugging anything else.** A JIS board stored as ANSI
  loses ¥ and ろ, and a remapped ANSI board needs to be stored as JIS
  ([studio-jis-stored-as-ansi](../hhkb/studio-jis-stored-as-ansi/README.md),
  [keycap-legend-language-and-jis](../via/keycap-legend-language-and-jis/README.md)). It takes
  seconds: `defaults read /Library/Preferences/com.apple.keyboardtype` (see the
  [README](../README.md)).
- **Change one thing at a time, and write down what you changed.** When two things change at once,
  the cause can't be told apart: the cable and the port were swapped together in
  [hall-effect-keyboard-behind-usb-hub](../hardware/hall-effect-keyboard-behind-usb-hub/README.md),
  and Karabiner's settings changed during the test in
  [keycap-legend-language-and-jis](../via/keycap-legend-language-and-jis/README.md).
- **Rule out the hardware before blaming software.** Cable, port, hub or dock, and anything resting
  on the keys: [hall-effect-keyboard-behind-usb-hub](../hardware/hall-effect-keyboard-behind-usb-hub/README.md),
  [usb-c-dock-mouse-not-enumerated](../hardware/usb-c-dock-mouse-not-enumerated/README.md),
  [keyboard-resting-on-laptop](../hardware/keyboard-resting-on-laptop/README.md). Injected keys
  can't reproduce a hardware cause, so record real key presses with a key logger such as
  Karabiner-EventViewer.

## Rule of thumb

Imagine you got a blank set of keycaps and engraved them however you like, in whatever language,
for any target audience. Would that audience know how to use the keyboard without searching
"\<your company\> keyboard how to use" every day?
