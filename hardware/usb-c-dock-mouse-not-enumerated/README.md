# A USB mouse dead after a reboot, behind a USB-C dock

**Status:** not input-method related; hardware (2026-10-17).

Source: FKeyIME, [`docs/issues/usb-mouse-after-reboot.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/usb-mouse-after-reboot.md).

## Symptom

After a reboot the USB mouse didn't work. The laptop's touchpad and the HHKB's pointing stick over
Bluetooth did.

## What was found *(measured with `Get-PnpDevice`)*

No USB mouse was listed at all, but an "Unknown USB Device (Device Descriptor Request Failed)" on
port 4 of a VIA Labs hub (VID 2109), the USB-C dock's hub chain behind the laptop's USB controller.
The device didn't answer when Windows asked what it was. The TIP handles text input only and
touches no drivers.

## What the source lists to try

Re-plug the mouse into another dock port, unplug the dock for about 10 s, or plug the mouse
straight into the laptop. Which of these was done, and the outcome, isn't recorded.
