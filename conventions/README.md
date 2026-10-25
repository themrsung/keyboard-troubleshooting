# conventions/ — conventions

Conventions this repository follows, mainly for AI agents. Each convention has its own folder,
with one folder per revision named `REV#-YYYYMMDD`: `#` is the revision number, which grows by one
with each revision (REV1, REV2, REV3, …), and `YYYYMMDD` is the revision's date, e.g.
`REV2-20261102` after `REV1-20261025`. A revision isn't edited once a newer one exists; changes go
into a new revision, and the previous one is listed as a legacy version.

- keynames: what each key is called, by its position on the HHKB JIS layout, with its legends on
  QWERTY, Korean 2-set, JIS Korean and Japanese Kana, and its QMK keycode.
  - [REV1-20261025](keynames/REV1-20261025/KEYNAMES.md) (current): the tables, and the same data for
    code in [keynames.js](keynames/REV1-20261025/keynames.js),
    [keynames.ts](keynames/REV1-20261025/keynames.ts) and
    [Keynames.java](keynames/REV1-20261025/Keynames.java).
