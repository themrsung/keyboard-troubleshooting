# Hardware, met while debugging input methods

Problems that first looked like input-method or keyboard faults. The first two are from FKeyIME's
`docs/issues/` at [`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e).

- [keyboard-resting-on-laptop](keyboard-resting-on-laptop/README.md): Backspace sent the message
  with a stray `3`; a Hanja pick also typed its number. **Open, hypothesis.**
- [usb-c-dock-mouse-not-enumerated](usb-c-dock-mouse-not-enumerated/README.md): a USB mouse dead
  after a reboot, behind a USB-C dock's hub.
- [hall-effect-keyboard-behind-usb-hub](hall-effect-keyboard-behind-usb-hub/README.md): a
  Magnetox XF stopped working behind a powered USB hub; another cable and port fixed it.
- [dac-without-volume-stays-muted](dac-without-volume-stays-muted/README.md): volume up or down
  doesn't unmute a USB DAC that has no volume control (QUAD USB). **Open.**
