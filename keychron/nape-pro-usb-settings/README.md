# Keychron Nape Pro: reading and changing its settings over USB

The Nape Pro is Keychron's trackball, with six buttons, a small round button, a dial and a 25 mm
ball. Keychron Launcher sets it up in the browser, but over USB it answers VIA's raw-HID protocol
plus Keychron's own `a7` commands. Its button keymap and its trackball settings (DPI, ball
orientation, gestures) can be read and written from a script, with no browser.

The commands come from Launcher's own JavaScript (`launcher.keychron.com/main.*.js`, fetched
2026-11-08) and from Launcher's device definition for the Nape Pro (see "Sources"). Each command
listed as verified was checked on the device.

Tested on macOS 27 (Apple Silicon), Nape Pro over USB-C, firmware `v1.1.6-ZK` and then `v1.3.0-ZK`.

## The tester's setup

The Nape Pro sits with the mouse buttons (M1, M2) pointing north, away from the body. Wanted:

| Control | Does |
|---|---|
| M2 | left click |
| M1 | right click |
| ButtonOne, ButtonTwo | scroll with the ball while held |
| ButtonFour | back (mouse 4) |
| ButtonThree | forward (mouse 5) |
| CircleButton | 2.4 GHz pairing (see "2.4 GHz receiver") |
| Dial | clockwise → (right arrow), counter-clockwise ← (left arrow) |
| Ball | finger up → pointer up, finger right → pointer right |
| Ball while scrolling | finger up → scroll down, finger right → scroll left |
| Sensitivity | as low as the device goes: step 0, 400 DPI |
| Connection | 2.4 GHz, through a Keychron Link-KM receiver |

Done with a keymap file and three trackball settings. The keymap and orientation are set on every
layer (0–8), so they work whichever layer is active:

```sh
swiftc -O -o naperaw naperaw.swift
./apply.sh ./naperaw layout-themrsung.txt                  # buttons and dial
./trackball.sh ./naperaw angle 180                         # ball orientation
for L in {0..8}; do ./trackball.sh ./naperaw layer-angle $L 180; done
./trackball.sh ./naperaw dpi 0                             # use step 0 (400 DPI)
```

Over the receiver instead of the cable, put `NAPE_PID=0xd026` in front of each command (see
"2.4 GHz receiver").

