# A VIA definition for the TFG Magnetox XF

Hansung's keyboards speak VIA's protocol ([web-driver-internals](../web-driver-internals/README.md)),
but VIA doesn't list them. [tfg-magnetox-xf.json](tfg-magnetox-xf.json) is a VIA v3 definition for
the **TFG Magnetox XF** (USB 0x0416:0x8144): 104 keys, a 7 × 16 matrix and the lighting menu.

It's converted from Hansung's own definition, `app.superstore.co.kr/definitions/b/68583748.json`,
with [convert-definition.py](convert-definition.py), which works for the other Hansung models too:

```sh
curl -O https://app.superstore.co.kr/definitions/b/68583748.json
python3 -I convert-definition.py 68583748.json tfg-magnetox-xf.json
```

Checked: every key's position round-trips exactly, and reading the keyboard's keymap over raw HID
put each keycode where the layout draws it (Esc at 0,0, the letters, the numpad).

## Using it

1. [usevia.app](https://usevia.app) in Chrome or Edge (it needs WebHID).
2. Settings → turn on **Show Design tab**.
3. Design → **Load Draft Definition** → `tfg-magnetox-xf.json`.
4. Configure → **Authorize device**.

Loading a definition writes nothing to the keyboard, and keymap edits use the same commands as
Hansung's driver, so both keep working. Hansung's magnetic-switch settings (actuation, Rapid
Trigger, DKS, calibration) and firmware updates stay in Hansung's driver.

Things to know:
- VIA's Any key didn't accept `LT(x,y)` for this keyboard: [any-key-rejects-layer-tap](../../via/any-key-rejects-layer-tap/README.md).
- Mod-tap keycodes are stored, but the firmware gets them wrong: [mod-tap-rshift-bug](../mod-tap-rshift-bug/README.md).
- The layout data is Hansung's: the positions and matrix of their keyboard.
