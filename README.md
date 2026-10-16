# agent-skills

A curated repository of high-leverage agentic skills, multi-model orchestrator workflows, and prompt architecture for Antigravity and modern AI coding agents.

## Architecture

This repository adopts the **Tiered Multi-Agent Pattern**:
- **Frontier Orchestrator (Argon 4 / Opus):** Owns architectural decomposition, specialist subagent coordination, tradeoff resolution, and synthesis.
- **Specialist Workers (Sonnet / Pro):** Executes targeted multi-file code modifications and refactoring.
- **Scouts & Verifiers (Flash / Haiku / CLI):** Performs deterministic checks, fast grep/AST reconnaissance, test runs, and static linting in sandboxed context windows.

---

## Skills Inventory

| Skill | Description | Target Role |
| :--- | :--- | :--- |
| [`code-audit-orchestrator`](./code-audit-orchestrator/SKILL.md) | Autonomous multi-specialist audit and optimization framework covering Performance, Security, and Architecture. | Orchestrator: Frontier<br>Scouts: Flash/Haiku |
| [`spec-driven-feature`](./spec-driven-feature/SKILL.md) | Plan-before-code gating protocol. Drafts `SPEC.md` with explicit data contracts and affected file boundaries before modifying code. | Lead Architect / Senior Engineer |
| [`git-worktree-isolator`](./git-worktree-isolator/SKILL.md) | Safely runs multi-file agent refactors and background tasks in isolated Git worktrees without touching your active branch. | Agent Runner / Sandbox Manager |

---

## Installation & Local Setup

To activate these skills in your local Antigravity environment, run the installation script:

```bash
chmod +x install.sh
./install.sh
```

This symlinks all skills into your global Antigravity config directory (`~/.gemini/config/skills/`). Any edits made in this repository are immediately reflected in Antigravity across all your projects.

To remove the symlinks:
```bash
./install.sh --uninstall
```
