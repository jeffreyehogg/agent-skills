# Audit Handoff & Report Schemas

Reference schemas for subagents reporting findings back to the Lead Orchestrator.

## 1. Specialist Executive Summary Table Schema

```markdown
| ID | Location | Domain | Issue Summary | Severity (P0-P3) | Estimated Fix Effort |
|:---|:---|:---|:---|:---|:---|
| PERF-01 | `src/api/routes.ts#L45-L60` | Performance | Unbatched SQL queries in loop | P1 | Low |
| SEC-01  | `src/middleware/auth.ts#L22` | Security | Insecure JWT secret validation | P0 | Low |
| ARCH-01 | `src/services/billing.ts#L10` | Architecture | Tight circular dependency with User service | P2 | High |
```

## 2. Severity Classification Definitions

- **P0 (Critical / Blocker):**
  - Security: Remote code execution, auth bypass, plaintext secret exposure, unauthenticated data exfiltration.
  - Performance: Server crash, memory leak causing OOM under normal load, deadlocks.
- **P1 (High Priority):**
  - Security: Missing CSRF/CORS protections, unvalidated redirects, IDOR.
  - Performance: O(N^2) or worse query loops, unindexed high-volume DB queries, blocking main event loop > 100ms.
- **P2 (Medium Priority):**
  - Architecture: Complex God-classes, high cyclomatic complexity, inconsistent error handling.
  - Performance: Redundant network requests, missing payload compression.
- **P3 (Low Priority / Tech Debt):**
  - Minor code smells, inconsistent naming, dead utility functions.

## 3. Worker Verification Report Schema

Returned by the execution worker upon test suite validation:

```markdown
### Verification Summary
- **Target File(s):** `src/api/routes.ts`
- **Issue Resolved:** PERF-01 (Batched query execution)
- **Tests Executed:** `npm test -- routes.test.ts`
- **Result:** PASSED (All 14 tests green)
- **Benchmark / Metrics:** Query count reduced from 25 to 1 per request.
```
