# Pitfalls to check in each run

Each row is a generalized failure scenario and a prevention rule, derived from the author's account. Private source records are not included. Labels such as verified describe that account, not an independent public audit. Test each relevant boundary in the current run; do not treat this catalog as proof that the packaged scripts implement every fix.

## Requirements, questions and records

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| R01 | Initial partition plan was impossible | Capacity arithmetic and shrink limits were stale | Measure live supported size; recompute peak | Preserve recovery requirements because a bad implementation does not invalidate the goal |
| R02 | Recovery partition objective disappeared from revision | Agent optimized away the owner's requirement | Restore requirement from owner's prior asks | Maintain a requirements ledger because prior assistant output is not authority |
| R03 | Owner could not identify a question's folder | Names alone were unfamiliar | Add purpose, size, dates and ordinary examples | Explain each item because the owner cannot decide from a path alone |
| R04 | Question context vanished or previews clipped | UI hid preceding prose; cards were too terse | Put full context inside each card | Make each question self-contained because display behavior differs |
| R05 | Long lists and repeated approval prompts obstructed work | Too many questions and unbatched config edits | Ask at most four; review related exact changes together | Batch within scope because permission fatigue hides important choices |
| R06 | Agent continued while owner's questions remained unanswered | Execution took priority over direct questions | Answer first, then resume authorized work | Track unanswered questions because they steer the active task |
| R07 | Scope classification was wrong | Account/folder/client-like names were treated as ownership proof | Ask about actual work and relationship | Label inferred ownership because names are ambiguous |
| R08 | Missing answers became unclear authority | Truncated dialogs, cancellation and "later" | Keep raw answers and pending gates | Never infer consent because silence carries no decision |
| R09 | New work was absent from plan | Several working days passed between inventory and execution | Reconcile downloads, repos and sessions again | Date a cutoff because a plan ages while work continues |
| R10 | An unfetched branch could not supply a design | Local object did not exist | Use the available downloaded brief; fetch only if authorized | Check evidence availability because a branch name is not a local artifact |
| R11 | Old audits still claimed already-fixed paths were stale | Review evidence predated edits | Recheck actual files and date corrections | Audit live revisions because findings can expire |
| R12 | "All copied" overstated completion | Manual done markers included unresolved exceptions | Separate verified, partial, waived and deferred | Use dispositions because a marker cannot prove completeness |
| R13 | Final checks were missing from historical summary | Closing session happened after the note chunks | Append closing tail and reconciliation index | Preserve chronology because execution and closeout differ |
| R14 | Time/event ordering was inconsistent | UTC transcript stamps mixed with local command output | Declare timezone and convert only UTC stamps | Record time basis because double conversion changes causality |
| R15 | Final total-count script failed | Loop used the wrong automatic variable / null matches | Sum validated structured rows; qualify reported total | Recompute from evidence because an asserted total may outlive its failed calculation |
| R16 | Owner said drives removed but volumes remained online | Confirmation was not yet reflected in live state | Check again after shutdown and next startup | Distinguish testimony and observation because they can refer to different moments |

