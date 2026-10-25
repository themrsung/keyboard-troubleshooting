# Hansung's web driver: VIA's protocol underneath

Hansung's keyboards (TFG Magnetox, GK… PRO V2, Archon, F1 PRO, FX ULTRA, CloudMax) are set up in
its web driver, [app.superstore.co.kr](https://app.superstore.co.kr) ("HANSUNG Web Driver"). It's
Hansung's own React app, but it talks to the keyboard with **VIA's raw-HID protocol**, so VIA and
other VIA tools can read and write the keymap too.

Read from the driver's JavaScript bundle (`/assets/index-a26e811e.js`, October 2026) and checked
against a TFG Magnetox XF on firmware 5.9.2 where noted. Not from Hansung's documentation.

## Transport

- WebHID, on the interface VIA uses: usage page **0xFF60**, usage 0x61 (also 0xFF68/0x61 and
  0xFF01/0x10 for other device families). 32-byte reports, report ID 0. Checked on the XF.
- VIA's command numbers: `GET_PROTOCOL_VERSION` 0x01, `DYNAMIC_KEYMAP_GET/SET_KEYCODE` 0x04/0x05,
  custom menus 0x07–0x09, macros 0x0C–0x10, `GET_LAYER_COUNT` 0x11, `GET/SET_BUFFER` 0x12/0x13.
  The XF answers protocol version **12**, 4 layers. Checked.
- Hansung's own commands on top, 0x20–0x43: Rapid Trigger and DKS reload, calibration, LT tapping
  term (0x36), Fn control, polling, gamepad, Win lock, LED settings, profiles, and more.
- **Firmware version:** Hansung's command **0xF0** (`GET_VER`) answers major, minor, patch
  (`F0 05 09 02` = 5.9.2). VIA's own firmware-version value (0x02 with id 0x04) is left at 0.
  Checked. Firmware updates use 0xF1–0xF6 (erase, write, read ROM).
- The firmware stores data in regions named LDROM/APROM, Nuvoton's terms, and the USB vendor ID is
  0x0416 (Nuvoton's). So it's likely Nuvoton vendor firmware implementing VIA's protocol, not QMK.
  That's an inference.

## Keycodes

The driver has its own QMK keycode tables, chosen by the protocol version:

| Table | Mod-tap | Layer-tap | Momentary |
|---|---|---|---|
| `default`, `v10` | 0x6000 | 0x4000 | 0x5100 |
| `v11`, `v12` | 0x2000 | 0x4000 | 0x5220 |

So for protocol 12 it's QMK's current numbering, which the XF's stored keymap confirms (`MO(1)`,
`KeyMomentaryLayerOne`, is 0x5221). Modifier bits are QMK's (`MOD_LCTL` 1, `MOD_LSFT` 2,
`MOD_LALT` 4, `MOD_LGUI` 8, right-hand +16). The firmware doesn't act on mod-tap the way QMK does: see
[mod-tap-rshift-bug](../mod-tap-rshift-bug/README.md).

## What the driver's own UI offers

- **Layer-tap and layer-modifier** (`LT`, `LM`) buttons in the Layers tab, shown from firmware 4.4,
  with a configurable tapping term (200 ms by default). An **Any** key (modifier + key) from 4.25.
- **ModTap/TGL** advanced keys on magnetic boards: up to 5 keys, 10–1000 ms. Hold and tap are each
  one HID usage from a fixed 104-key ANSI list (modifiers, F1–F12; no layers, 한영/한자 or
  International keys).
- The key picker has 한영 (`KC_LNG1`, `KeyKTSHangulToggle`), 한자 (`KC_LNG2`, `KeyKTSHanja`) and
  F13–F24, but not `KC_INT1`–`KC_INT3` (ろ, カタカナ, ¥: `KeyRo`, `KeyJISKLangKorean`,
  `KeyLongKatakana`), 変換 or 無変換 (`KeyJISHenkan`, `KeyJISMuhenkan`). The firmware sends those
  fine when written another way (VIA, or [raw HID](../../via/raw-hid-keymap-editing/README.md)).
- Feature tiers by firmware version, e.g. SmartTap allows 2 keys, 4 from 3.7.1, and 5 from 5.9.2.

## Definitions

Each keyboard's layout is a VIA definition, compiled and with short field names, at
`https://app.superstore.co.kr/definitions/b/<vendor << 16 | product>.json` (index at
`/definitions/index.json`). [via-definition-magnetox-xf](../via-definition-magnetox-xf/README.md)
converts one back to a normal VIA v3 definition. Firmware files and version info come from
`www.sparq.co.kr`. The page links monsterlabs.co.kr, possibly its developer.
