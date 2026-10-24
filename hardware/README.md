# Hardware, met while debugging input methods

Problems that first looked like input-method or keyboard faults. The first two are from FKeyIME's
`docs/issues/` at [`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e).

- [keyboard-resting-on-laptop](keyboard-resting-on-laptop/README.md): Backspace sent the message
  with a stray `3`; a Hanja pick also typed its number. **Open, hypothesis.**
- [usb-c-dock-mouse-not-enumerated](usb-c-dock-mouse-not-enumerated/README.md): a USB mouse dead
  after a reboot, behind a USB-C dock's hub.
- [hall-effect-keyboard-behind-usb-hub](hall-effect-keyboard-behind-usb-hub/README.md): a
  Magnetox XF stopped working behind a powered USB hub; another cable and port fixed it.
- [volume-keys-unmute-only-when-volume-changes](volume-keys-unmute-only-when-volume-changes/README.md):
  macOS's volume keys didn't unmute a USB DAC with no volume control (QUAD USB); the unmute seems
  to come only with a volume change. **Finding.**
