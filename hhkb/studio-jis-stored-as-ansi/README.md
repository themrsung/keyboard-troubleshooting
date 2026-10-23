# A JIS HHKB stored by macOS as ANSI

**Status:** fixed by setting the type by hand.

An HHKB Studio (JIS), used over Bluetooth through Karabiner-Elements, typed fine, but the keys that
depend on macOS's keyboard type didn't work: a program reading Windows-JIS カタカナ at the HID level
(only opening keyboards stored as JIS) found nothing to open.

`/Library/Preferences/com.apple.keyboardtype` had every keyboard as 40 (ANSI), the HHKB Studio
(`21-1278-0`) included. And because Karabiner was modifying it, the keys actually reached macOS
from Karabiner's virtual keyboard (`593-1452-0`), which was ANSI too. Karabiner's own "Virtual
Keyboard: JIS" setting doesn't write that entry.

Fix: store both as JIS (42), then restart whatever reads the types:

```sh
sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype \
  -dict-add "593-1452-0" -int 42 "21-1278-0" -int 42
```

Or run Keyboard Setup Assistant (System Settings → Keyboard → Change Keyboard Type…) with the
keyboard, and choose JIS. Seen on macOS 27.0.1, Karabiner-Elements 16.3.0.
