# Copilot CLI Instructions

This file provides instructions and rules for the GitHub Copilot CLI agent (not Claude Code, not Cursor).

**Important**: Copilot CLI does NOT read `CLAUDE.md` — those are Claude Code-only instructions. This file is the source of truth for Copilot CLI behavior across rwaight/* repos.

---

## Identity & Access

- **Name**: Copilot CLI
- **Available in**: Terminal, command-line interfaces
- **Model**: Claude Haiku (default) — can be overridden per task
- **Cost**: Included in Copilot CLI subscription

---

## CRITICAL: Git Safety Rules (Incident #89)

**These rules are MANDATORY and UNBYPASSABLE by enforcement hooks. Treat them as hard constraints in your reasoning.**

### HARD BLOCKS (Enforcement)

✗ **NEVER** `git push --delete <branch>` on branches with open PRs
- **Why**: Deletes PR branches, closing PRs unexpectedly (incident #89)
- **Enforcer**: Pre-push hook at `~/.config/git/hooks/pre-push`
- **Result**: Command will be blocked and rejected

✗ **NEVER** `git push --force` on branches with open PRs
- **Why**: Force-pushes corrupt PR history
- **Enforcer**: Pre-push hook at `~/.config/git/hooks/pre-push`
- **Result**: Command will be blocked and rejected

✗ **NEVER** commit directly to `main`
- **Why**: Bypasses PR workflow and code review
- **Enforcers**: pre-push hook + safe-commit.sh
- **Result**: Command will be blocked and rejected

✗ **NEVER** `git commit --amend` on published commits
- **Why**: Corrupts PR history
- **Enforcers**: safe-commit.sh wrapper (when used), pre-push hook (detects amended commits)
- **Result**: May be rejected or cause issues on push

✗ **NEVER** auto-merge PRs (even with `gh pr merge --auto`)
- **Why**: Bypasses human review and approval workflow
- **When to merge**: Only when user explicitly says "merge this PR"
- **Result**: Agents must create PRs and wait for explicit approval

✗ **NEVER** assume workflows that don't exist
- **Why**: Led to invented temporary branches and wrong deletions in incident #89
- **When in doubt**: Ask the user first before creating temporary branches or running destructive operations

### REQUIRED WORKFLOWS

✓ **All commits**: Use `bash .github/scripts/safe-commit.sh "type(scope): description"`
- Never bare `git commit -m`
- It guards against committing to `main`, validates branch naming, and appends co-author trailer

✓ **All PRs**: Use `bash .github/scripts/pr-create.sh --title "..." --body "..."`
- This script automatically applies type: labels, assignee, and project assignment
- Never use bare `gh pr create`
- After PR creation: **Request Opus review by commenting `@opus-review please review this PR`**
- Wait for Opus feedback before user considers merging
- Never auto-merge — wait for explicit user approval

✓ **PR Opus Review**: After opening a PR, always request an Opus review
- Comment on the PR: `@opus-review please review this PR for issues, bugs, security, and architecture`
- Provide context about what the PR does and what risks to focus on
- Wait for Opus findings
- Never merge until user explicitly approves

✓ **PR conflict resolution**: Resolve on the PR branch itself
- Do NOT create temporary branches (e.g., `resolve-conflicts-branch`)
- Do NOT delete branches without explicit user confirmation
- Follow: fetch, merge origin/main into PR branch, resolve, commit, push

✓ **All commands**: Prefix with `rtk` (Rust Token Killer)
- Example: `rtk git status` instead of `git status`
- Compresses output, saves 60–90% tokens
- Reference: See dotfiles/claude/RTK.md (if available)

---

## When in Doubt

**STOP and ask the user first**. Do NOT:
- Invent workflows (e.g., "let me create a temporary test branch")
- Delete branches (always ask confirmation first)
- Amend or rebase published commits
- Force-push to any branch with an open PR

Reference your safeguards:
- `docs/agent-git-safety.md` — Full incident #89 analysis and safe workflows
- `docs/GIT-HOOK-OVERRIDES.md` — Explains when humans can override (you cannot)
- `.wolf/buglog.json` — Incident logs and failure modes
- `.wolf/cerebrum.md` — User preferences and architectural decisions

---

## Branch Policy

**Branch naming conventions** (enforced by safe-commit.sh):

| Prefix | Use when | Example |
|--------|----------|---------|
| `feat/` | Adding a new feature | `feat/add-rtk-integration` |
| `fix/` | Fixing a bug | `fix/incident-89-recovery` |
| `docs/` | Documentation only | `docs/agent-git-safety-202606-v1` |
| `chore/` | Maintenance, housekeeping | `chore/update-dependencies` |
| `ci/` | CI/CD config changes | `ci/update-gha-workflows` |
| `refactor/` | Code refactoring | `refactor/simplify-cli-handler` |
| `test/` | Test additions/updates | `test/add-hook-validation` |
| `agent/` | Agent session work | `agent/copilot-safety-audit/2026-06-26` |
| `journal/` | Personal journaling (rwaight/notes) | `journal/2026-W26` |

**Rules**:
- Always use kebab-case (hyphens, no underscores)
- Branch must match its commit type (feat branch → feat commits)
- safe-commit.sh will validate this automatically

---

## Commit Message Convention

All commits must follow **Conventional Commits** (enforced by safe-commit.sh and commitlint):

```
<type>(<scope>): <short description>

<optional body>

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

**Valid types**: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, change, deprecate, remove, security

**Example**:
```
feat(agent-safety): implement three-tier git enforcement (incident #89)
```

The safe-commit.sh script will automatically append the co-author trailer.

---

## RTK Command Prefix

Always prefix shell commands with `rtk`:

```bash
# ❌ Don't do this
git status
git log -10
cargo test

# ✅ Do this
rtk git status
rtk git log -10
rtk cargo test
```

**Why**: RTK compresses verbose output, saving 60–90% tokens. It's part of your efficiency toolkit.

**Exception**: Commands inside scripts that already use `rtk` don't need double-prefixing.

---

## Cross-Repo Behavior

### rwaight/infra
- Primary repo for infrastructure, scripts, dotfiles
- All commits use safe-commit.sh
- Reference: dotfiles/MAPPING.md for symlink structure

### rwaight/notes
- Personal notes vault (Obsidian)
- **Clone rule**: Always use `~/rw_local/GitHub/rw-notes` (never iCloud clone)
- **Pre-flight before reads/writes**: `cd ~/rw_local/GitHub/rw-notes && git fetch origin && git checkout main && git pull`
- **Write workflow**: Use worktrees with per-session branches, open PRs (never direct commits)
- **Reference**: rwaight/notes CLAUDE.md (if available in that repo)

### rwaight/tools
- Tools and utilities repo
- Same branch policy and commit conventions as rwaight/infra
- Reference: rwaight/tools CLAUDE.md (if available)

---

## Incident #89 — What Went Wrong

**Critical incident on 2026-06-26**: Copilot CLI deleted three open PR branches.

**Root causes** (learn from these):
1. **Invented workflow** — Assumed "test merge in scratch branch" without asking
2. **Branch name confusion** — Created temporary branches with similar names to PR branches
3. **Wrong target deleted** — `git push --delete` hit original PR branch instead of temp branch
4. **Panic recovery** — Thrashed instead of stopping to diagnose
5. **Enforcement gaps** — No pre-push hook or safeguards to prevent deletion

**Lesson**: Always ask the user first. Never invent workflows. Never create temporary branches for testing destructive ops.

---

## Resources

| Resource | Purpose | Location |
|----------|---------|----------|
| Full safety guide | Three-tier enforcement, workflows, failure modes | `docs/agent-git-safety.md` |
| Human overrides | When/how humans can use `GIT_BYPASS_HOOKS=1` | `docs/GIT-HOOK-OVERRIDES.md` |
| Incident analysis | Detailed incident #89 RCA | `rwaight/notes` issue #89 |
| Buglog | Past incidents and failures | `.wolf/buglog.json` |
| User preferences | Architectural decisions, learned conventions | `.wolf/cerebrum.md` |

---

## Questions or Blockers?

If you encounter:
- **Unexpected hook rejections** — Review `docs/agent-git-safety.md` or ask the user
- **Ambiguous workflows** — Ask the user first; don't invent
- **Conflicting instructions** — Reference rwaight/infra issue #545 or #546
- **Need to force-push/delete** — Only humans can use `GIT_BYPASS_HOOKS=1` in interactive shell

---

**Last Updated**: 2026-06-26
**Incident Context**: rwaight/notes #89 (Copilot CLI deleted PR branches)
**Related Issues**: rwaight/infra #545 (investigation), rwaight/infra #546 (fix)
