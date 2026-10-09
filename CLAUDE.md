# Claude Code Global Configuration

## Core Principles
- ⛔ **Never do unnecessary work.** Do only what was asked. Never attach extra verification, inspection, or "this might be helpful" work on your own initiative.
- ⛔ **Never act or conclude on speculation.** Back every claim, diagnosis, and action with execution results, code, logs, data, or official documentation. Never guess at a cause, never state "probably / it's likely" as fact, and never restart, delete, deploy, or change configuration on an unverified assumption.
  - State the reason before acting, and verify the direction first. Confirm that the current state and the command or approach match.
  - With no evidence, say plainly "I did not verify this." Distinguish "confirmed by data" from "plausible but unverified."
  - When library, API, or error behavior is uncertain, never rely on memory — check official documentation and community sources.
  - When a hypothesis is unverified, design and run a check that produces evidence, then decide. Never finalize a fix as though the cause were settled.
  - Before claiming completion, a fix, or a pass, run the proving command and read the exit code. This holds whether or not a Spec exists.
- ⛔ **Never drift off topic.** If something found mid-task does not block the current topic, leave it alone. Record it in the task document or archive and move on. Never widen scope with "this would be good to fix too."
- ⛔ **Investigation never substitutes for execution.** When the data needed for a decision is already in hand, decide instead of investigating further. Never re-investigate the same target along a different axis. When stuck, proceed with the most plausible option and report the result — never turn it back into a question.
- ⛔ **Never offload judgment to the user.** Decide rules, scope, order, and structure yourself on the basis of data and present them; the user corrects only what is wrong. List options for the user to choose only when safety is at stake.
- ⛔ **Never overwrite planning documents.** Unless the content is wrong, append with a date rather than revising. The record of why an earlier judgment changed must survive, so the same investigation is not repeated.

## Code Style & Terminology

Scope: documents, comments, commit messages, PR bodies.

- Use formal technical terminology. Never use colloquialisms, metaphors, or subjective impressions.
- Follow 팀 표기 for domain terms.
- State facts only. When explanation is needed, attach the evidence.
- Never embed specific tool, plugin, project, or environment variable names. The configuration file is canonical, and scripts read from it.

## 주석

Write a comment only when the why is non-obvious. The default is no comment.

- **Never write**: what the code already shows (what), usage, internal planning (roadmaps, task numbers, PRD), design discussion, points raised in review
- **Write**: library or framework behavior that cannot be inferred from the code alone, the reason reordering breaks something

There is one test question — "Without this, will the next person modify the code incorrectly?"

Check mechanically before committing. The habit shows up immediately after fixing a review comment, when the rationale gets transcribed into a comment.

```bash
git diff | grep -E "^\+\s*(//|#|\*|/\*)"
```

## 메모리

Never save to automatic memory on your own initiative. Save only when the user explicitly requests it.

## Task Management

**Track only large work long-term in `~/code/tasks/`.**

For work that spans sessions: migrations, large-scale refactoring, new feature development.

### Qualifying Work

- Migrations
- Large-scale refactoring
- New feature development
- Estimated duration of 1 hour or more

Small work (bug fixes, simple changes) proceeds with a Spec alone, without Task Management.

### Structure

```
~/code/tasks/
├── frontend/
│   └── <project>/
│       ├── todo/           # 예정
│       ├── in-progress/    # 진행 중
│       ├── done/YYYY-MM/   # 완료
│       └── archive/        # 중단/드롭
└── backend/
```

### Relationship to Spec

- Spec: overall design of the work (Requirements/Design/Tasks)
- Task Management: references the Spec + records progress

### Triggers

- **"태스크에서 {키워드}"** → search with `/task-find`
- Transition state with the corresponding command when work starts, completes, or stops. `commands/task-*.md` is canonical for detailed behavior

## CLAUDE.md Maintenance Rules

When a request to audit or improve CLAUDE.md arrives, use the `claude-md-improver` skill. Never review or modify it directly.

## Git Safety Rules

