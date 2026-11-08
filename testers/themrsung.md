# themrsung

- GitHub: [@themrsung](https://github.com/themrsung)
- Email: themrsung@gmail.com

## Platforms

- macOS, Apple Silicon (native)
- Windows 11, x86 (native)
- Android (Samsung phone)
- Android (Samsung tablet)

## Keyboards

| Model | Layout | Firmware | Connections | Notes |
|---|---|---|---|---|
| HHKB Studio | JIS | stock | USB-C (USB 2.0), Bluetooth 5.0 LE | Pointing stick and gesture pads. macOS once stored it as ANSI ([hhkb/studio-jis-stored-as-ansi](../hhkb/studio-jis-stored-as-ansi/README.md)) |
| HHKB Hybrid Type-S (unit 1) | JIS | stock | USB-C, Bluetooth (up to 4 devices) | - |
| HHKB Hybrid Type-S (unit 2) | JIS | stock | USB-C, Bluetooth (up to 4 devices) | Received 2026-11-05. All keys healthy; works on battery power; paired over Bluetooth LE and working, as "HHKB-Hybrid_1", 0x04FE:0x0022 |
| HHKB Professional BT | HHKB US | stock | Bluetooth 3.0 | - |
| MONGDOL 87 | US ANSI, 87-key TKL | stock | USB, 2.4 GHz, Bluetooth LE | - |
| Deck Hassium (unit 1) | US ANSI, 108-key | stock | USB | **Dead key:** S (`KeyS`) never registers; every other key works (checked with [keyboard-health-check](../utils/keyboard-health-check/README.md)). Kept for testing with a broken keyboard. Reports as "Deck 108 Hassium", USB 0x0A34:0x0212 |
| Deck Hassium (unit 2) | US ANSI, 108-key | stock | USB | All keys work. Reports as "CBL108P", USB 0x0F39:0x1085 |
| SPM AL21W | Numpad | stock | USB, 2.4 GHz, Bluetooth | Numpad only. Same maker as the MONGDOL 87 |
| Hansung TFG Magnetox XF | US ANSI, 104-key | stock | USB, wired | Mod-tap unreliable ([hansung/mod-tap-rshift-bug](../hansung/mod-tap-rshift-bug/README.md)) |
| MacBook M4 keyboard | Mac US ANSI | n/a | n/a | macOS testing only |
| MacBook Neo keyboard | Mac JIS | n/a | n/a | macOS testing only |
| Samsung Galaxy Book keyboard | Korean US ANSI, with numpad | n/a | n/a | x86 testing only |
| Keychron C2 Pro | US ANSI, 104-key | stock | USB-C, wired | - |
| RealForce Compact | JIS, tenkeyless | stock | USB, wired | Topre. All keys checked with [keyboard-health-check](../utils/keyboard-health-check/README.md); remapped with Karabiner-Elements ([configfiles/realforce-compact-jis](../configfiles/realforce-compact-jis/README.md)). USB 0x0853:0x0200 |
| REALFORCE X1P JP TKL | JIS, tenkeyless | stock, A1.13 | USB | Topre. Model X1PC11. Reports as "REALFORCE X1P JP TKL", USB 0x0853:0x0322. Remap: [configfiles/realforce-x1p-jp-tkl](../configfiles/realforce-x1p-jp-tkl/README.md). Stored as JIS (42) in macOS's `com.apple.keyboardtype` |
| MONSTARGEAR pebble mini (몬스타기어 조약돌 미니) | 13u, four rows, no number row | stock (VIA protocol 12) | USB | Reports as "GUTS WECAT4", USB 0x342D:0xE47E. The left Shift, the key right of it (/ here) and Z are laid out the same as an ISO keyboard's short left Shift, extra key and Z, so the board may be used for ISO ergonomics testing. Keymap: [layouts/mini-numberless](../layouts/mini-numberless/README.md), [configfiles/monstargear-pebble-mini](../configfiles/monstargear-pebble-mini/README.md) |
| Razer Tartarus Pro | Gaming keypad, left hand | stock | USB, wired | USB 0x1532:0x0244 |
| Keychron Nape Pro | Trackball, 7 buttons and a dial | stock, v1.1.6 then v1.3.0 | USB-C | USB 0x3434:0x0440 ([keychron/nape-pro-usb-settings](../keychron/nape-pro-usb-settings/README.md)) |
