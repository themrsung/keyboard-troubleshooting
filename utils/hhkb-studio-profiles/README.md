# hhkb-studio-profiles

Split an HHKB Studio Keymap Tool settings file (`.hks`) into its four profiles, or merge profiles
into one file. Profiles you don't fill get **PFU's factory keymap** for that slot, not anyone's
custom one.

For HHKB Studio Keymap Tool **1.1.2** (setting file 1.1.0.0), from
[PFU's download page](https://happyhackingkb.com/download/), and the files it saves; the script
refuses other versions. Tested on the HHKB Studio JIS only; **untested on the HHKB Studio US**. Needs [jq](https://jqlang.org) (`brew install jq`).

```sh
utils/hhkb-studio-profiles/hhkb-studio-profiles.sh split  IN.hks [OUTDIR]
utils/hhkb-studio-profiles/hhkb-studio-profiles.sh split  --single IN.hks [OUTDIR]
utils/hhkb-studio-profiles/hhkb-studio-profiles.sh merge  OUT.hks [P1 [P2 [P3 [P4]]]]
utils/hhkb-studio-profiles/hhkb-studio-profiles.sh check  FILE...
```

## The two kinds of file

The tool's **File → Save the Settings** saves either:

- **All Profiles** (`"SaveType": "All"`): `Profile1` … `Profile4`. Opening one replaces all four
  profiles.
- **Current Profile** (`"SaveType": "Single"`): one profile, under `Profile`. Opening one loads it
  into the profile picked in the drop-down above the keymap preview (the tool's Help, "Overwriting
  the Keymap for the Keyboard with a Keymap in a Config File").

Both also carry the DIP switches, the pointing-stick buttons and the gesture pads, which apply to
the whole keyboard, and the model (`TypeNumber`). DIP switches are physical, so the tool records
them but doesn't set them.

## Operations

### split

```sh
hhkb-studio-profiles.sh split layouts/hhkb-jis-golden/hhkb-studio-golden.hks /tmp/golden
```

Writes `IN-Profile1.hks` … `IN-Profile4.hks`, one per profile of an All Profiles file. Each is an
**All Profiles** file with that profile in its own slot and PFU's factory keymap in the other three,
so opening it gives you that one profile in place and a stock keyboard otherwise.

With `--single`, each is a **Current Profile** file instead, to open into whichever profile you
pick in the tool.

### merge

```sh
hhkb-studio-profiles.sh merge mine.hks configfiles/hhkb-studio-jis/hhkb-studio-jis.hks
hhkb-studio-profiles.sh merge mine.hks - - work.hks old-all.hks@4
hhkb-studio-profiles.sh merge factory.hks
```

Writes one All Profiles file, the sources in slot order (Profile1 first). A source is:

| Source | Means |
|---|---|
| `FILE` | a Current Profile file |
| `FILE@N` | profile `N` (1–4) of an All Profiles file |
| `-` | PFU's factory keymap for that slot |

Slots left off the end are `-`, so `merge OUT.hks` alone writes the factory keymap in all four
profiles. The settings outside the keymap (DIP switches, pointing-stick buttons, gesture pads) come
from the first source that isn't `-`; with none, they're the factory settings, DIP switches all off.
All sources must be the same model.

### check

Prints each file's type, model, tool version and profiles, and fails on a file the script can't
read.

## The factory keymaps

[defaults/factory.hks](defaults/factory.hks) is an All Profiles export of the owner's **HHKB
Studio JIS** (`PD-ID120B`) right after a factory reset (2026-10-26, Keymap Tool 1.1.2). An unfilled
slot gets that slot's profile from it.

As [PFU's manual](https://happyhackingkb.com/manual/studio/ug-us/en/ug/topic/profile.html) says,
Profile1 is for Windows, Profile2 for macOS, and Profiles 3 and 4 are the same as Profile1. In the
file, Profile2 differs from Profile1 only in the bottom row: Mac's 英数 / かな
(`KeyJISMacEnglish` / `KeyJISMacKana`) and ⌘ where Windows has 無変換 / 変換
(`KeyJISMuhenkan` / `KeyJISHenkan`) and カタカナ, plus two codes not yet identified at positions
108 and 109 of every layer (24460 / 24461 on Windows, 24462 / 24463 on Mac). A Profile1 restored on its own (**Edit →
Restore the Layout to the Factory Default Layout → Current Profile**) is the same, key for key.

Factory settings outside the keymap: pointing-stick buttons **off**, all four gesture pads **on**.
The file records DIP switch 6 on, but that's the owner's physical switch; `merge` with no sources
writes all six off, as shipped.

Other models (the US Studio) aren't covered: `split` and `-` refuse them; `split --single`, and
`merge` with all four slots given, still work.

## Checked

On 2026-10-26, with jq 1.7.1 on macOS 27.0.1:

- Splitting [the golden layout's file](../../layouts/hhkb-jis-golden/hhkb-studio-golden.hks) both
  ways and merging the pieces back gives the same file, key for key.
- A split file has its own profile in its slot and the factory file's in the other three.
- `merge OUT.hks` alone gives the factory file, DIP switches off.

The files the script writes haven't been opened in the Keymap Tool yet.
