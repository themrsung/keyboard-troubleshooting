# Digests: what changed across the keyboard repositories

A digest summarizes the commits and other activity in the keyboard-related repositories over a
stated time window: what was found, how it was fixed, and what is still open. Digests are usually
written by AI agents from commit and activity logs. This page is the standard they follow, so
every digest is collected, checked and laid out the same way.

| Digest | Window (UTC+9) |
|---|---|
| [2026-11-02-last-36-hours](2026-11-02-last-36-hours/README.md) | 2026-10-31 22:08 → 2026-11-02 10:08 |

## Rules

A digest repeats what the sources record. It doesn't add to them. This is the repository's rule on
[untruthful software](../CONTRIBUTING.md#untruthful-software), applied to reports.

- **Don't guess hardware.** If a commit doesn't name the keyboard, computer, OS version or device
  something was measured on, write **"not recorded"**. Don't fill the gap from the tester profiles
  in [`testers/`](../testers/): they list what a tester owns, not what was used.
- **Say what kind of claim it is.** Keep the source's own status: measured, built but not
  measured, not built, planned, inferred, a hypothesis, or open. If the source says a cause was
  inferred, the digest says "inferred" too.
- **Virtual machines and simulated input are not hardware.** If a test ran in a VM, over VNC, or
  with synthetic key events, say so.
- **Every claim links to its source:** a commit (full hash in the link, a short hash is fine as
  the text), a pull request, an issue or a release. Claims with no source are left out.
- **Leave nothing out quietly.** Every repository that was looked at is listed, including those
  with no activity in the window. Anything not counted (merges, unrelated repositories) is named,
  with the reason.
- **Note when work moves.** If a fix was superseded, reverted or ported to another repository in
  the window, say so next to it.
- **Key names** follow [KEYNAMES.md](../conventions/keynames/REV1-20261025/KEYNAMES.md), as in
  the rest of the repository (see [CONTRIBUTING.md](../CONTRIBUTING.md#conventions)).
- **Plain wording.** Short sentences, no marketing language, no rating of the work.

## Collecting

1. **State the window first:** start and end, with a time zone (UTC+9 unless there's a reason
   not to), and how it was chosen, e.g. "the 36 hours before 2026-11-02 10:08".
2. **Find the repositories.** List the owners' repositories by push date (`gh repo list <owner>
   --limit 200 --json name,pushedAt`) for every owner in scope, currently
   [themrsung](https://github.com/themrsung) and [team-mirae](https://github.com/team-mirae).
   Keep the keyboard-related ones.
3. **Fetch before reading.** In each local clone, run `git fetch --all`, then
   `git log --all --since=<start> --until=<end>`, so commits on unmerged branches are included.
   Without a clone, use `gh api repos/<owner>/<repo>/commits` with `since` / `until`.
4. **Read more than the subject line.** Read the commit body, and the files it adds under `docs/`,
   troubleshooting notes and READMEs, plus the pull requests, issues and releases in the window
   (`gh pr list --state all`, `gh release list`).
5. **Note what each commit records:** platform and version, hardware, how it was measured, and
   its status (see Rules).

## Layout

One folder per digest, `digests/YYYY-MM-DD-<window>/README.md`. The date is the day the window
ends. `<window>` is a short description such as `last-36-hours` or `week-44`. The sections, in
order:

1. **Title:** `# Digest: <scope>, <start> → <end> (<time zone>)`.
2. **Opening paragraph:** the window, the sources (local clones, GitHub, which owners), and how
   they were collected.
3. **About hardware:** what the sources do and don't record about hardware, and the "not recorded"
   rule.
4. **Key names:** a legend of the keys the digest names, legend to canonical name (left out if no
   keys are named).
5. **Repositories:** a table with repository, commit count and a note (new, fork, ported,
   abandoned, …), then the repositories looked at that had no commits, and anything not counted.
6. **Troubleshooting findings:** one `###` per bug or platform behaviour, with these fields where
   they apply:
   - **Where:** repository and commit links, including ports.
   - **Symptom:** what the user saw.
   - **Evidence:** logs, commands and their output, as quoted in the source.
   - **Cause:** marked "inferred" where the source says so.
   - **Fix** (or **Solution** if it's documented as a limit rather than fixed).
   - **Still open:** what isn't solved.
   - **Platform:** OS and version, hardware, or "not recorded".
7. **Features and design changes:** one `###` per repository, bullets led by the change in bold,
   with commit links, measured results as the source gives them, and whether each was released,
   merged, or left on a branch.

Leave out a section with nothing in it, except Repositories, which is always there.

## Publishing

1. Add the digest to the table at the top of this page, and to the `digests/` section of the
   [top-level README](../README.md#digests--what-changed-across-the-keyboard-repositories) with a
   one-paragraph summary.
2. Open a pull request named `digests: YYYY-MM-DD, <short description>`.
3. A digest is a record of its window. Correct factual mistakes in it, but don't update it with
   later events; those go in the next digest.
