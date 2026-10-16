# Phase 7: verify end to end

Use `verification-report.md`. Verification is a reconciliation against expected work, not a green exit code.

| Evidence | Proves | Does not prove |
|---|---|---|
| Every expected path + count + size | Presence and length for the selected set | Byte equality or coverage of excluded data |
| SHA-256 sample | Equality for the named sample | Equality of unsampled files |
| SHA-256 all expected files | Byte equality for that set at check time | Application readiness or future durability |
| Archive CRC test | Internal archive integrity | Correct source selection or a working restore |
| Cloud one-way size check | Expected remote paths and sizes | Full cryptographic identity or absence of extras |
| Owner confirmation | An owner-reported action | An independently observed test |
| Current read-only flag | OS reports the mapped disk read-only now | Hardware health or persistence after reconnect |

1. Compare inventory and triage against every manifest row and special-item disposition. Include retained-original and deferred items in the denominator.
2. Confirm all selected expected files, counts, bytes, hash scope and extra target files. Preserve detailed hash evidence privately when required.
3. Recheck the frozen sources after copy and after reconnect. Stop if identity or read-only status changed.
4. Compare repository refs, stashes, dirty/untracked state, linked worktrees and integrity. Explain deliberate copied-link changes separately from original file hashes.
5. Check app data, service versions, mounts and owner-selected records. A healthy port is not proof that the correct database loaded.
6. Test tool resolution in a fresh shell and agent rules in a fresh nested project session. Verify author and outgoing account separately.
7. Ask the owner to open representative documents, media, repos, browser/app profiles and recovered workflows. Record exact items and results.
8. Test a restore from an independent backup. For encrypted material, the owner performs the test without showing contents or keys.

An empty source row is valid only if independently confirmed and expected. A denied directory, skipped test or absent dependency remains an exception. Do not create a blanket done marker to conceal it.

"Done" means every item has a documented disposition; critical verification passes; exceptions have owner acceptance and named follow-ups; consumers use the intended copies; recovery is preserved. If a cloud backup is deliberately deferred, say "local migration accepted; off-device backup pending" rather than "fully backed up."

Gate: the owner approves switchover from the report. Repeat affected checks after phase 8, because agent configuration and path adapters can change behavior.
