# Hardware, met while debugging input methods

Two problems that first looked like input-method bugs, from FKeyIME's `docs/issues/` at
[`440d74e`](https://github.com/themrsung/fkeyime/commit/440d74e).

- [keyboard-resting-on-laptop](keyboard-resting-on-laptop/README.md): Backspace sent the message
  with a stray `3`; a Hanja pick also typed its number. **Open, hypothesis.**
- [usb-c-dock-mouse-not-enumerated](usb-c-dock-mouse-not-enumerated/README.md): a USB mouse dead
  after a reboot, behind a USB-C dock's hub.
