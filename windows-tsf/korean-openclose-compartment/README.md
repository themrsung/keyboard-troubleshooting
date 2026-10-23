# Windows closes the Korean open/close compartment when a Korean profile activates

**Status:** solved in JIS Korean's Windows shell.

Source: JIS Korean, [`docs/troubleshooting/windows-tsf-notes.md`](https://github.com/team-mirae/jis-korean/blob/72dcc4b/docs/troubleshooting/windows-tsf-notes.md).

## Symptom

The first build switched every app to ABC (passthrough) right after activating.

## Cause

Windows sets `GUID_COMPARTMENT_KEYBOARD_OPENCLOSE` to closed when a Korean profile activates, and
the shell took that change for the user pressing 한/영.

## Fix

한/영's state lives in a TSF global compartment of the shell's own (shared by every app in the
session, never stored). The open/close compartment only mirrors it for the input indicator; a
change from anywhere else is put back. 한/영, the indicator's button and the menu are the only ways
to switch.