- [layout-themrsung.txt](layout-themrsung.txt): the keymap. Every layer is `00d5 00d4 522a 522a
  00d2 00d1 7e04`, and the dial is `0050` / `004f` (`KC_LEFT` / `KC_RGHT`). This is shipped
  layer 1 with `CircleButton` changed from `MO(11)` to `7e04` (Keychron's "2.4G Pair").
- [trackball-themrsung.txt](trackball-themrsung.txt): `trackball.sh show` afterwards. Orientation
  (180°) and the DPI step in use (0) differ from the factory settings.
- Confirmed by the tester: buttons, pointer direction and scroll direction. The dial was changed
  to arrow keys afterwards; its direction hasn't been confirmed yet.
- Wanted but not possible on the device: ↓ / ↑ on the dial while ButtonOne or ButtonTwo is held.
  See "The dial can't change while scrolling".
- DPI: the factory step 0 (400) still felt too fast, but nothing on the device goes lower. See
  "DPI values can't be changed".

Why 180°: at 0° both the pointer and the scroll were wrong on both axes. Rotating the ball by
180° fixed both at once, because the firmware rotates the ball's motion before deciding between
pointer and scroll. No macOS setting (Natural scrolling) or Karabiner rule was needed.

## Tools

```sh
swiftc -O -o naperaw naperaw.swift
./snapshot.sh ./naperaw > backup.txt          # read-only: firmware, keymap, dial
./apply.sh ./naperaw backup.txt               # write a snapshot's keymap and dial, then verify
./trackball.sh ./naperaw show                 # read-only: DPI, orientation, gestures, sleep, battery
./trackball.sh ./naperaw dpi 1                # also dpi-value, angle, layer-angle, gesture, force
./naperaw via 01                              # one raw report; prints what was sent and the reply
NAPE_PID=0xd026 ./trackball.sh ./naperaw show # any of the above through the 2.4 GHz receiver
```

- `snapshot.sh` and `trackball.sh show` only read. Take a snapshot before writing anything.
- `apply.sh` writes each key with `DYNAMIC_KEYMAP_SET_KEYCODE` (`0x05`) and the dial with
  `DYNAMIC_KEYMAP_SET_ENCODER` (`0x15`). It then reads everything back and diffs it against the
  file. It uses only the `layer N:` lines: 9 lines of 7 keycodes, then 9 lines of 2 for the dial.
- `trackball.sh` follows every write with the matching read, so it prints what the device holds.
- `naperaw` sends exactly the bytes it's given. The reply prints as `via <`. Reports the device
  sends on its own print as `via ~` (see "Status report"). Read "Don't send" first.

Other files:
- [snapshot-v1.3.0.txt](snapshot-v1.3.0.txt): the keymap as shipped. `apply.sh` it to go back.
- [test-number-keys.txt](test-number-keys.txt): `1`–`7` on the buttons and `8`/`9` on the dial,
  used to find out which control is which.

## 2.4 GHz receiver (Keychron Link-KM)

The receiver is a Keychron Link-KM: VID 0x3434, PID 0xD026. It has the same interface set as the
Nape Pro: keyboard and mouse (page 0x01), VIA raw HID (0xFF60 / 0x61) and 0x8C.

### Pairing

The Nape Pro didn't connect to the receiver on its own; the receiver may have shipped paired with
nothing, or with another device. What worked:

1. Put Keychron's "2.4G Pair" keycode (`7e04`, `CUSTOM(4)` in Launcher's definition) on a button.
   This needs the cable, or an existing receiver link. Here it's `CircleButton`, on every layer.
2. Unplug the Nape Pro's USB-C cable.
3. Press that button. The Nape Pro's LED flashes: it's in pairing mode.
4. **Unplug the receiver and plug it back in** while the LED is still flashing. Pressing the button
   alone wasn't enough: the receiver has to be freshly plugged in too, probably because it only
   accepts pairing for a short time after it starts.
5. Move the ball. It connected within a few seconds.

Not checked: whether a connection-mode switch on the Nape Pro matters, and whether the shipped
`MO(11)` on `CircleButton` is Keychron's own pairing or connection button.

### Settings through the receiver

Once paired, the receiver passes VIA and `a7` commands through to the Nape Pro. Every read and write
in this folder works with the receiver's PID:

```sh
NAPE_PID=0xd026 ./snapshot.sh ./naperaw
NAPE_PID=0xd026 ./apply.sh ./naperaw layout-themrsung.txt
NAPE_PID=0xd026 ./trackball.sh ./naperaw show
```

- Through the receiver, the replies are the same as over the cable: protocol 12, 9 layers,
  `v1.3.0-ZK`, the keymap, orientation and DPI. `snapshot.sh`'s `# usb` section is empty, because it
  looks the cable device up by name. `NAPE_USB_NAME="Keychron Link-KM"` shows the receiver's
  instead.
- **A command can get no reply over the radio.** One `apply.sh` run stopped at
  `dial write layer 4 failed:` with an empty reply. Running it again succeeded. Its writes set
  values rather than toggle them, so a retry is safe.
- The receiver doesn't answer `bc`, the query Launcher uses to ask a receiver which devices are
  connected. It sends back a report starting `ff`, before and after pairing alike.
- Don't send anything on the receiver's 0x8C interface either: it's the same firmware-update
  channel as on the Nape Pro.

## USB interfaces

VID 0x3434, PID 0x0440, serial `0123456789ABCDEF`. bcdDevice is the firmware version: 0x0116 on
v1.1.6, 0x0130 on v1.3.0. Launcher's definition calls the bootloader `telink`.

