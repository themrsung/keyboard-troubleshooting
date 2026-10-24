# Layout principles

These are guidelines, not a set of strict rules, but please try to design around them.

## Limitations

- **This design assumes Windows with the Microsoft IME Korean**, which switches languages with
  한/영 (`VK_HANGUL`) and converts to hanja with 한자 (`VK_HANJA`). Both are a single toggle or
  action each, not one key per language: a separate key per language needs a text input processor
  of its own (see [windows-tsf](../windows-tsf/README.md)).
- **Designing for the Microsoft IME's dubeolsik (Korean 2-set) also makes a layout work with
  [JIS Korean](https://github.com/team-mirae/jis-korean) for Windows.** JIS Korean is a superset of
  dubeolsik: it only assigns more of the keyboard to Korean characters, so a layout that types
  dubeolsik correctly types JIS Korean too.
- **The layouts here are designed and tested on Windows (ko-KR).** For other platforms, create a
  new directory next to this one, such as [`layouts/`](../layouts/PRINCIPLES.md) (macOS) or
  `layouts-arch-linux/`.

Each principle ends with how the golden layout,
[windows-104-key-golden](windows-104-key-golden/README.md), meets it. **The golden layout is still
being designed**, so these sections fill in as it is.

## 1. Idempotency

A distinct action should produce a consistent result, regardless of how many times it has been
typed.

- **Exception 1:** when there are simply too few keys to map actions to, a toggle becomes
  necessary.
- **Exception 2:** existing convention. For example, 한/영 as an English–Korean toggle is
  acceptable: existing typists always keep it in mind while typing, so it adds no cognitive load.
- **Exception 3:** a binary state the user can perceive without further input or keeping their
  focus on it. Is music playing or not? Is the keyboard's backlight on or off? For a state like that, a
  toggle is acceptable, and may be the better design: one key instead of two, and the user already
  knows which way it will go.

### The golden layout

- **한/영 stays a toggle** (exception 2), on Right Alt, where the Microsoft IME's Type 1 keyboard
  puts it.
- **한자 is a key of its own:** a tap of the right Fn sends USB LANG2 (`VK_HANJA`), which converts
  the syllable in composition however many times the key was pressed before.

## 2. Conservation

Something that works on a conventional layout should also work on the custom layout, either the
same way or in some modified way.

### The golden layout

- **Every key of a stock Windows 104-key board is where it was,** except Caps Lock and both ends
  of the bottom row. Scroll Lock and Pause, which Keychron left out for Cortana and a backlight key,
  are back right of Print Screen.
- **Caps Lock is still there,** on Fn+Tab (as on an HHKB), and Control moves left of A.
- **Left Control is still there,** as Right Control; the left end is now Fn.
- **Right Fn is still Fn when held,** and adds 한자 on a tap.
- **Left Alt is still Alt when held,** and adds 無変換 on a tap. A lone tap of Alt no longer
  opens a window's menu bar; F10 still does.
- **The backlight toggle that Fn+Tab replaced** is still on Fn+Pause, and its brightness on
  Fn+F5 / F6, and its effects moved from their own key to Fn+Print Screen / Scroll Lock, all
  [reserved for hardware control](#reserved-for-hardware-control-rhc). Cortana is dropped: it's gone
  from Windows 11. The backlight's other controls, which took Fn + Q–T and A–G, gave way to
  the HHKB Fn layer, and NKRO moved from Fn+N to Fn+B.

## 3. Consistency

No one who would be reading this uses just one keyboard with just one computer, so layouts need to
be consistent. Assume switching between layouts and operating systems.

- **Reference:** for the layouts in this directory, the golden reference is always
  [windows-104-key-golden](windows-104-key-golden/README.md) (Keychron C2 Pro, full-size US).

### The golden layout

It's the reference, so it's consistent by definition. What it already shares with the macOS
layouts in [`layouts/`](../layouts/PRINCIPLES.md):

- **Control left of A.**
- **Fn at both ends of the bottom row**, as Fn1 is on the HHKB Studio JIS.
- **JIS's 無変換 and 変換 either side of Space:** 無変換 on a tap of the left Alt and on Fn + the
  left Alt, 変換 on Fn+Space, and カタカナ/ひらがな on Fn + the left Win. With the left Alt and Win
  taken on the Fn layer, Fn+X is Alt and Fn+Z is Win there.
- **JIS's extra keys right of Space, on the Fn layer:** Fn+Right Alt is ¥, Fn+Right Win is む
  (JIS's ] key) and Fn+Right Control is ろ. As on the macOS
  [us-ansi-104-key-to-jis](../layouts/us-ansi-104-key-to-jis/README.md), the keys right of Space
  carry them, though there the middle one is /.
- **The HHKB Fn layer:** F1–F12 on the number row, the arrows on [ ; ' /, Home / End / Page keys,
  keypad keys, Delete / Insert, Caps Lock on Tab, and volume, mute and eject on A–F, as on the
  macOS 104-key layout. Fn+P is Play/Pause, as in the macOS layouts' Mac extras.

## 4. Compatibility

While the layouts here are designed for Windows, they shouldn't exclude other operating systems. The
basics should still work, usually defined as:

- At least one modifier key of each type (Control, Alt/Option, System, and Fn) visible and
  realistically reachable in every layer.
- **Exception:** a modifier's own layer. For example, a held Fn key doesn't have to expose another
  Fn key, as it would serve no purpose.
- **Scope:** keyboards. A numpad isn't a keyboard, so the modifier rule doesn't apply to it. Even
  if it did, apps don't treat numpad keys like the main ones: Ctrl + keypad 1 is often handled
  differently from Ctrl+1, and Shift + keypad 1 doesn't type !.

### The golden layout

- **Every modifier on every layer:**

  | Layer | Control | Alt | System (Windows) | Fn |
  |---|---|---|---|---|
  | Standard | left of A, and right Control | Alt, both sides (left: 無変換 on a tap; right: 한/영 on Type 1) | Win, both sides | Fn, both ends of the bottom row |
  | Fn | left of A (right: ろ) | Fn+X (left Alt: 無変換; right: ¥) | Fn+Z (left Win: カタカナ; right: む) | Fn (its own layer is the exception) |

- **Standard keycodes only,** so far: everything the keyboard sends is an ordinary USB key.

## 5. Several points of access

Assume firmware or software will break. It is better to have multiple ways of reaching the same key
or key combination than to rely on one.

### The golden layout

- **Keys reachable two ways:**
  - Control: left of A and right Control (on the standard layer).
  - Fn: both ends of the bottom row.
  - 한자: a tap of the right Fn, and Right Control on a Type 1 keyboard.
  - 無変換: a tap of the left Alt, or Fn + the left Alt.
  - Play/Pause and volume: Fn+P and Fn+A–D, or Fn + the F-row.
  - The arrows, Home / End / Page keys, Delete and Insert: their own keys or the Fn layer.
  - F1–F12: their own keys or Fn + the number row.
  - Print Screen and Scroll Lock: their own keys or Fn+I / Fn+O.
- **Firmware first.** The keymap lives in the keyboard, so it works on any computer without a
  remapper.

## Reserved for Hardware Control (RHC)

Some Fn combinations are **reserved for hardware control (RHC)**: the slots where a keyboard's
controls of itself go, the same ones on every layout here, so a hand that switches keyboards looks
for them in one place. A reservation, not a restriction: a layout may put anything in an RHC slot,
including actions that have nothing to do with the hardware, and a keyboard with fewer controls
than slots leaves the rest to other uses.

The connection slots (Fn+Q, Fn+1 … 5 and Fn+0) are the HHKB Studio's layout.

| RHC key | Recommended |
|---|---|
| Fn+1 … Fn+5 | Bluetooth profiles: Fn+1 for BT1, Fn+2 for BT2, and so on |
| Fn+0 | USB |
| Fn+- / Fn+= | (none yet) |
| Fn+Q | Bluetooth connect |
| Fn+B | NKRO setting |
| Fn+F5 / Fn+F6 | Backlight brightness down / up |
| Fn+Print Screen | (none yet) |
| Fn+Scroll Lock | (none yet) |
| Fn+Pause | Backlight on/off (a toggle: exception 3 of [idempotency](#1-idempotency)) |

On a board without the key, such as a tenkeyless without Pause, the combination is reserved
wherever that key's function lives.

### The golden layout

Fn+F5 / F6 dim and brighten the backlight, and Fn+Pause turns it on and off, as recommended.
Fn+Print Screen and Fn+Scroll Lock step through the backlight's effects, back and forward. The
other slots hold unrelated actions, which RHC allows: the board is wired only, so Fn+1 … 5 and
Fn+0 / - / = are F1 … F5 and F10 … F12 from the HHKB Fn layer, and Fn+Q is transparent. Fn+B
sets NKRO, as recommended, which leaves Fn+N free for the HHKB's keypad +.

## General tips

For your own sake, and easier development, try to avoid:

- **Using non-standard keys as a state trigger.** For example, F18 as the only way into Korean
  needed middleware on every keyboard whose firmware can't be remapped to F18, including older
  HHKBs: the HHKB Hybrid Type-S can't be remapped beyond F12, so F13–F24 can't be reached in
  firmware alone. Apps take these keys too: on Windows an AutoHotkey hook took the F-keys
  ([low-level-hook-takes-f-keys](../windows-tsf/low-level-hook-takes-f-keys/README.md)), and on
  macOS iTerm keeps F1–F19 ([korean-key-in-iterm](../macos-input-method/korean-key-in-iterm/README.md)).
  A standard key such as 한/영 avoids this.
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
- **Check which Korean keyboard type Windows uses before debugging anything else.** The type
  decides what Right Alt and Right Control send: on Type 1 they are 한/영 and 한자, on Type 2 the
  keyboard needs dedicated 한/영 and 한자 keys, and Type 3 adds Shift+Space for 한/영. Windows keeps
  it as the `LayerDriver KOR` value under
  `HKLM\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters` (`kbd101a.dll`, `kbd103.dll` or
  `kbd101c.dll`; confirm on the test machine). The [tester](../utils/windows-tester/README.md)
  simulates each type.
- **Change one thing at a time, and write down what you changed.** When two things change at once,
  the cause can't be told apart: the cable and the port were swapped together in
  [hall-effect-keyboard-behind-usb-hub](../hardware/hall-effect-keyboard-behind-usb-hub/README.md),
  and Karabiner's settings changed during the test in
  [keycap-legend-language-and-jis](../via/keycap-legend-language-and-jis/README.md).
- **Rule out the hardware before blaming software.** Cable, port, hub or dock, and anything resting
  on the keys: [hall-effect-keyboard-behind-usb-hub](../hardware/hall-effect-keyboard-behind-usb-hub/README.md),
  [usb-c-dock-mouse-not-enumerated](../hardware/usb-c-dock-mouse-not-enumerated/README.md),
  [keyboard-resting-on-laptop](../hardware/keyboard-resting-on-laptop/README.md). Injected keys
  can't reproduce a hardware cause, so record real key presses with a key logger, such as the
  [tester](../utils/windows-tester/README.md) on a Mac.

## Rule of thumb

Imagine you got a blank set of keycaps and engraved them however you like, in whatever language,
for any target audience. Would that audience know how to use the keyboard without searching
"\<your company\> keyboard how to use" every day?
