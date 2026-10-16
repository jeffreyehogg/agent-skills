# Audit Handoff & Report Schemas

Reference schemas for subagents reporting findings back to the Lead Orchestrator.

## 1. Specialist Executive Summary Table Schema

```markdown
| ID | Location | Domain | Issue Summary | Concrete Evidence / Remedy | Severity | Effort |
|:---|:---|:---|:---|:---|:---|:---|
| PERF-01 | `src/api/routes.ts#L45-L60` | Perf | Unbatched SQL queries in `map` loop | Replace `await db.query` in loop with `WHERE id = ANY($1)` | P1 | Low |
| SEC-01  | `src/middleware/auth.ts#L22` | Sec | Insecure JWT secret fallback | Enforce `algorithms: ['RS256']` and fail fast on missing key | P0 | Low |
| ARCH-01 | `src/services/billing.ts#L10` | Arch | Circular import with `UserService` | Extract shared `BillingUserPort` interface into `src/types/` | P2 | High |
| UI-01   | `src/components/Modal.tsx#L18` | UI | Non-semantic modal `<div onClick>` without focus trap | Replace custom overlay `<div>` with native `<dialog>` element | P1 | Low |
```
**Constraint:** Return at most **15 rows** ordered by severity (`P0` $\to$ `P3`). Do not include raw file dumps.

## 2. Severity Classification Definitions

- **P0 (Critical / Blocker):**
  - Security: Remote code execution, auth bypass, plaintext secret exposure, unauthenticated data exfiltration.
  - Performance: Server crash, memory leak causing OOM under normal load, deadlocks.
  - UI / Frontend: Broken primary user flow, infinite render loop freezing the browser tab, completely inaccessible critical action (e.g., keyboard/screen-reader trap on checkout/login).
- **P1 (High Priority):**
  - Security: Missing CSRF/CORS protections, unvalidated redirects, IDOR.
  - Performance: O(N^2) or worse query loops, unindexed high-volume DB queries, blocking main event loop > 100ms.
  - UI / Frontend: Interactive `<div onClick>` controls missing keyboard/role semantics, cascading client fetch waterfalls, severe layout shift (CLS), or missing error/loading states on critical mutations.
- **P2 (Medium Priority):**
  - Architecture: Complex God-classes, high cyclomatic complexity, inconsistent error handling.
  - Performance: Redundant network requests, missing payload compression.
  - UI / Frontend: Legacy JS scroll/modal/layout workarounds replaceable by modern CSS/HTML (`<dialog>`, Popover, `:has()`, container queries), unmemoized context causing avoidable subtree re-renders.
- **P3 (Low Priority / Tech Debt):**
  - Minor code smells, inconsistent naming, dead utility functions, hardcoded design token values.

## 3. Worker Verification Report Schema

Returned by the execution worker upon test suite validation:

```markdown
### Verification Summary
- **Target File(s):** `src/api/routes.ts`
- **Issue Resolved:** PERF-01 (Batched query execution)
- **Diff Stat:** `1 file changed, 12 insertions(+), 18 deletions(-)`
- **Tests Executed:** `npm test -- routes.test.ts`
- **Result:** `PASSED` (14/14 green, 0 regressions, Attempt 1/3)
- **Benchmark / Metrics:** Query count reduced from 25 to 1 per request.
```
