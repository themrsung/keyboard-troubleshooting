# A profile's substitute layout doesn't change which layout types

**Status:** worked around by design: the TIP types every character from its own scan-code table
(2026-10-17).

Source: FKeyIME, [`docs/issues/us-symbols-in-english-and-korean.md`](https://github.com/themrsung/fkeyime/blob/440d74e/docs/issues/us-symbols-in-english-and-korean.md),
spec §6.2, commits [`7652657`](https://github.com/themrsung/fkeyime/commit/7652657),
[`fc127e4`](https://github.com/themrsung/fkeyime/commit/fc127e4),
[`8f5d9f8`](https://github.com/themrsung/fkeyime/commit/8f5d9f8).

## Symptom

All three profiles were registered with `SubstituteLayout = 0x04110411` (Japanese) so a JIS
keyboard would type JIS symbols in English and Korean too. Measured with `ToUnicodeEx` on the
thread's layout after each switch, and by typing the keys by scan code (Shift+2, ろ, Shift+ろ, ¥,
`@`, `[`, `:`):

| Profile | Thread HKL | Result |
| --- | --- | --- |
| EN | 04090409 | `@`, –, –, –, `[`, `]`, `'` (US) |
| KO | 04120412 | `@`, –, –, –, `[`, `]`, `'` (US) |
| JA | 04110411 | `"` `\` `_` `\` `@` `[` `:` (JIS) |

So the substitute had no effect: each language kept its own layout (en-US `kbdus`, Korean
`kbd101a`).

## What was done

FKeyIME types every character from its own JIS table by scan code in all three modes. Apps that
read raw keys (games) still see Windows' layout. Later (`8f5d9f8`) the substitute layout was
removed from the registration altogether while chasing [settings-doesnt-list-tip](../settings-doesnt-list-tip/README.md);
typing wasn't re-measured after that removal.
