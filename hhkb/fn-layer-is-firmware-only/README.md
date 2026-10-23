# The HHKB's Fn layer lives in its firmware

On an HHKB Professional (2, BT, and similar), Fn never reaches the computer. The keyboard handles it
and sends a different keycode instead: Fn+6 arrives as F6, Fn+`` ` `` as forward Delete, Fn+[ as ↑.
To macOS and Karabiner-Elements, those look exactly like dedicated keys.

What follows from that:
- **Fn can't be moved.** A remapper never sees Fn, so it can't put Fn on another key, or turn it
  into anything else.
- **Remaps don't reach the Fn layer.** Karabiner's rule for `` ` `` doesn't change Fn+`` ` ``,
  which arrives as `delete_forward`. That's useful: `` ` `` can become Backspace while Fn+`` ` ``
  stays forward Delete.
- **A rule on `f6` acts on Fn+6 too.** Karabiner can't tell a real F6 from Fn+6.
- **A second Fn key has to rebuild the layer.** To get Fn on right ◇, where an HHKB JIS has it,
  Karabiner holds a variable while the key is down and sends each Fn key itself (F1–F12, Insert,
  Delete, Caps Lock, arrows, Home/End/Page keys, the keypad keys, volume and eject). See the rules
  in [hhkb-pro-bt-us-to-jis](../../layouts/hhkb-pro-bt-us-to-jis/README.md).

Checked on an HHKB Professional BT (US) in Mac mode (DIP SW2 on), with Karabiner-Elements 16.3.