## Freeze, disks and capacity

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| D01 | Drive showed offline/zero capacity or "No Media" during diagnosis | Transport/source problem; exact early cause unresolved | Stop source reads; inspect host events and owner actions | Do not repair originals because evidence and recovery must survive |
| D02 | Departures were called spontaneous hardware failure | Owner shutdowns, unplugs and sleep/wake were omitted | Correlate event/power timeline with owner history | Qualify diagnosis because events need context |
| D03 | Retry storm passed the old gate | Departure counter missed disk/NTFS retries without departure | Check error IDs, dismounts and departures | Use multiple signals because no departure does not mean healthy I/O |
| D04 | Sleep protection failed after charger loss | Only AC settings had been changed | Review battery/lid behavior and recorded restoration | Cover relevant power states because AC can disappear |
| D05 | Hidden Git/editor/agent activity still touched originals | Background panes and metadata writers remained | Close writers; freeze at disk level | Do not rely on visible windows because watchers keep running |
| D06 | Freeze stopped after offline; online step failed | Device stopped answering; disk number became stale | Leave offline; owner checks connection; re-identify by stable identity | Never online in `finally` because read-only may not have succeeded |
| D07 | Read-only command did nothing without error | Padded serial selected zero disks | Trim serial; assert exactly one match and resulting state | Assert selection because empty pipelines can succeed |
| D08 | Port swap changed disk numbers | Enumeration order changed | Resolve current number from confirmed physical identity | Never persist a disk number as identity because reconnects reorder devices |
| D09 | Port improvement became proof of healthy platters | Power/adapter inference and SMART pass were overstated | Record correlation and remaining uncertainty | Do not promise hardware health because those checks are limited |
| D10 | Sources remained writable despite a freeze plan | Planned state was mistaken for actual/persisted state | Check current disk flags and persistence separately | Verify before every batch because intentions do not protect a disk |
| D11 | Root privacy claim was false | Disabling ACL inheritance left broad explicit ACEs | Review destination ACLs by SID and assert allowed entries | Inspect effective entries because inheritance alone is incomplete |
| D12 | Target space nearly exhausted | Live and rescue VM copies, archives and history overlapped | Budget peak storage and reserve before execution | Count simultaneous copies because final size understates peak |
| D13 | Proposed new partition treated as full backup | Partitions shared one physical device | Add independent backup and restore exercise | Track failure domains because one device loss takes both partitions |
| D14 | Settings restoration used a guessed value | Original value had not been captured | Label inference; ask owner; save originals next time | Record before changing because default is not necessarily prior state |
| D15 | Eject reported device in use | Readers or OS handles persisted | Close handles, or save/shut down before unplugging | Never promise safe hot-unplug solely from read-only because reads may be active |
| D16 | Repeated heavy scans worsened instability | Audits reread a troubled source | Reuse snapshots; stop reads; review host logs | Bound scan load because repeated reads are not free |

## Inventory, selection and coverage

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| I01 | Valuable Downloads content was marked disposable | Folder classified as installers without file evidence | Separate installers from ordinary documents | Inspect mixed folders because names do not establish contents |
| I02 | Identity documents and credentials reached ordinary routes | Sensitive material hid in generic folders and notebooks | Route by owner-reviewed metadata to separate handling | Treat unsure data explicitly because parent scope is insufficient |
| I03 | Loose profile files and deep repos were missed | Depth-limited scans and root assumptions | Full bounded enumeration plus explicit loose-root rows | Test root and nested cases because shallow coverage misses work |
| I04 | Whole disk appeared covered | A triage row at the drive root matched every descendant | Require exact bounded dispositions; self-test matcher | Do not use broad leave rows as proof because they mask omissions |
| I05 | Grouped paths did not match reliably | Several paths occupied one source field | Split into one path per row | Normalize rows because string splitting is ambiguous |
| I06 | Changed-file scan missed newly copied/moved work | Modification timestamps were preserved | Include creation/parent changes and current full coverage | Do not use mtime alone because movement can retain it |
| I07 | Partial scan looked complete | Enumeration exceptions were swallowed during resets | Record path/operation/error and nonzero exit | Fail visibly because empty results can mean failed reads |
| I08 | Detached scan output was empty/partial | Process launch was mistaken for completion | Record logs, exit and completion state | Verify job termination because launching is not finishing |
| I09 | Cloud tree vanished from inventory | Blanket reparse exclusion removed cloud directories | Inventory special attributes separately | Distinguish cloud and links because their recovery differs |
| I10 | `/XJ` did not exclude cloud placeholders | Cloud reparse tags differ from junction behavior | Inspect recall/offline attributes and copy selection | Test actual selection because a flag name is not a guarantee |
| I11 | Root placeholder grouping threw substring error | Assumed every file had a deeper parent | Handle root files separately | Validate relative-path arithmetic because root cases are different |
| I12 | Scan sizes overstated copied volume | Summed total column including excluded files | Use selected/copied bytes and structured row records | Budget selected data because listing totals have different meanings |
| I13 | API configuration cache inflated the vault | Broad parent routing mixed regenerable cache and credential stores | Separate cache from opaque credential handling | Assign bounded paths because vault routing should not hide bulk data |
| I14 | Old OS/AppData/Public/Default areas had no disposition | Coverage focused on known projects | Add explicit inventory or retained-original decisions | Include non-project state because it may hold irreplaceable data |

