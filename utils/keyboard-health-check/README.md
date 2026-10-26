# keyboard-health-check

A Mac app for checking an old or suspect keyboard. While its window is focused, it logs every key
down (↓) and up (↑), and lights the key on three full-size boards drawn on screen: US ANSI
(108 keys), ISO (109) and JIS (113). Each is the standard full-size board (104 / 105 / 109) plus
four keys above the numpad: Mute, Vol−, Vol+ and Calc. Press every key once: what stays gray never
registered.

```sh
utils/keyboard-health-check/build.sh          # build/KeyboardHealthCheck.app: swiftc, ad-hoc signed, then the self-test
open utils/keyboard-health-check/build/KeyboardHealthCheck.app
```

No Xcode project. Build it yourself, and delete `build/` when you're done: it's ignored by git.

## Reading it

- **Colors:** gray untested, blue held now, green registered at least once, orange possible chatter.
- **Chatter:** a press within 30 ms of the same key's last release is flagged `⚠ … chatter?`. A
  worn switch bouncing types the key twice from one press.
- **Each log line** has the time, the key's legend, its canonical name from
  [KEYNAMES.md](../../conventions/keynames/REV1-20261025/KEYNAMES.md), its HID usage
  (`page:usage`), the press count, how long it was held, and the device that sent it.
- **Warnings** (orange in the log): a second down without an up, and the keyboard's own rollover
  error (too many keys at once, or a fault in the key matrix).
- **Device** narrows the boards and the log to one keyboard, when several are connected.
- **CLEAR** empties the log; **EXPORT** saves it as a text file; **Reset keys** turns every key gray
  again.

## Two ways of reading keys

- **HID (with Input Monitoring):** reads the keyboards with IOHIDManager, without seizing them, so
  each press comes with the device's name and VID:PID, and arrives as the usage the keyboard really
  sent: Print Screen, Insert and Num Lock as themselves, and 無変換, 変換 and カタカナ, which macOS
  doesn't pass to apps (see [japanese-keycodes-on-macos](../../qmk/japanese-keycodes-on-macos/README.md)).
  Keys are only logged while the window is focused. The first launch asks for Input Monitoring;
  allow it in System Settings → Privacy & Security → Input Monitoring, then quit and reopen the app.
  An ad-hoc signed rebuild may need to be allowed again.
- **macOS key events (without it):** the fallback. No device names; Print Screen, Scroll Lock and
  Pause arrive as F13–F15, Insert as Help and Num Lock as keypad Clear, which the app maps back;
  無変換 and 変換 never arrive, and カタカナ arrives as かな. The status line says which is in use.

## Limits

- **Nothing is blocked:** media keys still change the volume, and in HID mode the keys still reach
  macOS. The app swallows key events in its own window, so ⌘Q doesn't quit it: close the window.
- **A keyboard's Fn never reaches the computer,** so it can't be tested; test it through the keys
  of its layer (e.g. Fn + F-key media keys).
- **Karabiner-Elements** seizes the keyboards it modifies; their presses then come from
  `Karabiner DriverKit VirtualHIDKeyboard` instead of the keyboard itself. Pick "All keyboards", or
  exclude the keyboard in Karabiner's Devices settings while testing.
- **The four extra keys** above the numpad are drawn as Mute, Vol−, Vol+ and Calc. Not every
  108-key board has those: the Deck Hassium's are Fn, Nkey (rollover), Pn and Toggle, handled in its
  firmware, so they never reach the computer and stay gray. A key a board doesn't have stays gray.