| Interface | Usage page / usage | Reports | Use |
|---|---|---|---|
| 0 | 0x01 / 0x06 | ID 1 keyboard, ID 2 consumer, ID 3 mouse (5 buttons, 16-bit X/Y, wheel, AC Pan) | Typing, clicking, pointing |
| 1 | 0xFF60 / 0x61 | 32 bytes in/out, no report ID | VIA raw HID, and every setting below |
| 2 | 0x8C / 0x01 | in ID 0xB1, out ID 0xB2, 32 bytes each | Firmware update channel: Launcher's bootloader jump and Bluetooth updates write report 0xB2 |

macOS asks for no permission to open interfaces 1 and 2.

## Don't send

- **Anything on interface 2 (0x8C).** Launcher uses it for `bootloaderSwitch` and firmware
  transfer.
- **`a7 14 …`.** Launcher's `resetKeyMapSingleKey`.
- **`a7 39` (`SET_LAYER_ORI`) for layers 9 and above.** Reading them with `a7 38` returns `52` for
  layer 10 and `90` for layer 11. Those aren't angles, so they're probably neighbouring memory, and
  writing there could overwrite it. Layers 0–8 are fine.
- **The `a7 20 <sub>` "Nape_Settings" group.** Launcher's code also has a command set under
  `a7 20`, but on this firmware `a7 20` is `GET_ORI` and every reply has `[2] = 00`. Early probes
  sent `a7 20 xx` and only read orientation. The working commands are the flat `a7 <cmd>` below.

## Buttons (matrix 1 × 7)

Launcher reads each layer as 14 bytes, at row 0, col 0–6. The number test confirmed which control
each column is. The names in the "Name" column are the tester's; they aren't in KEYNAMES.md yet.

| Label | Name | Col | Where (ball at 0°) | Number test | Shipped, layer 0 | Shipped, layer 1 (active) | Tester's layout |
|---|---|---|---|---|---|---|---|
| 03 | `ButtonThree` | 0 | top left | 1 | `MO(10)` scroll | `MS_BTN5` forward | `MS_BTN5` forward |
| 04 | `ButtonFour` | 1 | top right | 2 | `KC_NO` | `MS_BTN4` back | `MS_BTN4` back |
| 01 | `ButtonOne` | 2 | middle left | 3 | `MS_BTN4` back | `MO(10)` scroll | `MO(10)` scroll |
| 02 | `ButtonTwo` | 3 | middle right | 4 | `KC_NO` | `MO(10)` scroll | `MO(10)` scroll |
| M1 | `MouseOne` | 4 | bottom left | 5 | `MS_BTN1` left click | `MS_BTN2` right click | `MS_BTN2` right click |
| M2 | `MouseTwo` | 5 | bottom right | 6 | `MS_BTN2` right click | `MS_BTN1` left click | `MS_BTN1` left click |
| (none) | `CircleButton` | 6 | small round button next to 04 | 7 | `MO(11)` unknown | `MO(11)` unknown | `7e04` 2.4 GHz pairing |
| – | `WheelCounterClockwise` | enc 0 ccw | dial | 8 | `KC_UP` | `KC_LEFT` | `KC_LEFT` |
| – | `WheelClockwise` | enc 0 cw | dial | 9 | `KC_DOWN` | `KC_RGHT` | `KC_RGHT` |

- "Where" is from Launcher's definition, which draws the ball at 0°. On the tester's desk the
  mouse buttons point away from the body.
- `CircleButton` is the only round button and looks like a Bluetooth connect button. Launcher's
  definition calls it `knob` and draws it at the dial's height, but it isn't a dial press. No
  column is a dial press; the dial only turns.
- On the tester's unit, layer 1 is active: `a3` (default layer) answers `01`, and the status
  report says layer 1. Before any changes, M1 gave right click and M2 gave left click, which is
  layer 1's shipped keymap.
- There are 9 stored layers (`11` → `09`). Layers 9, 10 and 11 are firmware modes, not stored
  layers. Launcher labels `MO(9)` "gesture" and `MO(10)` "scroll", and has no label for `MO(11)`.

