# macOS loses the Windows JIS カタカナ key

**Status:** works, through a HID listener plus a key tap, with the keyboard stored as JIS
(2026-10-22). Reached in seven commits; each fixed a problem the previous one showed.

Source: JIS Korean, commits [`9a50937`](https://github.com/team-mirae/jis-korean/commit/9a50937),
[`a37d5ff`](https://github.com/team-mirae/jis-korean/commit/a37d5ff),
[`ac9a0b7`](https://github.com/team-mirae/jis-korean/commit/ac9a0b7),
[`f01b227`](https://github.com/team-mirae/jis-korean/commit/f01b227),
[`c1b97d3`](https://github.com/team-mirae/jis-korean/commit/c1b97d3),
[`1e79c7c`](https://github.com/team-mirae/jis-korean/commit/1e79c7c),
[`bdfb463`](https://github.com/team-mirae/jis-korean/commit/bdfb463),
[`0a466c2`](https://github.com/team-mirae/jis-korean/commit/0a466c2),
[`0357ffa`](https://github.com/team-mirae/jis-korean/commit/0357ffa);
[`docs/troubleshooting/macos-katakana-and-eisu.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-katakana-and-eisu.md);
spec §8.2.1. macOS 27.0.1, HHKB Studio JIS over Bluetooth, HHKB Hybrid Type-S JIS,
Karabiner-Elements 16.3.0.

## The goal

The カタカナ/ひらがな key (`KeyJISKLangKorean`) of Windows JIS keyboards (right of Space, where
Korean keyboards have 한/영, `KeyKTSHangulToggle`) as a key that always goes to Korean, from any app
and any input source.

## Steps and what each one ran into

| Commit | Change | What it ran into |
| --- | --- | --- |
| `9a50937` | Read the keyboard at the HID level (`IOHIDManager`, Input Monitoring) to know whether usage 0x88 (カタカナ) is held, and swallow a かな (`KeyJISMacKana`) event (key code 104) in a system-wide key tap (Accessibility) while it is. Plan based on macOS turning カタカナ into かな. | — |
| `a37d5ff` | The listener gave up when Input Monitoring wasn't granted yet. Now it retries every 3 s without a restart. | — |
| `ac9a0b7` | Logs both permission states while waiting; asks for the permissions only the first time (a menu item asks again). | Grants lost on every build: see [permissions-lost-on-rebuild](../permissions-lost-on-rebuild/README.md) |
| `f01b227` | Opening failed as a whole when another program held some keyboards (Karabiner-Elements seizes the ones it remaps), though the others had opened. Now only "not permitted" means waiting. | — |
| `c1b97d3` | Open only keyboards macOS stores as JIS, read from `/Library/Preferences/com.apple.keyboardtype` (`product-vendor-country`; 40 ANSI, 41 ISO, 42 JIS). | Every keyboard on the test Mac was stored as 40, so nothing opened (below) |
| `1e79c7c` | The log showed **no event at all** reaching the tap for the HHKB's カタカナ: macOS discarded the key rather than turning it into かな. The HID listener now switches to Korean on the press itself; the tap only swallows a かな made of it where one arrives. The Japanese usages 0x87–0x94 are logged. | — |
| `bdfb463` | While カタカナ was held, a real かな press was swallowed too. The listener also tracks the real かな key (usage 0x90, LANG1); with both down, かな is the real one. | — |

The other Windows-only keys are lost the same way: 変換 (`KeyJISHenkan`) and 無変換
(`KeyJISMuhenkan`) arrive as 英数 (`KeyJISMacEnglish`) (spec §8.2.1).

## The keyboard stored as ANSI (`0a466c2`)

Symptom: カタカナ selected Japanese or did nothing, F18 (`KeyFunctionEighteen`) worked; the log had
only the tap's line
(`tap: key code 104 down, カタカナ held false`) and, at launch, `hardware keys: no keyboard is
configured as JIS`.

Cause *(measured)*: `com.apple.keyboardtype` had every keyboard as 40, the HHKB Studio (`21-1278-0`)
included, although it typed JIS correctly through Karabiner. With Karabiner remapping a keyboard,
Karabiner holds it and its keys come out of Karabiner's virtual keyboard (vendor 1452, product 593,
entry `593-1452-0`), which was 40 too. Karabiner's "Virtual Keyboard: JIS" setting doesn't write
that entry.

Fix: store both as 42 (`sudo defaults write /Library/Preferences/com.apple.keyboardtype keyboardtype
-dict-add "593-1452-0" -int 42 "21-1278-0" -int 42`, or Keyboard Setup Assistant), then
`pkill -x JISKorean`. After the relaunch the log said `hardware keys: on for 2 JIS keyboard(s),
some held by another program` and a press gave `hardware key 0x88 down`. Restarting Karabiner
wasn't needed. Also in [hhkb/studio-jis-stored-as-ansi](../../hhkb/studio-jis-stored-as-ansi/README.md).

## With Karabiner-Elements (`0357ffa`)

カタカナ works with Karabiner on or off for the keyboard, as long as the virtual keyboard is stored
as JIS and no Karabiner rule remaps `japanese_pc_katakana`. Tested with an HHKB Hybrid Type-S JIS
and an HHKB Studio.

## Commands the source used

```sh
defaults write me.sjun.inputmethod.JISKorean DiagnosticLog -bool true
tail -f ~/Library/Logs/JISKorean.log
defaults read /Library/Preferences/com.apple.keyboardtype
karabiner_cli --list-connected-devices   # /Library/Application Support/org.pqrs/Karabiner-Elements/bin
```