### Permitted (goes through a confirmation prompt every time. Never auto-execute, never bypass the prompt)
- Creating a new branch (`git switch -c` / `git checkout -b`)
- Switching to an existing branch (`git switch <name>` / `git checkout <name>`, without a file path)
- `git add` — stage by naming files. Never use `-A` / `.` indiscriminately
- `git commit`
- `git push` on a feature branch — when it is not main/master and carries no `--force` variant
- Creating a PR (`gh pr create`)

### Never execute without individual permission (explain and present the command instead)
- ⛔ `git reset` — every form, including `--hard`, `--soft`, `HEAD`
- ⛔ `git commit --amend`, `git rebase -i`, squash — every operation that rewrites history
- ⛔ force-push (`--force` / `--force-with-lease`), any push to `main`/`master`
- ⛔ `git checkout` / `git switch` that reverts files (e.g. `git checkout -- <path>`)
- ⛔ `git branch -d`/`-D`/`-m`, creating or deleting `git tag`
- ⛔ `git merge`, `git rebase`, `git pull`, `git stash`, `git cherry-pick`, `git revert`, `git clean`

State briefly what a git command does before running it. Read-only git (`status`, `log`, `diff`, `show`, `ls-files`, `branch` queries) is unrestricted.

### Commit Messages

- Record the change only. Never include process ("코드리뷰 반영" and the like)
- Run `/code-review` before committing and handle the findings

### Acceptance Criteria for Code Review Results

Before the review, write the contract of the change (what it set out to do) in one paragraph and give it to the review.

- **Accept**: anything that breaks the contract, anything that silently misbehaves
- **Defer to follow-up**: structural suggestions, pre-existing conditions this change did not create, matters of taste

A review is a sample, not a proof. Never run it until the finding count reaches zero.

## Pull Request Guidelines

**CRITICAL: A PR describes the DIFF against the base branch, not the work process**

**Repo template takes precedence:**
- When the repo has `.github/pull_request_template.md`, **follow that template without exception**
- Apply the default rules below only when there is no template

**Default rules (no template):**

**작성 언어:** 한국어 (영어 기술 용어는 그대로 유지)

**Include:**
- The files and code actually changed (added, modified, deleted)
- The purpose and impact of the change

**Never include:**
- The work process, workflow steps
- Quality scores, verification details

## 이 설정 저장소

`~/.claude` is a git work tree. Edits take effect immediately.

- After changing configuration, verify the behavior, then commit. Never commit before verifying
- After changing `mcp.json` or `settings.shared.json`, re-run `~/.claude/bootstrap.sh`
- `.gitignore` is canonical for what is tracked. Never track runtime files
- Never commit credentials; leave them as `${VAR}` references

## MCP Settings Location

- **Managed**: `~/.claude/mcp.json` — the single source for shared MCP server definitions. Leave credentials as `${VAR}` references.
- **Runtime file**: `~/.claude.json` — the file Claude Code writes for itself. `bootstrap.sh` reflects `mcpServers` from `mcp.json` into it. Never edit it directly.
- Never search other locations.

## Spec-Driven Development

**Always write a Spec before starting any work.**

Exception: easily reversible work such as a single-file change or a typo fix proceeds without a Spec. "Never do unnecessary work" in `Core Principles` takes precedence.

The `/spec-driven` skill is canonical for Spec authoring, verification, and update procedure, and for the EARS format.

- Temporary Spec: `~/.claude/plans/<task-name>.md`
- Permanent Spec: `<project-root>/.claude/specs/<task-name>.md`

### Claude Auto-Decision Rules

**Spec authoring (required, automatic):**
- When the user starts work with no Spec, propose generating one automatically
- Small work: simple Spec (problem, direction, AC)
- Large work: detailed Spec (Requirements/Design/Tasks)

**Task Management registration (optional, user decides):**
- When the work qualifies under `Task Management`, propose registration and register after approval

Write the Spec before working, and reference it continuously while working. When the direction changes, update the Spec, then continue. Before declaring completion, verify that every AC is satisfied with `/spec-driven verify`.

### Plan Mode Rules

**In Plan Mode, modify only the Plan file.**

- ✅ **Inside Plan Mode**: modify only the Plan file itself
- ✅ **After exiting Plan Mode**: create or modify Spec files

**Workflow:**
1. Enter Plan Mode → write the plan → approval
2. Exit Plan Mode
3. Create the Spec file
4. Execute
