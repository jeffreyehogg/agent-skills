---
name: spec-driven-feature
description: >-
  Enforces a specification-first development workflow (SPEC.md gating protocol).
  Activates when designing or implementing complex multi-file features (3+ files),
  new API endpoints, database schema migrations, or cross-cutting architectural changes.
  DO NOT trigger for single-file edits, isolated bug fixes, test-only additions,
  or when an approved specification already exists.
---

# Spec-Driven Feature Development

## Overview
This skill enforces a **Plan-Before-Code Gating Protocol**. Autonomous coding agents often fail by leaping directly into file edits, leading to context drift, hallucinated APIs, and wasted tokens on trial-and-error debugging.

When this skill activates, **no application code may be modified** until a formal specification (`SPEC.md` or `.specs/<feature-slug>.md`) is drafted, verified against repository constraints, and approved.

---

## 1. Phase 1: Context & Constraint Scouting

Before drafting the specification:
1. Identify existing conventions, data models, and API utilities in the project.
2. Locate type definitions or schema files (e.g., `schema.prisma`, `drizzle/schema.ts`, Zod schemas, OpenAPI specs).
3. Do not read entire files unless necessary; inspect exports, interface headers, and types.

---

## 2. Phase 2: Draft `SPEC.md`

Read [`./references/spec_template.md`](./references/spec_template.md) and create `.specs/<feature-slug>.md` (or `SPEC.md` in the repository root if requested) following that exact structure:
1. **Objective, Success Criteria & Explicit Non-Goals:** Clear 2-sentence problem statement, deterministic pass criteria, and explicit out-of-scope boundaries.
2. **Data Contracts & Signatures:** Exact TypeScript interfaces, database column types, or API schemas.
3. **File Modification Boundary Matrix:** Explicit `Create`, `Modify` (with target functions/lines), and `Forbidden` paths.
4. **Implementation Checklist & Verification Protocol:** Exact test commands, linter checks, and edge cases.

---

## 3. Phase 3: The Gating Checkpoint (MANDATORY)

Once the specification is generated:
1. **Interactive Mode (User Session):** Present a concise summary linking to the spec file, surface any architectural tradeoffs (using `ask_question` if multiple valid approaches exist), and ask for confirmation before writing code:
   > *"I have drafted the specification in [`SPEC.md`](./SPEC.md). Please review the proposed data contracts and file boundary matrix. Shall I proceed with implementation?"*
2. **Autonomous Subagent Mode:** If invoked by a parent Lead Orchestrator (e.g., from [`code-audit-orchestrator`](../code-audit-orchestrator/SKILL.md)) that already provided an approved Remediation Plan, verify that the File Boundary Matrix has zero conflicts with `Forbidden` paths and proceed to Phase 4.
3. **HARD STOP:** In interactive sessions, wait for approval or feedback. Do not touch source files until given the green light.

---

## 4. Phase 4: Phased Execution & Mid-Flight Amendment Protocol

Upon approval:
1. **Optional Sandbox Isolation:** For multi-file changes or when the primary working tree has unrelated changes, provision an isolated worktree via [`git-worktree-isolator`](../git-worktree-isolator/SKILL.md) before modifying files.
2. Implement the feature in discrete, atomic milestones (e.g., Schema $\to$ Core Logic $\to$ API Handlers $\to$ UI/Integration).
3. Mark off progress checkboxes in the spec file as milestones complete.
4. Keep git commits scoped to individual milestones.

### Escape Hatch: Mid-Flight Spec Amendment
If implementation uncovers an unforeseen constraint (e.g., a `Forbidden` file *must* be modified, an upstream SDK type mismatches the drafted contract, or the user amends requirements mid-flight):
1. **Halt edits immediately** on the affected milestone.
2. Append an entry to `## 6. Spec Amendments (Delta Log)` in the spec file documenting:
   - **Trigger / Blocker:** Why the original contract cannot hold.
   - **Amended Section & Delta:** Exact changes to Data Contracts or the File Modification Boundary Matrix.
3. If the delta touches a previously `Forbidden` file or alters a public API/schema contract, pause and request fast-track user confirmation before resuming. If the delta is purely internal (e.g., extracting an internal helper file), log the delta in the spec and continue.

---

## 5. Phase 5: Verification & Archive

1. Run the deterministic test suite specified in Phase 2.
2. Verify all type-checks and linters pass cleanly.
3. Update the spec status to `Completed` and archive it to `.specs/completed/YYYY-MM-DD-<feature-name>.md` (or remove temporary spec files if the repository does not track `.specs/`).