### Scrolling: `MO(10)` doesn't take over the other buttons

`MO(10)` is the firmware's "scroll while held". While it's held, the ball scrolls and every other
key falls through to the stored layers.

Tested with the number keymap and `MO(10)` on `CircleButton` in layer 1. While holding it, the ball
scrolled, and M1, M2, 01, 02, 03, 04 and the dial still typed 5, 6, 3, 4, 1, 2, 8, 9. So any button
on any layer can be a scroll key without changing the rest of the keymap.

The tester had seen Keychron's scroll setting change their other keys. Written directly over USB,
only the one key changes.

There's no per-layer "ball scrolls" setting in Launcher's protocol. The only other scroll control
is the global "force scroll" flag (`a7 32`), which wasn't tested.

### The dial can't change while scrolling

The dial falls through like every key. While `MO(10)` is held it sends whatever the stored layers
give it, so it can't be ← / → normally and ↓ / ↑ only while scrolling. Layer 10 has no stored
dial: `14 0a 00 0x` reads `0000`, the same for layers 9 and 11. Don't write it either. This
firmware doesn't bounds-check every per-layer command (see "Don't send"). Ways around it:

- Use a second, real layer: a button with `MO(2)`, and the dial set to ↑ / ↓ in layer 2. While
  that button is held, the ball moves the pointer instead of scrolling.
- On the Mac, with Karabiner-Elements: the scroll button and the dial send unused keys, and a rule
  does the scrolling (`mouse_motion_to_scroll`) and picks the dial's arrows. Only on Macs with
  Karabiner.

Not checked:
- Which layer keys fall through to when layers differ. All layers were identical in the test.
- Whether `TG(10)` (`0x526a`) toggles scrolling. It was written to ButtonFour once but not tried.

## Ball orientation

`a7 34 n` sets the angle to n × 45°, and `a7 39 L n` sets the angle used while layer L is active.
Launcher's own orientation control writes the layer angle for the current layer. The tester's fix
was 180° in both places (`a7 34 04`, and `a7 39 L 04` for L = 0–8), and it took effect at once.

The rotation applies to scrolling as well as pointing. One 180° turn corrected both pointer axes and
both scroll axes. Keychron's custom keycodes can also change it from a button: orientation ±, a
fixed angle, or a loop (see below).

## Pitfalls

### Buffer writes don't reach the buttons

`DYNAMIC_KEYMAP_SET_BUFFER` (`0x13`) wrote the number keymap, and both `0x12` and `0x04` read it
back. The buttons still kept their old keys. Writing the same keycodes again one at a time with
`DYNAMIC_KEYMAP_SET_KEYCODE` (`0x05`, the command Launcher uses) took effect at once, with no
replug. Dial writes with `0x15` took effect at once. Whether a replug would also have loaded the
`0x13` writes wasn't tested.

### DPI values can't be changed

Switching DPI steps works, but changing a step's value doesn't, on firmware v1.3.0:

- `a7 23 00 <value LE>` (`SET_DPI_VALUE`) answered OK, and `a7 24 00` read back 200, 100 and then 1.
  The ball still felt like 400 every time: after reselecting step 0, after switching to step 1 and
  back, and after a restart (cable out, switch off, cable in).
- Switching to step 4 (`a7 22 04`) made the ball much faster, so the step number is applied at
  once.
- `a7 37 64 00` (custom DPI = 100) answered OK, but `a7 36` still read 400. Launcher's keycode table
  has a "custom DPI" key (`CUSTOM(47)`), but the Nape Pro's definition stops at `CUSTOM(46)`.

So each step has a built-in speed (400, 800, 1600, 3200, 4000), and the values only change what's
stored and shown. Step 0 was put back to 400 to match. For slower than 400, use macOS's Tracking
speed (System Settings → Mouse), which applies to every mouse. Not checked: whether Keychron
Launcher can change it, for example with a command this firmware handles differently.

### Status report