## Copy, Git, archives and history

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| C01 | Existing scaffolding made a copy row skip | Script treated any occupied destination as complete | Copy before scaffolding; compare mapped files | Do not equate existence with completion because an empty scaffold is not data |
| C02 | Resume could overwrite active edits | Copy reran a completed phase | Activation marker and separate new target | Lock active destinations because copied work becomes authoritative |
| C03 | Partial large file looked complete | Restartable/preallocated file had full length and newer time | Hash existing mapped files; preserve conflict; retry to fresh target | Never trust size/time alone because incomplete bytes can look current |
| C04 | Missing selected file returned success | Robocopy filter matched no file | Assert source existence and expected set | Validate inputs because transport success can copy nothing |
| C05 | Verification missed a failed listing | Only uncopied-file bit was tested; failure bits ignored | Check native status and expected contents | Reject every listing failure because no diff can be false |
| C06 | Frozen/ZIP tests printed FAIL but exited success | Assertions did not propagate process failure | Throw and exit nonzero | Test exit behavior because CI reads status, not prose |
| C07 | Logs collided and totals were incomplete | Filenames derived only from shared destinations; archive log absent | Prefix each log with stable row ID | Log every row because one target may have multiple operations |
| C08 | SSH files and sandbox marker denied reads | Old-account ACLs and protected service ownership | Owner-reviewed backup-mode recovery; retain exception | Never change source ownership because access is not worth losing the original boundary |
| C09 | Selected cloud files failed "write protected" | Hydration tried to write onto frozen source | Recover from approved cloud into new target or owner-defer | Preserve freeze because placeholders are not local contents |
| C10 | Tracked bytecode disappeared in copied repo | Cache exclusion ignored tracked state | Restore copied tracked files; check tracking before exclusions | Preserve all tracked work because cache-like names can be versioned |
| C11 | Worktree repair could modify original repo | Copied pointers still reached source admin paths | Rewrite destination `.git`/`gitdir` using explicit map first | Validate common-dir before repair because Git follows relationships |
| C12 | Worktree mapping failed on old drive prefix | Source links were already stale before migration | Map historical prefixes explicitly; repair destination only | Record broken source links because current source path is not the whole map |
| C13 | Worktree verification falsely passed | Hardcoded cases and ignored source-command errors | Check each worktree/common-dir and native exit | Test every registered worktree because top-level status is insufficient |
| C14 | Empty repo failed while corrupt objects could pass | Judged stderr text or used connectivity-only fsck | Use full integrity check and exit status | Verify objects because connectivity alone is weaker |
| C15 | Worktree fixture write failed | Hidden `.git` file required appropriate write handling | Edit copied hidden file explicitly | Test hidden metadata because normal file assumptions differ |
| C16 | Git reported unexpected fixture paths | `subst` resolved to real backing path | Compare canonical paths; avoid fake-drive collisions | Keep fixtures portable because aliases are not physical paths |
| C17 | Moved fixture/test broke script references | Hardcoded location or fake drive already existed | Derive from script root; refuse collision | Use isolated fresh roots because tests must not touch live paths |
| C18 | Relative/non-ASCII worktree relinks remained unproved | Historical mapper did not support them fully | Separate explicit fixtures and manual review | Do not advertise unsupported mapping because parser success is not correctness |
| C19 | Git bundle backup omitted local work | Bundles exclude untracked files and worktree state | Preserve full trees with metadata and verify archives | Back up working state because commits are only part of a repo |
| C20 | Windows tar crashed on filenames | Non-ANSI names hit the chosen implementation | Use tested Unicode-capable archive path and integrity test | Test Unicode extraction because archive creation alone is insufficient |
| C21 | Copied images appeared missing | Ordinary path checks exceeded Windows path limits | Extended-path verification found them | Use long-path APIs because false absence blocks safe cutover |
| C22 | One transcript kept differing | The current session was still writing it | Close all writers and repeat final check | Stop before history cutover because a moving source cannot match |
| C23 | "Already done" hid incomplete later steps | Early return checked only the history junction | Record and verify each step independently | Use per-step evidence because one sentinel cannot certify a workflow |
| C24 | Older history was missing | Retention setting absent in active profiles | Snapshot immediately; owner chooses retention | Preserve history early because cleanup can run during redesign |
| C25 | Transcript count and total-file count were conflated | Snapshot included attachments and metadata | Record both measures separately | Name denominators because counts describe different sets |
| C26 | Proposed recursive cleanup endangered live history | An old profile contained a junction to active data | Keep original; inspect link graph before any separate cleanup | Never recurse blindly because links can escape the tree |
| C27 | Resume/history lookup broke after project relocation | Histories and trust entries were keyed by paths | Map logical/physical paths and test resume per account | Verify user workflows because byte copies do not repair discovery |

