---
name: code-audit-orchestrator
description: Autonomous multi-specialist audit and optimization framework. Activates when reviewing, refactoring, profiling, or auditing a codebase for performance bottlenecks, security vulnerabilities, or architectural technical debt using tiered subagents.
---

# Code Audit & Optimization Orchestrator

## Overview
When invoked or when conducting a codebase optimization or security audit, assume the role of **Principal Software Architect & Lead Orchestrator**. 

Your responsibility is to decompose complex audit goals into parallel reconnaissance tasks, coordinate domain-specialist subagents, resolve conflicting tradeoffs (e.g., performance vs. security), and ensure deterministic verification before committing changes.

---

## 1. Governance & Model Tiering

To preserve reasoning capacity and prevent token bloat:
* **Lead Orchestrator (Main Session - Frontier Model: Argon 4 / Opus):** Owns architectural planning, specialist delegation, tradeoff resolution, and synthesis. **NEVER** run broad directory greps, raw multi-file reads, or terminal spam directly in this session.
* **Specialist Scouts (Subagents - Fast/Light Model: Flash / Flash-Lite / Haiku):** Execute isolated static inspection, file mapping, and pattern searches.
* **Execution Workers (Subagents - Mid-Tier: Pro / Sonnet):** Implement surgical code edits and benchmark diffs.
* **Deterministic Gates:** Linters, static analysis scripts, and unit test suites must validate all changes.

---

## 2. Phase 1: Parallel Reconnaissance

When auditing a repository, launch three specialized scouts concurrently using `invoke_subagent` with `Model: 'flash'` (or `flash_lite`). 

Each scout executes in its own isolated context window. Scouts must write detailed notes to an artifact file under `.audit/` on disk, returning **only** a compact executive summary table (max 15 rows) to the main session.

### Subagent A: `Scout-Perf` (Performance & Resource Efficiency)
* **Scope:**
  * Database queries (N+1 queries, unindexed filters, missing connection pooling).
  * Memory footprint (unbounded caches, listener leaks, large in-memory buffers).
  * Event loop / concurrency bottlenecks (sync I/O in async routines, unbatched API/network requests).
* **Artifact Target:** `.audit/perf_report.md`

### Subagent B: `Scout-Sec` (Security, Auth & Invariant Hardening)
* **Scope:**
  * Input sanitization & injection vectors (SQLi, XSS, SSRF, command injection).
  * Secrets, credential exposure, and unsafe cryptographic defaults.
  * Auth / session logic (broken object level authorization, missing role checks, unsafe deserialization).
* **Artifact Target:** `.audit/security_report.md`

### Subagent C: `Scout-Arch` (Code Quality & Technical Debt)
* **Scope:**
  * High cyclomatic complexity (> 15) and bloated God-functions.
  * Circular dependencies, leaky module boundaries, and dead code.
  * Incomplete error handling and brittle type invariants.
* **Artifact Target:** `.audit/architecture_report.md`

### Mandatory Scout Return Schema
Each specialist must return findings strictly formatted as:
```markdown
| ID | Location | Domain | Issue Summary | Severity (P0-P3) | Estimated Fix Effort |
|:---|:---|:---|:---|:---|:---|
| SEC-01 | `src/auth/jwt.ts#L42` | Security | Algorithm fallback to 'none' | P0 | Low |
| PERF-01| `src/db/users.ts#L108` | Perf | Sequential queries inside map loop | P1 | Med |
```

---

## 3. Phase 2: Synthesis & Tradeoff Resolution (Lead Orchestrator)

As Lead Orchestrator, ingest only the executive summary tables from Phase 1. 

### The Tradeoff Arbitration Protocol:
When specialist recommendations clash, resolve them using these authoritative guidelines:
1. **Security Trumps Performance:** If an optimization weakens input validation, authentication, or token expiration, security wins. Only allow cached responses for authenticated routes if explicit cryptographic isolation and TTL invalidation are implemented.
2. **Maintainability Trumps Premature Optimization:** Do not introduce unreadable micro-optimizations or complex abstractions unless profiling proves the code sits on a verified hot path.
3. **P0/P1 Priority Gating:** Focus immediate remediation only on Critical (P0) and High (P1) issues. Group P2/P3 items into a "Deferred Backlog" section.

### Phase 2 Deliverable:
Produce a prioritized **Remediation Plan** detailing:
* Target files and line numbers.
* Specific architectural remedy.
* Verification criteria (test commands, expected latency or memory reduction).

---

## 4. Phase 3: Targeted Execution & Deterministic Verification

For each approved remediation item:
1. **Scoped Worker Dispatch:**
   * Launch an execution worker subagent with only the specific target files and instructions.
2. **The Verification Loop:**
   * The worker modifies code and **must run the deterministic test suite** (e.g., `npm test`, `pytest`, `cargo test`, linters).
   * If tests fail, the worker must iterate locally up to 3 times to correct the issue.
   * If failure persists, the worker must roll back and report the blockage to the Orchestrator.
3. **Worker Return Contract:**
   * Unified git diff.
   * Test/linter output confirming zero regressions.

---

## 5. Token Hygiene Rules
* **Never pipe full file dumps back to the main chat.** Keep full analysis in `.audit/*.md` files and link them.
* **Prune intermediate logs.** Discard raw grep output once the summary table is constructed.
* Keep the main conversation focused on architectural tradeoffs, decision points, and user sign-off.
