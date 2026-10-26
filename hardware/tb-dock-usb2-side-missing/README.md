# An HHKB Studio not seen over USB, behind a Thunderbolt dock with no USB 2.0 side

**Status:** fixed by power-cycling the dock; hardware (2026-10-26).

## Setup

- Computer: MacBook Air, Apple M4, macOS 27.0.1.
- Keyboard: HHKB Studio (JIS), stock firmware, over USB-C.
- Dock: ARTMU T4D210 (Thunderbolt 4 / USB4 DOCK, vendor ARTMUKOREA CO.,LTD), firmware 36.0,
  connected in USB4 mode at 40 Gb/s. It had worked with the keyboard the day before.

## Symptom

On the dock, the keyboard didn't type over USB. All four LEDs stayed blue. Re-plugging, power
off and on, and Fn (`KeyHHKBUniversalFunction`) + Control (`KeyLeftControl`) + 0 (`KeyZero`)
didn't help; the last turned the LEDs off for a moment. With the batteries out the LEDs still
lit, so the keyboard was getting power from the cable.

## What the LEDs mean

[PFU's manual](https://happyhackingkb.com/manual/studio/ug-us/en/ug/topic/led_status.html):
all four LEDs blue is **USB**; Bluetooth lights only the LED of its slot (1 to 4). Waiting for a
USB connection, all four light blue and then turn off. Staying on isn't described; here it was
the keyboard waiting on USB for a computer that never answered. It was not falling back to
Bluetooth.

## What was found *(measured with `system_profiler SPUSBHostDataType` and `ioreg -p IOUSB`)*

- No device with PFU's vendor ID (`0x04FE`) on the bus, and no USB attach, failure or
  accessory-block messages in `log show` for the previous 30 minutes. The Mac never saw a
  connection attempt, so macOS's accessory approval wasn't the cause.
- Behind the dock, only its 10 Gb/s USB 3 side was listed: an Intel hub (`0x8087:0x0b40`), two
  VIA Labs USB3.1 hubs (`0x2109:0x0822`) and a Realtek 2.5G LAN adapter (`0x0bda:0x8156`). The
  dock's 480 Mb/s USB 2.0 side was missing entirely.
- The keyboard is a full-speed (12 Mb/s) device, so it can only connect through a hub's USB 2.0
  side. The LAN adapter, on the USB 3 side, kept working, so the dock looked fine.

## What fixed it

1. Plugged straight into the MacBook, the keyboard connected (15:21:23) on the MacBook's other
   USB bus, not behind the dock: `HHKB-Studio`, PFU Limited, full speed. The cable had been
   swapped just before this, so this step alone doesn't separate cable from dock.
2. The dock was unplugged from power for a few seconds and reconnected. Its USB 2.0 side came
   back: a Fresco Logic USB2.0 hub (`0x1d5c:0x5801`), a Texas Instruments power-delivery
   controller ("TPS DMC Family", `0x0451:0xace1`) and two VIA Labs USB2.0 hubs (`0x2109:0x2822`).
3. Back on the dock, the keyboard connected (15:24:42) at `0x01130000`, on the dock's USB 2.0
   hub, 12 Mb/s.

Why the dock's USB 2.0 side dropped out isn't known.

## How to tell

```sh
system_profiler SPUSBHostDataType | grep -E 'Hub:|Manufacturer|Link Speed|Location ID'
```

Behind a dock, look for a USB 2.0 hub at 480 Mb/s next to the USB 3 one. If only the 5 or
10 Gb/s hubs are there, low- and full-speed devices on the dock (keyboards, mice, numpads) can't
connect, while fast ones still do.

## What to try, in order

1. Plug the keyboard straight into the computer. If it works there, it's the dock.
2. Unplug the dock from power and the computer for about 10 seconds; reconnect the dock first,
   then the keyboard.

## Related

- [usb-c-dock-mouse-not-enumerated](../usb-c-dock-mouse-not-enumerated/README.md): a USB mouse
  behind a USB-C dock's VIA Labs hub (VID 2109), on Windows. Whether its USB 2.0 side was
  missing too isn't recorded.
- [hall-effect-keyboard-behind-usb-hub](../hall-effect-keyboard-behind-usb-hub/README.md): a
  keyboard dead behind a USB hub; another cable and port fixed it.