After a setting changes, the device sends a report of its own on interface 1: `a3 <layer> <angle /
45> <dpi step>`. For example, `a3 01 04 02` means layer 1, 180°, DPI step 2. It can arrive before
the reply to the command that caused it. Launcher listens for these to follow the active layer.
`naperaw` used to stop at the first report, which made `trackball.sh angle` print `reply: a3 …`.
It now waits for the reply that starts with the command it sent (`a7 <cmd>`, or the VIA command
byte) and prints any others with `~`.

## Keymap as shipped (unchanged by the v1.1.6 → v1.3.0 update)

| Layer | Col 0 | Col 1 | Col 2 | Col 3 | Col 4 | Col 5 | Col 6 | Dial ccw / cw |
|---|---|---|---|---|---|---|---|---|
| 0 | `522a` | `0000` | `00d4` | `0000` | `00d1` | `00d2` | `522b` | `0052` / `0051` |
| 1 | `00d5` | `00d4` | `522a` | `522a` | `00d2` | `00d1` | `522b` | `0050` / `004f` |
| 2 | `00ae` | `00ae` | `00d4` | `7e2c` | `00d1` | `00d2` | `522b` | `0052` / `0051` |
| 3–8 | `522a` | `7e2b` | `00d4` | `7e2c` | `00d1` | `00d2` | `522b` | `0052` / `0051` |

Keycodes in protocol-12 numbering:

| Value | QMK / Keychron | Canonical name |
|---|---|---|
| `00d1` / `00d2` | `MS_BTN1` / `MS_BTN2` | `KeyLeftMouseButton` / `KeyRightMouseButton` |
| `00d4` / `00d5` | `MS_BTN4` / `MS_BTN5` | `KeyMouseButtonFour` / `KeyMouseButtonFive` |
| `00d9` / `00da` | `MS_WHLU` / `MS_WHLD` | `KeyMouseWheelUp` / `KeyMouseWheelDown` |
| `00ae` | `KC_MPLY` (shipped on layer 2) | `KeyMediaPlayPause` |
| `0052` / `0051` | `KC_UP` / `KC_DOWN` | `KeyUpArrow` / `KeyDownArrow` |
| `0050` / `004f` | `KC_LEFT` / `KC_RGHT` | `KeyLeftArrow` / `KeyRightArrow` |
| `001e` … `0026` | `KC_1` … `KC_9` (number test) | `KeyOne` … `KeyNine` |
| `0000` | `KC_NO` | no key |
| `5229` / `522a` | `MO(9)` gesture / `MO(10)` scroll | firmware modes; `MO(10)` keeps the other keys |
| `522b` | `MO(11)` | unknown firmware mode, shipped on `CircleButton` |
| `526a` | `TG(10)` | untested |
| `7e00` + n | Keychron `CUSTOM(n)` | see below |

Keychron's custom keycodes on the Nape Pro (`customKeycodes` in the definition, index n):

| n | Value | Keycode |
|---|---|---|
| 0–2 | `7e00`–`7e02` | Bluetooth host 1–3 |
| 3 | `7e03` | bootloader (DFU) |
| 4 | `7e04` | 2.4 GHz pairing |
| 5–25 | `7e05`–`7e19` | macOS / Windows shortcuts: screen lock, desktops, emoji, Siri, battery level, … |
| 26 / 27 | `7e1a` / `7e1b` | orientation + / − |
| 28–35 | `7e1c`–`7e23` | orientation 0°, 45°, … 315° |
| 37 / 38 | `7e25` / `7e26` | DPI + / − |
| 39 / 40 | `7e27` / `7e28` | report rate + / − |
| 43 | `7e2b` | orientation loop |
| 44 | `7e2c` | DPI loop |
| 45 | `7e2d` | report rate loop |
| 46 | `7e2e` | double left click |

## Trackball settings (`a7 <cmd> …` on interface 1)

The reply echoes `a7 <cmd>`. For a set, `[2] = 00` means OK. Multi-byte values are little-endian.
"Factory" is what v1.3.0 held before any changes; the tester's values are in
[trackball-themrsung.txt](trackball-themrsung.txt).

