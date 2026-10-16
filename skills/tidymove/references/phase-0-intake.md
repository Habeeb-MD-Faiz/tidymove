# Phase 0: understand the owner

Use `templates/intake-questionnaire.md`, `decision-log.md` and `STATE.md`. Capture constraints verbatim in the private run. Do not replace the owner's words with a broader interpretation.

| Ask about | Capture | Reason |
|---|---|---|
| Work | Personal work, agency work, employers, clients, active and archived projects | Scope determines access and placement |
| Devices | Current machine, old disks, external adapters, phones, servers and shared devices | A path alone does not identify a physical source |
| Accounts | Login labels, owner, organization, allowed storage and publishing | An available account may be the wrong destination |
| Cloud | Providers, quotas, sync roots, online-only files and local caches | A visible filename may have no local contents |
| Tools | Daily apps, languages, toolchains, licenses, services and scheduled jobs | Data includes state outside project folders |
| Agents | Tools, profiles, config levels, skills, plugins, MCP servers and history | A working account may still load stale or unsafe config |
| Future | New clients, teammates, machines, larger datasets and shared services | The standard must grow without renaming everything |
| Constraints | No-touch sources, confidentiality, downtime, budget, disk capacity and network limits | These define execution boundaries |
| Communication | Voice dictation, common mishearings, terse output, MCQ preference | Questions must be understandable and answerable |

1. Draw a small source/current/target map using logical labels such as `<SOURCE-1>` and `<TARGET>`, because disk letters and mount names can change.
2. Associate each label with physical identity, capacity and a privately recorded serial or UUID. Have the owner confirm it before freeze operations.
3. Establish a storage policy for each scope and each agent account, because either account may be used for several kinds of work.
4. Record what success means: files present, repositories usable, app data restored, agents working, backups recoverable and sources kept.
5. Ask what must stay available during the run. Schedule writer shutdown and final delta scans around that work.
6. Save unanswered items with an owner and next action. Do not guess that an old folder is disposable.

Gate: the owner acknowledges the scope, constraints and open questions. This permits planning, not partitioning or uploading.
