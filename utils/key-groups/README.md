# key-groups

Several physical keys acting as one key, on macOS: for example one wide bar resting on two
switches, where Space should stay down until the last switch is released. Each group has member
keys, one output key, and a rule:

| Rule | Output held while | Use |
|---|---|---|
| `or` (`any`) | any member is held | A bar on two or more switches |
| `and` (`all`) | every member is held | A chord, or a bar that must be pressed flat |
| `xor` | an odd number of members is held (for two keys: exactly one) | |
| `one` | exactly one member is held | |
| `NofM` | at least N of the M members are held, e.g. `2of3` | A long bar on three or four switches |

The output goes down when the rule becomes true and up when it becomes false. A held output
repeats while a member repeats. Member keys never reach apps; everything else passes through.

```sh
utils/key-groups/build.sh                 # build/KeyGroups.app: swiftc, ad-hoc signed, then the self-test
open utils/key-groups/build/KeyGroups.app
```

No Xcode project. Build it yourself, and delete `build/` when you're done: it's ignored by git.

## Using it

- **Set up a group:** Record Keys, press the keys that make up the group, then Done; Record Key and
  press the key it sends; pick the rule (and N, for N of M). Groups are saved between launches. A
  group that can't be used yet says why (fewer than two keys, no output, a key in two groups…).
- **Try it here:** with System-wide off, keys pressed while the window is in front go through the
  groups, and the log shows each press and the output it causes (`A ↑    → Space ↑`). Ordinary
  letter keys work, and it needs no permission: nothing leaves the window.
- **System-wide:** the switch applies the groups in every app. It needs Accessibility (the Allow…
  button opens the setting): catching keys before apps see them and sending others in their place
  needs it, whatever the keys. Member keys never reach apps while it's on. Recording a group pauses
  it, so the keys reach the window. An ad-hoc signed rebuild may need to be allowed again.

For system-wide use, give each key in a group its own key code first, one nothing else uses (F13
to F20), in the keyboard's own keymap tool: VIA, or
[viahid](../../via/raw-hid-keymap-editing/README.md) (`KC_F13` is 0x68, `KC_F14` 0x69, …), or PFU's
Keymap Tool on an HHKB. Example: on the HHKB Studio JIS, 英数 → F13 and かな → F14 for a bar over
英数, Space and かな. With letter keys as members, those letters stop typing everywhere while it's on.

Quitting, or turning System-wide off, lets go of any output still held, so no key is left stuck down.

## Why not just map both switches to Space

Map both switches to the same key in firmware, and releasing either one can send Space up while the
other is still held: QMK, for one, does that (`unregister_code` takes the key out of the report).
Whether a keyboard's own firmware does it can be checked with
[keyboard-health-check](../keyboard-health-check/README.md): hold one key, press and release the
other, and watch for an early ↑. key-groups counts members instead, so `or` only lets go when the
last one is up. On a QMK board, the same counting can go in the firmware instead.

## Limits

- **Host-side only:** it works on the Mac it runs on, and only while it's running with System-wide on. On another computer
  the members send their F-keys.
- **Secure input:** while a password field (or any app using Secure Event Input) has focus, event
  taps don't see keys, so members reach the app as F13, F14… and the group does nothing.
- **Karabiner-Elements:** the tap sees Karabiner's output. Leave the member F-keys alone in
  Karabiner, or remap there instead.
- **No timing:** `and` and `NofM` are about which members are held now, not about pressing them
  within a time window.