## Shell, parser and process failures

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| P01 | Wrong copy arguments or paths | Automatic `$args` or case-insensitive `$m`/`$M`, `$w`/`$W` collisions | Use descriptive distinct variable names | Avoid reserved/colliding names because PowerShell shares them |
| P02 | Empty-array comparisons produced wrong state | Scalar/array semantics not normalized | Wrap expected collections and compare counts explicitly | Test empty inputs because zero repositories is valid |
| P03 | `continue` skipped the wrong loop | Used inside a PowerShell switch | Label outer row loop | Make control flow explicit because switch has its own iteration |
| P04 | Native progress became terminating error | Redirected stderr under ErrorActionPreference Stop | Scope preference and capture producer exit immediately | Use native semantics because stderr is not always failure |
| P05 | Docker query failed but displayed rc=0 | Downstream pipeline success replaced producer status | Save native exit before piping | Capture at source because pipelines can hide failures |
| P06 | Bulk replacements corrupted paths or lost saved edits | Bash/Node/PowerShell quoting and shell rewrites | Re-read; use edit tools and literal replacements preserving endings | Keep edits reviewable because shell interpolation changes text |
| P07 | Backslashes vanished; regex ended in invalid escape | Bash read without `-r`, nested escaping, sed replacement rules | Native path processing or tested script files | Avoid shell hopping because escaping compounds |
| P08 | A path became uppercase or a tab | sed interpreted `\U` or `\t` | Literal edit and byte-aware diff | Treat replacement text literally because Windows paths contain escapes |
| P09 | Replacement helper never ran | Function named `R` collided with Invoke-History alias | Rename helper and assert match counts | Avoid built-in names because resolution can be surprising |
| P10 | CSV edits created extra columns | Unquoted commas in notes | Write through CSV serializer and validate exact fields | Use real CSV parsing because comma counting is insufficient |
| P11 | Validator falsely rejected all rows | Incorrect property-count logic | Test validator on known-good/bad CSV fixtures | Verify the verifier because validation code also fails |
| P12 | Unicode test script would not parse | BOMless UTF-8 read as ANSI in PS5.1 | ASCII script with character-code fixture or UTF-8 BOM | Control encoding because defaults differ by runtime |
| P13 | Filename substitutions missed characters | En dash/nonbreaking-space differed from ASCII lookalikes | Preserve exact Unicode codepoints | Do not normalize names casually because path identity changes |
| P14 | Binary/video/transcript data flooded a diagnostic report | `-Include` with `-LiteralPath` did not constrain reads | Explicit allowlist before content access | Test filters on mixed fixtures because failed filtering can expose data |
| P15 | Parse check printed zero after error | Uninitialized `[ref]` variables | Initialize tokens/errors; fail if call fails | Require successful check execution because printed zero is not proof |
| P16 | Native CLI saw extra args or lost prompt text | PS5.1 stripped inner quotes | Simple args, JSON parsing, prompt/script files | Test argv because quoting bugs can alter effects |
| P17 | Node rejected `--mount` | Test options parsed as Node options | Use argument separator `--` | Separate interpreter and program options because both parse flags |
| P18 | Guard received empty/malformed JSON | Shell echo mangled Windows backslashes | Structured subprocess input from a test script | Serialize once because shell quoting is not JSON transport |
| P19 | Native Node could not find `/c/...` path | Git Bash path handed to Windows executable | Use native Windows absolute path | Respect executable platform because shell aliases do not translate everywhere |
| P20 | Row selection `15,21` became `1521` | Integer-array binding through `-File` | Parse a validated string list | Test entrypoint binding because interactive semantics differ |
| P21 | Browser timestamp overflowed number type | Microsecond timestamps exceeded safe JS integer range | Parse 64-bit integers exactly | Preserve numeric precision because silent conversion shifts dates |
| P22 | Redirecting stdin from NUL failed | Process API expected a normal file | Use fresh empty fixture file | Validate process API behavior because shell devices differ |
| P23 | Foreground copy/wait outlived tool or was blocked | Tool timeout and long sleep assumptions | Durable job, PID ancestry and monitor | Track process ownership because timeout is not termination |
| P24 | Monitor request failed validation | Required description omitted | Use tested complete monitor arguments | Validate orchestration because monitoring is part of the run |
| P25 | Duplicate transfers or orphan children could remain | Parent stopped without checking descendants | Inspect process tree before bounded restart | Enforce one writer because parent status is incomplete |
| P26 | No mobile alert arrived | Push notifications disabled | Record unavailable notification channel; use agreed alternative | Test alert path because a sent request may not notify anyone |

