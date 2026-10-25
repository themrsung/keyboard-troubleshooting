# macOS's volume keys unmute only when the volume changes

**Status:** finding; macOS (2026-10-24).

## Finding

On macOS, pressing volume up (`KeyVolumeUp`) or volume down (`KeyVolumeDown`) while muted usually
unmutes as a side effect. That isn't always true: with a USB DAC that has no volume control
(QUAD USB) as the output, neither key unmutes it.

The unmute seems to happen only when the volume actually changes. That's inferred from this
experiment; macOS's source code hasn't been analyzed.

## Setup

- Computer: Mac mini, Apple Silicon, macOS 27.0.1 (26A434).
- Output: QUAD USB, a USB DAC, as the default output and default system output.
- Keyboards, both over USB, stock firmware, tested one at a time:
  - HHKB Hybrid Type-S (JIS).
  - MONGDOL 87 (US ANSI, TKL), behind a Razer Thunderbolt 5 Dock.

### Devices *(measured with `ioreg -p IOUSB` and CoreAudio)*

| Device | Vendor string | VID:PID | bcdDevice | USB location | Behind |
|---|---|---|---|---|---|
| QUAD USB (DAC) | VIA Technologie | `0x2622:0x0102` | `0x0101` | `0x00131000` | Generic USB2.1 Hub `0x0BDA:0x5409` |
| HHKB-Hybrid | PFU Limited | `0x04FE:0x0022` | `0x0001` | `0x00114000` | ARTMUKOREA USB2.0 Hub `0x3447:0x2520` |
| MONGDOL 87 | RDMCTMZT | `0x36B0:0x3198` | `0x0010` | `0x00143000` | Razer Thunderbolt 5 Dock `0x1532:0x0F53` (bcdDevice `0x0052`), through its VIA Labs USB2.0 Hub `0x2109:0x2822` |

The same Generic hub as the DAC also has a Realtek "HID Device" (`0x0BDA:0x1100`) on it. Whether
that belongs to the DAC isn't known.

CoreAudio controls on the output scope, main element:

| Output | Volume (`kAudioDevicePropertyVolumeScalar`) | Mute (`kAudioDevicePropertyMute`) |
|---|---|---|
| QUAD USB | **none** | yes, settable |
| RØDE NT-USB+ (USB) | yes, settable | yes, settable |
| Mac mini Speakers | yes, settable | yes, settable |

The DAC's device UID is `AppleUSBAudioEngine:VIA Technologie:QUAD USB:131000:1`.

## Experiment

With the DAC as the output and muted, volume up and volume down were pressed on each keyboard.
Neither key unmuted the DAC, on either keyboard, so it isn't one keyboard's firmware or one hub.

The DAC exposes a mute control but no volume control, so there's no volume for the keys to change.
On outputs that do have a volume control, the same keys unmute as usual.

## Checking another output

```sh
ioreg -p IOUSB -w0 | sed 's/<class.*//'    # USB tree and locations
system_profiler SPAudioDataType            # default output
```

For the volume and mute controls, query `kAudioDevicePropertyVolumeScalar` and
`kAudioDevicePropertyMute` on the output scope with `AudioObjectHasProperty` and
`AudioObjectIsPropertySettable`. If the finding holds, an output with mute but no volume shouldn't
unmute on volume up or down either.
