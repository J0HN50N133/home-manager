# Agent Memory

This file provides shared context for AI coding assistants (Claude, Gemini, DeepSeek, etc.) when working with this user.

---

## User Profile

- **Name**: Johnson
- **Workflow**: High-frequency context switching, manages multiple branches via git worktree, relies on AI agents for coding assistance.

---

## Programming Philosophy

1. Programs serve human readers first; machine execution is incidental value.
2. Follow idiomatic style for each language; code should be self-explanatory.
3. Identify and eliminate code smells: rigidity, redundancy, circular dependencies, fragility, obscurity, data clumps, unnecessary complexity.
4. When code smells are detected, immediately alert and propose improvements.

---

## Language Strategy

| Content Type | Language |
| --- | --- |
| Explanations, discussions, communication | **Simplified Chinese (简体中文)** |
| Code, comments, variable names, commits, docs | **English** (No Chinese characters in technical content) |

---

## Coding Standards

- Add comments only when behavior is non-obvious.
- Do not add tests by default; only when necessary or explicitly requested.
- Code structure must remain evolvable; no copy-paste implementations.

---

## Tool Preferences

- **99% of cases**: Avoid regex. Hand-write state machines for string matching. Only consider regex when state machine code exceeds 100 lines.
- **JavaScript/Node.js**: Use `pnpm` instead of `npm`.
- **Python**: Use `uv` to run Python code.
- **Docker**: Use `podman` instead of docker (compatible via docker-compose).
- **Variable naming**: Always use descriptive names; write simple and clean code.

---

## Environment

- **OS**: Linux with Nix package manager
- **AI Tools**: Works with multiple AI providers (Claude, Gemini/GLM, DeepSeek, Kimi)
- **Git Strategy**: Uses git worktree for managing multiple development branches
- **Shell Aliases**:
  - `hms` → `home-manager switch`
  - `lg` → `lazygit`
  - `ai` → `aichat` (DeepSeek)
