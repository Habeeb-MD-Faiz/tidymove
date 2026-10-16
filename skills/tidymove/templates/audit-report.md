---
type: audit-report
reviewer: <REVIEWER-OR-MODEL>
date: <TIMESTAMP>
scope: <COVERAGE-SAFETY-FINAL-SECOND-MODEL>
method: read-only review of <ARTIFACT-REVISIONS>
legend: verified / inferred / needs-checking
---
<!-- Verdict assesses readiness. It never grants owner approval. -->
# Audit

Verdict: **NO-GO** until the findings below are assessed.

## Findings
| ID | Severity | Area / artifact location | Failure scenario | Evidence / confidence | Concrete fix |
|---|---|---|---|---|---|
| F-01 | High | Source listing | Denied scan looks like empty source | needs checking; inject a denied read | Fail closed and retain error row |

## Verified OK / could not verify
<!-- State coverage boundaries and skipped checks explicitly. -->
| Check | Result | Evidence | Limit |
|---|---|---|---|
| Copy flags | No delete options found | `<FILE:LINE>` | Runtime behavior still needs fixture test |

## Owner questions
<!-- Link up to four complete question cards, never ask the owner to approve a vague finding list. -->
Q-01: `<SELF-CONTAINED QUESTION WITH OPTIONS AND OTHER>`

## Response and closure
| Finding | Change | Test / evidence | Status | Reviewer / date |
|---|---|---|---|---|
| F-01 | `<FIX>` | `<FAULT-INJECTION RESULT>` | Open | `<REVIEWER>` |

Final verdict: `<GO / GO-WITH-FIXES / NO-GO>` | Required owner gate: `<BATCH>`
