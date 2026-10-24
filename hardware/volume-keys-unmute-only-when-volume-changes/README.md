# Volume up or down doesn't unmute a USB DAC without volume control

**Status:** open; hardware and macOS (2026-10-24).

## Setup

- Computer: Mac mini, Apple Silicon, macOS 27.0.1 (26A434).
- Output: QUAD USB, a USB DAC, as the default output and default system output.
- Keyboards, both over USB, stock firmware, tested one at a time:
  - HHKB Hybrid Type-S (JIS).
  - MONGDOL 87 (US ANSI, TKL).

### Devices *(measured with `ioreg -p IOUSB` and CoreAudio)*

| Device | Vendor string | VID:PID | bcdDevice | USB location | Behind |
|---|---|---|---|---|---|
| QUAD USB (DAC) | VIA Technologie | `0x2622:0x0102` | `0x0101` | `0x00131000` | Generic USB2.1 Hub `0x0BDA:0x5409` |
| HHKB-Hybrid | PFU Limited | `0x04FE:0x0022` | `0x0001` | `0x00114000` | ARTMUKOREA USB2.0 Hub `0x3447:0x2520` |
| MONGDOL 87 | RDMCTMZT | `0x36B0:0x3198` | `0x0010` | `0x00143000` | VIA Labs USB2.0 Hub `0x2109:0x2822` |

The same Generic hub as the DAC also has a Realtek "HID Device" (`0x0BDA:0x1100`) on it. Whether
that belongs to the DAC isn't known.

CoreAudio controls on the output scope, main element:

| Output | Volume (`kAudioDevicePropertyVolumeScalar`) | Mute (`kAudioDevicePropertyMute`) |
|---|---|---|
| QUAD USB | **none** | yes, settable |
| RØDE NT-USB+ (USB) | yes, settable | yes, settable |
| Mac mini Speakers | yes, settable | yes, settable |

The DAC's device UID is `AppleUSBAudioEngine:VIA Technologie:QUAD USB:131000:1`.

## Symptom

With the DAC as the output and muted, pressing volume up or volume down on the keyboard doesn't
unmute it. On an output that has a volume control, either key normally unmutes.

Seen on both the HHKB Hybrid and the MONGDOL 87, so it isn't one keyboard's firmware.

## Why, probably

The DAC exposes a mute control but no volume control, so macOS has no volume to change. The volume
keys look like they do nothing at all on such an output, including the unmute that normally comes
with them. That's an inference from the controls above; macOS's handling of the keys hasn't been
traced.

## What to do

Unmute some other way, such as the mute key or System Settings → Sound. Neither has been
recorded as tested here.

## Checking another DAC

```sh
ioreg -p IOUSB -w0 | sed 's/<class.*//'    # USB tree and locations
system_profiler SPAudioDataType            # default output
```

For the volume and mute controls, query `kAudioDevicePropertyVolumeScalar` and
`kAudioDevicePropertyMute` on the output scope with `AudioObjectHasProperty` and
`AudioObjectIsPropertySettable`. An output with mute but no volume should show the same symptom.