## Software, Docker and backups

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| S01 | Keep/drop package decisions conflicted | Product aliases mapped to the same package | Normalize exact package ID and scope | Reconcile aliases because one uninstall can remove a kept tool |
| S02 | Per-user uninstall failed under elevation | Installer scope did not match caller | Use owner-approved correct context | Match scope because admin is not always the right executor |
| S03 | MSI uninstall returned 1603 | Generic failure; elevation diagnosis was inferred | Inspect logs/processes; owner admin action; verify afterward | Do not assign cause from a generic code because several failures share it |
| S04 | New Python/Node/MCP appeared absent | Stale inherited PATH or store aliases won | Fresh-shell resolution and explicit managed executable | Verify executable origin because installation alone is insufficient |
| S05 | Cache migration returned robocopy 16 | Source possibly absent; exact cause unverified | Record failed row; reconcile source existence | Never normalize unknown errors because empty cache is only a hypothesis |
| S06 | Global install skipped build/postinstall script | Package manager policy | Record limitation; test needed operation under approved policy | Do not equate `--version` with full functionality because build steps matter |
| S07 | New password-manager app landed on OS disk | Default per-user installer path | Explain portable/installed tradeoff; owner chose | Resolve location before installation because toolchain rules may have app exceptions |
| S08 | Expected service data was not on current Docker disk | New and old disks held different generations | Inspect both copies; retain each until reconciled | Never assume older means obsolete because workloads differ |
| S09 | Only verified rescue copy would be consumed | Activation plan moved rescue into live location | Copy pristine rescue to separate live image | Preserve rescue because activation mutates data |
| S10 | Latest image could migrate database irreversibly | Version not pinned to copied state | Establish version evidence; pin DB major/app version | Verify compatibility before start because downgrade may be impossible |
| S11 | Unrelated required compose variables blocked DB backup | Full compose parse included proxy configuration | Reviewed DB-only operation; owner-supplied config | Isolate required service because unrelated settings should not block recovery |
| S12 | SQL export encoding could change | PowerShell native redirection writes text encoding | Dump inside container, then copy file out | Preserve bytes because databases need exact export format |
| S13 | Backup/swap/export was blocked by approval review | Credential, PII, shared-resource or irreversible effect | Explain block and give owner exact reviewed operation | Respect denial because script indirection is not permission |
| S14 | Starting services could fire external work | Restart policies, schedules and webhooks | Stop/disable on copy; owner confirms activation/network policy | Separate activation because local copy can create outward effects |
| S15 | Tunnel inspector exposed payloads to LAN | Port bound to all interfaces | Bind approved local inspection port to loopback | Review network binding because defaults can expose data |
| S16 | Container/image visibility differed | Image-store/backend settings changed | Reconcile backend and volume evidence | Do not infer data loss from one listing because storage backends differ |
| S17 | WSL user/inline shell check behaved unexpectedly | Registration/default-user config and stripped shell quotes | Review copied distro settings; use script-file check | Test actual user/workflow because registration alone is not recovery |
| S18 | A stopped recovered service was treated as broken | Owner had intentionally stopped it | Ask/record intent; do not restart automatically | Preserve desired operating state because stopped can be correct |
| S19 | Wrong-password archive test overstated recovery | Only header encryption was checked | Owner tests correct password and representative restore | Test recovery because encryption evidence is not restore evidence |