| Cmd | Name in Launcher | Request args | Reply | Factory | Write verified |
|---|---|---|---|---|---|
| `21` / `22` | `NAPE_GET_DPI` / `SET_DPI` | set: step | `[2]` step | step 2 | yes: takes effect at once (step 4 felt much faster) |
| `3c` / `3d` | DPI gear (step count) get / set | set: count | `[2]` count | 5 | no |
| `24` / `23` | `NAPE_GET_DPI_VALUE` / `SET_DPI_VALUE` | step (+ value LE) | `[2..3]` DPI | 400, 800, 1600, 3200, 4000 | stored, but no effect (see "DPI values can't be changed") |
| `36` / `37` | custom DPI get / set | set: value LE | `[2..3]` | 400 | no: answers OK, still reads 400 |
| `20` / `34` | `NAPE_GET_ORI` / `SET_ORI` | set: angle / 45 | `[2]` × 45° | 0° | yes: 180° |
| `38` / `39` | `NAPE_GET_LAYER_ORI` / `SET_LAYER_ORI` | layer (+ angle / 45) | `[2]` × 45° | 0° on layers 0–8 | yes: 180° on 0–8 |
| `2a` / `29` | `NAPE_GET_GESTURE` / `SET_GESTURE` | set: up, down, left, right keycodes LE | `[2..9]` | all `0000` | no |
| `33` / `32` | force gesture / scroll get / set | set: gesture, scroll (0/1) | `[2]`, `[3]` | 0 / 0 | no |
| `0b` / `0c` | sleep get / set | | `[3..4]` backlight, `[5..6]` sleep | 300 / 600 (units not checked) | no |
| `0d` / `0e` | poll rate get / set | | see below | not decoded | no |
| `31` | `NAPE_GET_BAT_REPORT` | | `[2]` %, `[3]` probably charging state | 100; `[3]` 01 or 02 on the cable, 00 on the receiver | read only |
| `26` / `25`, `2f` | `NAPE_GET_TAPHOLDS` / `SET_TAPHOLDS`, `DEL_TAPHOLDS` | layer, row, col | | none set | no |
| `28` / `27`, `2e` | `NAPE_GET_COMBOS` / `SET_COMBOS`, `DEL_COMBOS` | index | | none set | no |
| `2d` | `NAPE_SET_LAYER` | layer | | | not sent |

Poll rate replies `00 e8 03 58 06 00 e8 03 58 06 00 7d`. Launcher reads a support mask in `[5]`
and the rate as 8000 >> `[6]`, which gives 125 Hz, yet `[3..4]` is 1000. That doesn't add up yet,
so the set command isn't in `trackball.sh`.

## Firmware v1.1.6 → v1.3.0

USB descriptors, VIA protocol (12), layers (9), macros (16, 2394 bytes), Keychron `a0`/`a2`/`a3`
and keymap layers 0–3 are all unchanged; only `a1` and bcdDevice differ. Layers 4–8, and all but
the first bytes of the dial, weren't recorded before the update.

| Command | v1.1.6 | v1.3.0 |
|---|---|---|
| `a1` firmware string | `v1.1.6-ZK Mar  9 2026 16:31:16` | `v1.3.0-ZK Aug 20 2026 08:35:53` |
| bcdDevice | 0x0116 | 0x0130 |

Reviews say it runs ZMK. Over USB it speaks QMK's VIA protocol.

## Sources

- [Keychron's product page](https://www.keychron.com/products/keychron-nape-pro-wireless-trackball-mouse)
- Launcher's device definition: `https://launcher.keychron.com/static/device/875824192/json/v3.json`
  (875824192 = 0x3434 × 65536 + 0x0440). It holds the button positions and custom keycodes; it has
  no `matrix` block.
- [Keychron/qmk_firmware](https://github.com/Keychron/qmk_firmware) has no Nape Pro source in any
  branch (checked 2026-11-08).
