# Contributing

Anything related to keyboards is fine, as long as it does not promote, or directly provide the
resources required to build, untruthful software.

## Untruthful software

For the purposes of these guidelines, untruthful software is any software which:

- Does something it did not explicitly inform the user about, for example injecting a keystroke or
  input intentionally.
- Does not do something it explicitly informed the user it has done, for example dropping a
  keystroke or input intentionally.
- Does something, but not in accordance with what the user intended. For example, an auto-correct
  program correcting "appels and oranges" to "apples and oranges" is fine, but correcting it to
  "red and orange" is untruthful.
- Offers prediction, generation, or other non-deterministic or machine-learning-powered features
  without the user's explicit consent.

If such resources are found, they may be removed from the repository without further notice.

## Conventions

Follow the conventions in [`conventions/`](conventions/README.md), using their current revision.
Revisions are folders named `REV#-YYYYMMDD`, where `#` grows by one with each revision and
`YYYYMMDD` is its date.

- **Key names.** Name keys as in
  [KEYNAMES.md](conventions/keynames/REV1-20261025/KEYNAMES.md). Keep the legends readers see on the
  keycaps and add the canonical name beside them, e.g. "カタカナ (`KeyJISKLangKorean`)", or give key
  tables a canonical-name column. Where many names repeat, a short "Key names" legend at the top of
  the file, or in the folder's README, can map the names used there to canonical ones instead.
- **Don't rename what other tools read.** QMK keycodes, VIA and Karabiner files, browser
  `KeyboardEvent.code` values, Windows VK and scan codes, and quoted logs or UI text stay as they
  are; add the canonical name next to them.
- **A key with no name yet** gets one in KEYNAMES.md first, following its naming rules, in the same
  pull request.

## Your tester profile

Before submitting a pull request, make sure your profile is in the [`testers/`](testers/) directory
as a `username.md` file (see [`testers/themrsung.md`](testers/themrsung.md)).

You may redact information, but please don't anonymize it. For example, write "[redacted]" or
"[hidden for privacy]" rather than "tester@testing.com" or "email1@qwer.com", so this repository
remains truthful.

You may also anonymize your list of hardware, but at least the following must be disclosed:

- **The platform you tested on, and its version.** For example, "Windows 11, x64" or "macOS 27,
  Apple Silicon" is enough. Important: if you used a virtual machine, say so, for example
  "Ubuntu xx (virtual machine)".
- **The hardware you tested on, its firmware, and how it was connected.** For example, "HHKB Hybrid
  Type-S, stock firmware, over USB" is enough.

More information is always welcome, but you don't have to share it if you don't want to.