## Cloud and identity

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| N01 | Upload stalled at 0 B/s twice | Verified shared-client quota errors | Owner-managed approved client; bounded retries/log diagnosis | Inspect service errors because reachability is not throughput |
| N02 | Changing narrow-scope client hid prior uploaded objects | Object visibility belonged to old app authorization | Owner-approved retain/segregate old upload; fresh copy | Reconcile scope identity because authorization affects visibility |
| N03 | OAuth login was blocked in testing mode | Consent setup prerequisites incomplete | Follow current provider docs and owner setup | Verify current requirements because account flows change |
| N04 | Publishing consent app required more branding fields | Earlier instructions omitted prerequisites | Use legitimate owner-controlled required details | Never copy unverified third-party branding shortcuts because they do not prove authorization |
| N05 | OAuth token appeared in transcript | Login ran through captured command shortcut | Owner revokes/reconnects in separate terminal | Keep auth outside capture because CLI output can contain secrets |
| N06 | Overnight upload failed then verify said mismatch | Network unavailable, not proven file corruption | Restore connectivity, rerun copy, then verify | Distinguish unavailable from different because checks have prerequisites |
| N07 | Disk space planning ignored sync cache | Desktop sync could stage large upload locally | Evaluate actual cache behavior/capacity; approved direct-copy tool | Budget staging because remote size does not imply local space-free transfer |
| N08 | Cloud "verified" implied hashes of everything | Final check was one-way size-only | Label assurance and retain transport/check logs | State method because checks prove different properties |
| N09 | Privacy filter could fail open | Listing helper failure not propagated | Refuse upload on any selection-list failure | Prove exclusions because an unreadable list cannot certify privacy |
| N10 | Account check command unsupported | Remote did not implement UserInfo | Owner confirmation plus approved identity evidence | Do not infer account from quota because multiple accounts can share capacity |
| N11 | Wrong account published content; assurance was false | Account restrictions only in prose and unverified login | Test account-aware enforcement and actual identity | Name identity before sending because folder choice does not select account |
| N12 | Per-folder username did not select intended remote account | Credential helper ignored inactive-account preference | Reviewed scoped helper and non-secret identity tests | Test author and auth separately because they are independent |
| N13 | Identity test gave same result for all scopes | Fixture lived outside matching directories | Test inside actual scope paths | Exercise real matching rules because scratch location changes behavior |
| N14 | Blank email did not block a commit | Git could still resolve an author | Explicit useConfigOnly and tested reference-scope rule | Test rejection behavior because an empty field is not necessarily a gate |
| N15 | Push could deploy or author mismatch could prevent build | Production integration and author constraints not recorded | Hold deploying push; respect repo author policy | Record downstream effect because backup push may publish |
| N16 | Git push/MCP add returned confusing error despite success | Native stderr/exit wrappers; exact cause sometimes unknown | Verify resulting branch/server state without replaying blindly | Check postcondition because a wrapper error can follow a completed action |

## Agent configuration, guards and UI

