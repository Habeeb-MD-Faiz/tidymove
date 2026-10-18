# Using tidymove

Start with the [README](../README.md). This guide is for the person or agent preparing the actual commands. You can begin planning without running any of them.

## Install

Works with the agent you already use. You need it installed with local file access. Installing tidymove does not start copying files.

### Claude Code

Paste each line into the Claude Code conversation:

```text
/plugin marketplace add Habeeb-MD-Faiz/tidymove
/plugin install tidymove@tidymove
```

Review the installation prompt, then restart Claude Code or reload its plugins. Ask it to help you plan a move with tidymove.

### Codex

Paste this into the Codex conversation, not a terminal, then restart Codex:

```text
$skill-installer install https://github.com/Habeeb-MD-Faiz/tidymove/tree/main/skills/tidymove
```

### Cursor

Clone the repo in a terminal, then open the cloned folder in Cursor:

```shell
git clone https://github.com/Habeeb-MD-Faiz/tidymove
```

Ask in the Cursor conversation:

```text
Read AGENTS.md and help me plan a move.
```

### Gemini CLI

Install the skill from your terminal and review the confirmation prompt:

```shell
gemini skills install https://github.com/Habeeb-MD-Faiz/tidymove.git --path skills/tidymove
```

### Any other agent

Clone the repo in a terminal, then open your agent in the cloned folder:

```shell
git clone https://github.com/Habeeb-MD-Faiz/tidymove
```

Ask in the agent conversation:

```text
Read AGENTS.md and help me plan a move.
```

The agent must be able to read local files and follow the linked skill. Automatic discovery and permissions vary by tool.

### Install sources

Documentation checked on 2026-10-18. These routes match the README. The local manifests confirm the plugin and marketplace names; the complete skill lives in `skills/tidymove/`.

