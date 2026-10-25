# With Apple's ABC enabled, 英数 goes to ABC

**Status:** open in the input method; worked around by replacing ABC with ABC – Extended.
Tracked as [team-mirae/jis-korean#2](https://github.com/team-mirae/jis-korean/issues/2).

Source: JIS Korean, commit [`0a466c2`](https://github.com/team-mirae/jis-korean/commit/0a466c2),
[`docs/troubleshooting/macos-katakana-and-eisu.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/macos-katakana-and-eisu.md),
spec §8.2.1. macOS 27.0.1.

## Symptom

JIS Korean declares its English mode (`me.sjun.inputmethod.JISKorean.A_QWERTY`) with the Roman
script, so 英数 (`KeyJISMacEnglish`) should select it, as it selects a Japanese input method's own
Romaji mode. With
Apple's **ABC** enabled, 英数 selected ABC instead, although JIS Korean's key tap saw the key
(`tap: key code 102 down`). This settled the spec's open question: with ABC present, macOS picks ABC.

## Workaround (measured)

In System Settings → Keyboard → Input Sources → Edit…, add English → **ABC – Extended** first,
then remove ABC. 英数 then goes to JIS English, and ABC – Extended still types in password fields.

## Why ABC can't simply be removed

macOS keeps at least one plain keyboard layout enabled, for secure input (password fields bypass
input methods), and an input method's modes don't count as one. So ABC can only go once another
plain layout is there.
