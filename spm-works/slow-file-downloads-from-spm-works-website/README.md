# Slow file downloads from SPM Works' website

**Status:** known; outside our control (2026-10-24).

## Symptom

Files from SPM Works' website download slowly.

## Cause

The downloads are served through a Synology QuickConnect sharing service. *Inferred:* the files
probably come straight from a Synology NAS, with no CDN in front, so delivery is limited by that
NAS and its connection.

## What to do

- **Expect slow delivery.** Give a download time, and use a generous timeout.
- **Agents: don't spam the server.** Try once, for example
  `curl -fL --retry 2 --max-time 600 -o <file> '<link>'`. Don't run parallel downloads or retry in
  a loop: on a single NAS, that only makes it slower for everyone.
- **If `curl` fails, give the download link to a human** to open in a browser, and carry on once
  the file is there.
