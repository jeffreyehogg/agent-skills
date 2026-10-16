---
name: code-audit-orchestrator
description: >-
  Autonomous multi-specialist codebase audit and remediation framework.
  Activates when auditing, profiling, hardening, or systematically reviewing a
  repository or module for performance bottlenecks, security vulnerabilities,
  frontend/UI accessibility & rendering issues, or architectural technical debt using tiered subagents.
  DO NOT trigger for single-file bug fixes, greenfield feature creation, or trivial syntax questions.
---

# Code Audit & Optimization Orchestrator

## Overview
When invoked or when conducting a codebase optimization or security audit, assume the role of **Principal Software Architect & Lead Orchestrator**. 

Your responsibility is to decompose complex audit goals into parallel reconnaissance tasks, coordinate domain-specialist subagents, resolve conflicting tradeoffs (e.g., performance vs. security), and ensure deterministic verification before committing changes.

---

## 1. Governance & Model Tiering

To preserve reasoning capacity and prevent token bloat:
* **Lead Orchestrator (Main Session - Frontier Model: Argon 4 / Opus):** Owns architectural planning, specialist delegation, tradeoff resolution, and synthesis. **NEVER** run broad directory greps, raw multi-file reads, or terminal spam directly in this session.
* **Specialist Scouts (`invoke_subagent` with `TypeName: 'research'`, `Model: 'flash'`):** Execute isolated, read-only static inspection, file mapping, and vulnerability/bottleneck discovery.
* **Execution Workers (`invoke_subagent` with `TypeName: 'self'`, `Model: 'pro'`):** Implement surgical code edits, run deterministic test suites, and verify zero regressions.
* **Deterministic Gates:** Linters, static analysis scripts, and unit test suites must validate all changes.

---

## 2. Phase 0: Deterministic Pre-Reconnaissance

Before spawning subagents, run the deterministic reconnaissance script to map repository size, file extensions, frontend presence (`HAS_FRONTEND`), and >500-line hotspots at near-zero token cost:
1. Execute [`./scripts/quick_recon.sh`](./scripts/quick_recon.sh) via `run_command` with `Cwd` set to the target repository root.
2. Check the `HAS_FRONTEND=true|false` flag and hotspot list in the output to configure Phase 1 Scouts.

---

## 3. Phase 1: Parallel Reconnaissance

When auditing a repository, launch specialized read-only scouts concurrently in a **single** `invoke_subagent` call (`TypeName: 'research'`, `Model: 'flash'`):
* Always launch **Subagents A, B, and C** (`Scout-Perf`, `Scout-Sec`, `Scout-Arch`).
* Launch **Subagent D (`Scout-UI`)** **if and only if** Phase 0 reported `HAS_FRONTEND=true` (or the user explicitly requested a UI/frontend audit).

Each scout executes in its own isolated context window. Instruct each scout to follow the severity definitions and return **only** a compact executive summary table (max 15 rows, plus up to 3 lines of evidence per P0/P1 finding) matching the `Specialist Executive Summary Table Schema` in [`./references/schemas.md`](./references/schemas.md).

### Subagent A: `Scout-Perf` (Performance & Resource Efficiency)
* **Scope:**
  * Database queries (N+1 queries, unindexed filters, missing connection pooling).
  * Memory footprint (unbounded caches, listener leaks, large in-memory buffers).
  * Event loop / concurrency bottlenecks (sync I/O in async routines, unbatched API/network requests).

### Subagent B: `Scout-Sec` (Security, Auth & Invariant Hardening)
* **Scope:**
  * Input sanitization & injection vectors (SQLi, XSS, SSRF, command injection).
  * Secrets, credential exposure, and unsafe cryptographic defaults.
  * Auth / session logic (broken object level authorization, missing role checks, unsafe deserialization).

### Subagent C: `Scout-Arch` (Code Quality & Technical Debt)
* **Scope:**
  * High cyclomatic complexity (> 15) and bloated God-functions.
  * Circular dependencies, leaky module boundaries, and dead code.
  * Incomplete error handling and brittle type invariants.