| Agent | Source and scope |
|---|---|
| Claude Code | [Install and manage plugins](https://code.claude.com/docs/en/discover-plugins#add-a-marketplace) documents GitHub `owner/repo` marketplaces and `plugin@marketplace` installation. |
| Codex | [Install skills for local use](https://learn.chatgpt.com/docs/build-skills#install-curated-skills-for-local-use) documents asking `$skill-installer` to download skills from other repositories. This is a conversation prompt, not a shell command. The bundled installer also supports GitHub tree URLs. |
| Cursor | [Rules and AGENTS.md](https://cursor.com/docs/rules#agentsmd) documents instructions in the project root. The clone-and-read route uses this repository’s `AGENTS.md`, which directs the agent to the skill. |
| Gemini CLI | [Agent Skills](https://geminicli.com/docs/cli/skills/#managing-skills) documents Git repository installation and `--path` for a skill subdirectory. |
| Any other agent | [AGENTS.md](../AGENTS.md) links to [the skill](../skills/tidymove/SKILL.md). This is an explicit read request, not a claim of native installation or automatic discovery. |

No live agent installation was performed for this documentation update. When using the plain skill, keep the entire `skills/tidymove/` folder together, including `references/`, `templates/` and `scripts/`.

## Before you start

You need an AI tool with local file access, permission to use it with the selected data, enough storage for new copies, and time to answer questions. The kit does not install an AI tool or provide an AI account.

For the tested Windows path, use **Windows PowerShell 5.1**, Windows' built-in **robocopy**, and the Windows Storage commands used by `verify-frozen.ps1`. An access-denied result stops the check; it does not authorize running everything as administrator. The smoke test also uses Git to create a made-up repository.

The agent should prepare a source-protection plan for your exact disks. You approve and run any necessary elevated step separately. The kit does not freeze a drive automatically. If a drive is failing or cannot be identified reliably, stop and seek recovery help before repeated scans.

For macOS/Linux, read the [experimental recipes](../skills/tidymove/references/recipes-macos-linux.md). Those scripts require Bash, Python 3.9+, and rsync 3.x; they are not covered by the Windows smoke test.

## Words you will see

| Term | Plain meaning |
|---|---|
| Source / target | Where files are now / where new copies will go. |
| Inventory | A list of what is there, plus anything that could not be listed. |
| Freeze / read-only | Prevent writes to the old storage, then check that protection is active. |
| Triage | Ask what to do with items whose purpose is unclear. |
| Reconcile | Compare different copies and decide which to use, keeping alternatives. |
| Manifest | The exact copy list, saved as a CSV table. |
| Dry run | A preview. No destination data is copied, but private evidence files are written. |
| Hash / SHA-256 | A fingerprint calculated from file contents to compare copies. |
| Gate | A required check or approval before the next step. |
| Activation / switchover | Start using the new copies in your apps. |
| Opaque | Leave contents unread; the owner handles them privately. |
| Scope | A group with its own rules, such as personal or work files. |
| ACL / permissions | Rules about which users can read or change a file. |
| Rollback | How to return to a retained, checked copy if something fails. |

## Keep your run private

A **run** is one migration and its record. Ask the agent to choose a private folder with you and create `docs/STATE.md` there from the [template](../skills/tidymove/templates/STATE.md). Keep inventories, decisions, copy lists, and logs in that folder. They contain filenames and personal paths even when no file contents are shown.

Keep the run outside source and destination data folders and outside an installed plugin cache. The repository ignores `runs/` for local experiments, but ignoring files is not encryption or an access control. A separate private location is better for real migrations. Never upload a run as an issue attachment.

CSV templates contain explanation lines beginning with `#`. Remove those lines in your private working copy before opening it as a normal CSV. Generated inventory and verification files are ready to import. When viewing untrusted filenames in a spreadsheet, import columns as **text**; names starting with formula characters must not execute as formulas.

## Preview a Windows copy

These are examples for your agent to fill in after intake and review. Replace every angle-bracket placeholder with an approved absolute Windows path. Use a new private log folder for each attempt.

```powershell
$kit = '<ABSOLUTE-PATH-TO-TIDYMOVE>'
$source = '<SOURCE-FOLDER>'
$run = '<PRIVATE-RUN-FOLDER>'
& "$kit\skills\tidymove\scripts\verify-frozen.ps1" -Root $source
& "$kit\skills\tidymove\scripts\inventory.ps1" -Root $source -OutputCsv "$run\inventory.csv"
& "$kit\skills\tidymove\scripts\copy-verify.ps1" -Manifest "$run\manifest.csv" -OutputDir "$run\dry-01"
```

Check **each command's exit code immediately**. Zero means that command completed its stated check, not that your whole migration is safe. A scan can complete while reporting excluded items. `-AllowLiveScan` allows a metadata inventory of current-machine files; it never authorizes copying a live source.

Your agent prepares `manifest.csv` using exactly these columns:

```csv
source,target,mode
<SOURCE-FOLDER>,<NEW-TARGET-FOLDER>,folder
```

Use a CSV writer when filling real paths, so commas and quotation marks survive. `folder` means a whole selected folder. `file` means one file, with the exact destination filename at the end of the target path. That name may differ from the original. For example, two sources named `notes.txt` can become `notes-home.txt` and `notes-project.txt` in one destination folder. Preview both rows first. The script keeps the originals and never overwrites an existing file. An existing destination must match the source by SHA-256. The [migration plan template](../skills/tidymove/templates/migration-plan.md) explains how to record special cases separately.

## Copy after approval

After reviewing the plan, preview, available space, and source protection:

```powershell
& "$kit\skills\tidymove\scripts\copy-verify.ps1" -Manifest "$run\manifest.csv" -OutputDir "$run\copy-01" -Execute
```

The script checks every selected path and size, and by default every file’s SHA-256. A fresh log folder preserves earlier attempts. Read `verification.csv` and the numbered row logs. Each file row always receives a SHA-256 check, including when its destination name changes. Folder rows use robocopy on Windows or rsync on macOS/Linux. File rows use a direct copy that refuses to replace an existing file.

A refusal before copying writes `preflight.csv` in the new output directory, with `row,source,target,mode,stage,status,reason,exit_code`. Each parsed row records `REFUSED`, the batch refusal reason and exit code 1. Row 0 represents an empty manifest. No destination data is created. If the output path is unsafe, already exists, cannot be written, or cannot be proved separate from the manifest’s data paths, the script prints `REPORT NOT WRITTEN` and retains the console refusal instead. It cannot safely promise a report at an arbitrary path. Keep that console output and correct the path before retrying.

| Result | Meaning |
|---|---|
| `DRY-RUN` | Preview completed; no claim that the files were copied. |
| `VERIFIED-ALL` | All selected file contents matched at check time. |
| `VERIFIED-SAMPLE` | All expected paths/sizes checked; only the declared subset of contents checked. |
| `REFUSED` | Preflight stopped the whole batch before copying; read `preflight.csv`. |
| `FAILED` or `STOP` | Keep everything and investigate. Do not proceed to activation. |

`-Verify Sample -SampleSize 20` hashes the first 20 sorted file paths plus every pre-existing mapped destination file. This is **not a random sample** and cannot prove equality of unsampled files. Use full verification unless you explicitly accept that limit.

If a conflicting or partial file is found, leave it in place and use a fresh target after review. Do not delete it or disable the check. Never run two copy jobs against overlapping targets, even with different manifest files. The lock only serializes users of the same manifest; it does not stop other apps or malicious code from changing paths.

Once checks pass, open representative files yourself. After you approve using the new copies, the agent places `.tidymove-active` in each folder target, or beside each file target. This tells later copy runs to stop there. Never remove it to bypass a refusal.

## What needs a separate plan

The ordinary copier rejects links, recognized cloud placeholders, and secret-looking names. That includes `.env.example`, `passwords-old.txt`, password and credential names, tokens, private keys, wallets, recovery codes and key files ending in `.sample`. These checks use names only. Filename filters cannot detect every secret. Review harmless examples separately without weakening the detector.

Cloud-only files need owner-controlled recovery into new storage. Passwords and keys stay owner-handled. App databases need a consistent export. File fingerprints cover ordinary file contents, not every filesystem feature: security permissions, alternate data streams, sparse storage, resource forks, extended attributes, and case-sensitive names need explicit checks or another reviewed method.

Inventory identifies Git repository markers but does not run Git or read contents. Status, unpublished work, and repository integrity need a separate approved review. Git can read repository-controlled configuration and file contents; review those boundaries before invoking it on old data. Never open auth configuration to determine an account.

## Check the scripts

From the kit's root folder:

```powershell
powershell.exe -NoProfile -File .\tests\smoke.ps1
```

The test creates made-up files under a new `runs/smoke-...` folder and keeps them all. To keep that folder untouched, choose a **new, nonexistent** directory elsewhere:

```powershell
powershell.exe -NoProfile -File .\tests\smoke.ps1 -WorkDir '<NEW-TEST-FOLDER>'
```

The final result should say `SMOKE PASS` and state the skipped count. Deliberately rejected cases print a refusal followed by a passing assertion. The Windows freeze checker returns 0 for proved frozen, 1 for proved writable, and 2 for inconclusive, with a reason. A denied or unknown real disk query is `SKIPPED`, never a passing writable disk assertion. A proved frozen fixture disk fails that assertion. Any failed assertion ends with `SMOKE FAIL` and exit code 1; otherwise the suite returns 0 and reports skips separately. The suite checks synthetic file handling and simulated disk flags; it does not certify real disk protection, data recovery, or other operating systems.

Inventory and copy safety checks inspect the supplied paths and every parent through the drive or filesystem root, even in fixture mode. On Windows they query existence and attributes to reject reparse points and offline or cloud locations, and compare each path component against secret name patterns. On macOS/Linux they inspect symlink metadata and path names. Copy also checks for `.tidymove-active` at the destination and its parents. Ancestor validation does not open file contents. Copy separately reads the manifest at its supplied path and the fixture marker inside `FixtureRoot`. That option does not confine manifest or output paths. These ancestor checks prevent a link above the root from redirecting a scan or copy.

When the caller requires a strict subtree, use `-StrictSubtree` on Windows inventory or copy, or `--strict-subtree` on their shell equivalents. The request is refused before supplied paths, the manifest or the marker are inspected, and before output is created. This option reports an incompatible boundary; it does not enable a bounded scan. Do not run these scripts under a strict subtree requirement without it. Fixture mode permits synthetic data on writable storage but is not a read sandbox.

## If you get stuck

Keep the original, logs, and partial target. Ask the agent to state what is verified, what is a guess, and what needs checking. A denied read is not an empty folder. A successful copy is not a tested backup.

For a public bug report, reproduce the issue with made-up filenames and data. Follow [SECURITY.md](../SECURITY.md) if the problem could expose information or harm files.