| ID | Symptom | Cause | Fix | Rule and reason |
|---|---|---|---|---|
| A01 | Both account instructions loaded or state split | Home-directory starts and shadow launcher on PATH | Start in project; verify real launcher/account | Test fresh session because intended profile is not necessarily active |
| A02 | Scope rules failed to load in nested repo | Parent imports differed from global imports | Tested hard link or controlled adapter copy | Verify discovery because provider levels have different behavior |
| A03 | SCOPE metadata stopped loading after adapter change | Hard-linked rules replaced wrapper imports | Explicitly read SCOPE; test it independently | Test all required context because one loaded file does not imply others |
| A04 | Unused skills/connectors consumed large context | Duplicate installs and broad always-on loading | Owner-approved keep/park catalog; measure fresh session | Base pruning on use because capability availability is not evidence of need |
| A05 | Hook fired twice or compacted too aggressively | Vendored/plugin duplication and account settings divergence | Remove duplicate activation after backup; test settings | Reconcile layers because global and project behavior can combine |
| A06 | Junction creation failed | Parent/link layout inconsistent; exact initial cause unclear | Inspect actual target/parent; build only unused adapter paths | Check postconditions because a creation command can fail halfway |
| A07 | Guard blocked ordinary reads or wrapper invocation | Broad path regex did not distinguish read/write/execute | Log rule ID; test narrowly revised rule with owner approval | Separate operations because path presence alone does not define risk |
| A08 | Guard diagnosis/replay lacked evidence | Truncated payload logs produced invalid JSON | Structured bounded metadata; label incomplete replay | Preserve diagnostic structure because truncated text is not valid input |
| A09 | Script form bypassed an inline denial | Guard inspected command text but not equivalent script effects | Do not repeat denied action indirectly; route review | Honor action semantics because shell choice must not change authority |
| A10 | Secret files were allowed | Patterns missed `.secrets`, service.env and token/creds JSON | Add synthetic denial/pass cases; broaden reviewed patterns | Test realistic names because `.env` alone is insufficient |
| A11 | Guard errors or unsupported providers could allow actions | Fail-open behavior and uneven adapter coverage | Fail closed for protected actions; per-provider tests | Declare enforcement limits because one hook does not cover every tool |
| A12 | Wrapper/bridge could expose keys through edited code | Child runs as same user with injected environment | Narrow separate service/identity; protect executor | Use real access boundaries because regex and env injection are not isolation |
| A13 | Personal account verification failed | Expired authentication | Owner logs in separately; retain unverified status | Never authenticate for owner because credentials stay outside agent access |
| A14 | Status line vanished on small screens | Layout exceeded available width | Responsive/stacked rows and visible fallback | Test narrow widths because default terminal size is not universal |
| A15 | Status display hid information without drawing | File handoff success did not prove actual UI render | Keep fallback until owner-visible render confirmed | Verify visible output because mocks can pass while UI fails |
| A16 | Mod tests failed on missing APIs/result shapes | Incorrect mocks and hook contracts | Read current API; return required structured results | Test integration contracts because plausible signatures are not enough |
| A17 | Plugin install could not find new entry | Marketplace edit had not succeeded | Re-read, edit and validate catalog before install | Verify written state because a failed edit leaves old configuration |
| A18 | Agent prematurely denied a feature existed | Outdated capability knowledge | Inspect current local docs/API before concluding | Verify niche capabilities because memory can be stale |
| A19 | Concurrent report edits risked loss or stale statements | Writers shared a file without clear ownership | Re-read, assign sections, validate final content | Coordinate edits because parallel output shares state |
| A20 | Edit failed "file not read" | Tool required a current read | Re-read immediately before edit | Respect edit preconditions because user or another agent may have changed it |
| A21 | Read-only messaging connector exposed send tools | Server advertised writes despite intended policy | Explicit deny list and tests; owner controls sends | Enforce tool-level scope because prose alone does not remove capabilities |
| A22 | Proposed work looked finished in final reports | UI fixes, schedules, secret isolation and scope fields remained pending | Owned later-work list with evidence and acceptance | Keep unfinished work visible because a successful migration is bounded |

Use these rules in the relevant phase rather than asking the owner to memorize the catalog. Keep any new failure in the run's change log with symptom, observed cause, fix, verification and prevention rule.