### Subagent D: `Scout-UI` (Frontend, Accessibility & Rendering Craft)
*(Conditional: Spawn ONLY when Phase 0 outputs `HAS_FRONTEND=true`)*
* **Scope:**
  * **Rendering & Core Web Vitals (CWV):** Client fetch waterfalls, unnecessary full-subtree re-renders, unvirtualized large lists, layout shift (CLS) triggers, and missing `content-visibility` / image sizing.
  * **Accessibility (a11y) & Semantics:** Interactive `<div>`/`<span>` controls lacking keyboard/role support, missing form labels, broken focus traps in modals/popovers, and ARIA misuse.
  * **Modern Web & Styling Hygiene:** Legacy JS layout/scroll hacks replaceable by native HTML/CSS (`<dialog>`, Popover API, `:has()`, container queries, `dvh`), hardcoded magic colors/spacing bypassing design tokens, and missing loading/empty/error states.

> [!IMPORTANT]
> **Scout Failure / Timeout Fallback:** If a scout fails or hits a context limit on a large monorepo, re-invoke it scoped strictly to the top hotspot subdirectories identified in Phase 0 rather than running broad scans in the main session.

---

## 4. Phase 2: Synthesis & Tradeoff Resolution (Lead Orchestrator)

As Lead Orchestrator, ingest only the executive summary tables from Phase 1. 

### The Tradeoff Arbitration Protocol:
When specialist recommendations clash, resolve them using these authoritative guidelines:
1. **Security Trumps Performance:** If an optimization weakens input validation, authentication, or token expiration, security wins. Only allow cached responses for authenticated routes if explicit cryptographic isolation and TTL invalidation are implemented.
2. **Maintainability Trumps Premature Optimization:** Do not introduce unreadable micro-optimizations or complex abstractions unless profiling proves the code sits on a verified hot path.
3. **Accessibility & Native Web Primitives Trump JS Micro-Hacks:** Never strip semantic DOM elements, focus management, or ARIA attributes to shave bytes; prefer native browser APIs (`<dialog>`, Popover, CSS transitions) over custom JS listeners.
4. **P0/P1 Priority Gating:** Focus immediate remediation only on Critical (P0) and High (P1) issues. Group P2/P3 items into a "Deferred Backlog" section.

### Phase 2 Deliverable:
Persist the synthesized **Remediation Plan** to `.audit/remediation_plan.md` (or conversation artifact) detailing:
* Target files and line numbers.
* Specific architectural remedy and non-overlapping file ownership sets.
* Verification criteria (test commands, expected latency or memory reduction).
* **Spec Handoff (`High` Effort P0/P1 Items):** For architectural remediations spanning 3+ files or altering schemas/APIs, invoke [`spec-driven-feature`](../spec-driven-feature/SKILL.md) to draft `.specs/remediate-<ID>.md` with an explicit File Modification Boundary Matrix before dispatching workers.

---

## 5. Phase 3: Targeted Execution & Deterministic Verification

For each approved remediation item:
1. **Scoped Worker Dispatch:**
   * Launch an execution worker subagent (`TypeName: 'self'`, `Model: 'pro'`) with only the specific target files, remedy instructions, and verification commands.
   * **Frontend Modernization Synergy:** When dispatching a worker for `UI-*` findings, instruct the worker to activate the `modern-web-guidance` skill (if available) so UI fixes use current baseline HTML/CSS/JS APIs.
   * **Concurrency & Sandbox Guard:** Never run two workers concurrently in `Workspace: 'inherit'` if their target file sets overlap. Group overlapping edits into a single worker, isolate via `Workspace: 'share'`, or provision a dedicated worktree via [`git-worktree-isolator`](../git-worktree-isolator/SKILL.md).
2. **The Verification Loop:**
   * The worker modifies code and **must run the deterministic test suite** (e.g., `npm test`, `pytest`, `cargo test`, linters).
   * If tests fail, the worker must iterate locally up to 3 times to correct the issue.
   * **Safe Scoped Rollback:** If failure persists after 3 attempts, the worker must roll back **only** its target files (`git checkout -- <target-files>`), never `git reset --hard`, and report the exact failure output to the Orchestrator.
3. **Worker Return Contract:**
   * Workers must return strictly the compact `Worker Verification Report Schema` defined in [`./references/schemas.md`](./references/schemas.md) (`git diff --stat` summary + test/linter pass confirmation). Do **not** paste multi-hundred-line raw unified diffs into the main conversation.

---

## 6. Token & Git Hygiene Rules
* **Never pipe full file dumps or raw unified diffs back to the main chat.** Keep full analysis in `.audit/remediation_plan.md` and link it.
* **Prune intermediate logs.** Discard raw grep output once the summary table is constructed.
* **Clean Git Status:** Ensure `.audit/` is listed in `.git/info/exclude` or removed before committing so audit scratch files are never committed into the repository.
* Keep the main conversation focused on architectural tradeoffs, decision points, and user sign-off.
