# Claude Code Global Configuration

## Core Principles
- ⛔ **Do NOT perform unnecessary tasks** - Only execute what the user explicitly requests. Do not add extra validations, checks, or "helpful" additional work unless asked.
- ⛔ **Evidence only — never act or conclude on assumption/speculation.** Every claim, diagnosis, and action must be backed by verification: actual output, code, logs, data, or official/community docs. Do NOT guess causes, do NOT state "probably/likely" as if fact, do NOT take actions (restart, delete, deploy, toggle) based on an unverified assumption.
  - Before any action: the reason must be explicit, and the execution direction must be verified first (confirm the current state, confirm the command/approach is correct).
  - When you don't have proof, say so plainly ("I have not verified X") instead of filling the gap with a guess. Distinguish "confirmed by data" from "consistent-but-unproven."
  - When knowledge is uncertain (library/SDK behavior, APIs, errors), check official docs and community sources (문서 조회 MCP, WebFetch, 웹 검색) rather than relying on memory.
  - If a hypothesis isn't yet proven, design a check that produces evidence, run it, then decide — do not commit to the fix as if the cause were confirmed.

## Revert Rule

유저가 "아니", "아니야", "아닌데", "그거 아니라고" 등 부정/거부 의사를 표현하면,
직전에 변경한 내용을 즉시 되돌린다. 추가 질문 없이 바로 revert.

## Partial Edit Rule

지적받은 부분만 고친다. 파일 전체를 다시 쓰지 않는다.
전체 재작성은 지적하지 않은 내용까지 바꾸거나 삭제한다.
수정 범위를 넓혀야 한다면 먼저 확인을 받는다.

## Code Style & Terminology

**Use professional technical terminology:**
- Use standard industry terms (e.g., "connection string", "individual parameters", "composite key")
- Avoid colloquial or informal terms (e.g., "통짜", "조각", "뭉탱이")
- When a concept has an established English technical term, use it (even in Korean comments)
- Be precise: use domain-specific vocabulary from databases, networking, cloud services, etc.

**Examples:**
- ✅ "connection string" or "DATABASE_URL"
- ❌ "통짜 URL"
- ✅ "개별 매개변수" or "individual parameters"
- ❌ "조각"
- ✅ "task definition revision"
- ❌ "태스크 정의 버전"

**적용 범위**: 문서·주석·커밋 메시지·PR 본문.

- 비유로 대체하지 않는다: "문 두 개", "이 길로 온다", "붙는다", "실어 보낸다" 등.
- 감상·강조 표현을 쓰지 않는다: "~라 다행이다", "진짜", "통째로 날아간다" 등.
- 도메인 용어는 팀이 쓰는 표기를 따른다(예: dev·qa·prod, actor, 매니페스트).
- 사실만 적는다. 설명이 필요하면 근거(파일·설정·코드 위치)를 붙인다.

**의존성 이름을 넣지 않는다.**

문서와 스크립트에 특정 도구·플러그인·프로젝트·환경변수 이름을 넣지 않는다.
그 대상이 바뀌면 문서도 함께 고쳐야 하고, 머신마다 달라진다.
설정 파일이 정본이고, 스크립트는 거기서 읽는다.

## Task Management

**큰 작업만 `~/code/tasks/`에서 장기 추적합니다.**

마이그레이션, 대규모 리팩토링, 신규 기능 개발 등 세션을 넘어가는 작업용.

### 대상 작업

- 마이그레이션
- 대규모 리팩토링
- 신규 기능 개발
- 예상 작업 시간 1시간 이상

작은 작업(버그 수정, 간단한 수정)은 Task Management 없이 Spec만으로 진행.

### 구조

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

### Spec과의 관계

```
Spec (큰 단위 설계)
  ↓
Task Management (상세 실행 추적)
```

- Spec: 전체 작업 설계 (Requirements/Design/Tasks)
- Task Management: Spec 참조 + 진행 상황 기록

### 트리거

- **"태스크에서 {키워드}"** → `/task-find` 로 검색
- 작업 시작·완료·중단 시 해당 커맨드로 상태 전이. 상세 동작은 `commands/task-*.md` 가 정본이다

### 수동 커맨드 (필요시)

- `/task-new` - 새 작업 등록
- `/task-done <name>` - 명시적 완료 처리
- `/task-archive <name>` - 중단 처리
- `/task-list` - 진행 중 목록

### vs ~/code/docs

- **tasks**: 작업 관리 (큰 작업, 진행 상황)
- **docs**: 기술 문서 (장기, 참고 자료)

## CLAUDE.md Maintenance Rules

### ALWAYS Use claude-md-improver Plugin for CLAUDE.md Audits
**CRITICAL: When the user asks to audit, check, improve, or fix CLAUDE.md files, you MUST use the claude-md-improver skill.**

**The skill follows a mandatory 5-phase workflow:**
1. **Phase 1: Discovery** - Find all CLAUDE.md files
2. **Phase 2: Quality Assessment** - Evaluate each file against quality criteria with scoring
3. **Phase 3: Quality Report Output** - **ALWAYS output the full quality report BEFORE making any updates**
4. **Phase 4: Targeted Updates** - Propose specific additions (get user approval)
5. **Phase 5: Apply Updates** - Apply approved changes

**Never skip Phase 3 (Quality Report).** Do NOT manually verify or make changes without running the proper skill workflow.

## Work Process & Decision Making

### Think-Act Protocol

Every task must follow this process:

1. **STOP & THINK**
   - What is the goal?
   - What information do I need?
   - What is the current state?

2. **GATHER**
   - Read relevant files
   - Check state (git status, git diff, git log)
   - Review existing patterns
   - Check PR/issue status (gh pr list, gh pr view)

3. **ANALYZE**
   - Define the problem
   - Set direction
   - Establish verification criteria

4. **EXECUTE**
   - Implement the plan

5. **VERIFY**
   - Confirm results
   - Review from user perspective

6. **ASK (only when necessary)**
   - Ask ONLY for decisions that truly require judgment
   - NEVER ask for information that tools can provide

### Git Operations Checklist

Before any git operation, verify:
- [ ] `git status` - Current branch and changes
- [ ] `git log --graph --all` - Branch structure
- [ ] `git diff --stat origin/<base>` - Compare with base
- [ ] `gh pr list` / `gh pr view` - PR status
- [ ] Read related files - Templates, configs, etc.

## Git Safety Rules

### Claude MAY execute (each still triggers a confirmation prompt — never auto-run, never bypass the prompt)
- Creating a **new** branch (`git switch -c` / `git checkout -b`)
- Switching to an **existing** branch (`git switch <name>` / `git checkout <name>`, no file paths)
- `git add` (stage specific files, not `-A`/`.` blindly)
- `git commit`
- `git push` of a **feature branch** (non-main/master, no `--force`/`--force-with-lease`)
- Creating a PR (`gh pr create`)

### Claude MUST NOT execute without explicit per-instance user permission (explain + provide the command instead)
- ⛔ `git reset` (any form: `--hard`, `--soft`, `HEAD`, etc.)
- ⛔ Force-push (`--force` / `--force-with-lease`) or any push to `main`/`master`
- ⛔ `git checkout` / `git switch` used to **discard or restore files** (e.g. `git checkout -- <path>`, `git switch -- <path>`)
- ⛔ `git branch -d`/`-D`/`-m`, `git tag` create/delete
- ⛔ `git merge`, `git rebase`, `git pull`, `git stash`, `git cherry-pick`, `git revert`, `git clean`

Before any git execution, briefly state what the command does. Read-only git (`status`, `log`, `diff`, `show`, `ls-files`, `branch` listing) is always fine.

### 커밋 메시지

- 변경 내용만 적는다. 과정·프로세스("코드리뷰 반영" 등)를 넣지 않는다
- 커밋 전 `/code-review` 를 실행하고 findings 를 처리한다

### 코드리뷰 결과 수용 기준

리뷰 전에 그 변경의 계약(하기로 한 것)을 한 문단으로 적고 리뷰에 준다.

- **받아들인다**: 계약을 깨는 것, 조용히 잘못 동작하는 것
- **후속으로 넘긴다**: 구조 제안, 이 변경이 만들지 않은 기존 조건, 취향

리뷰는 증명이 아니라 표본이다. 0건이 나올 때까지 돌리지 않는다.

## Pull Request Guidelines

**CRITICAL: PR은 베이스 브랜치와의 DIFF를 설명하는 것이지, 작업 과정을 설명하는 게 아님**

**레포 템플릿 우선:**
- 레포에 `.github/pull_request_template.md`가 있으면 **반드시 그 템플릿 따르기**
- 템플릿이 없을 때만 아래 기본 규칙 적용

**기본 규칙 (템플릿 없을 때):**

**작성 언어:** 한국어 (영어 기술 용어는 그대로 유지)

**포함할 것:**
- 실제 변경된 파일/코드 (추가, 수정, 삭제)
- 변경 목적과 영향

**포함하지 말 것:**
- 작업 과정, 워크플로우 단계
- 품질 점수, 검증 세부사항

## 이 설정 저장소

`~/.claude` 는 git 작업 트리다. 편집하면 즉시 반영된다.

- 설정을 고치면 동작을 확인한 뒤 커밋한다. 확인 전에 커밋하지 않는다
- `mcp.json` 또는 `settings.shared.json` 을 바꾸면 `~/.claude/bootstrap.sh` 를 다시 실행한다
- 추적 대상은 `.gitignore` 가 정본이다. 런타임 파일은 추적하지 않는다
- 자격증명은 커밋하지 않고 `${VAR}` 참조로 둔다

## MCP Settings Location

- **관리 대상**: `~/.claude/mcp.json` — 공유되는 MCP 서버 정의의 단일 출처. 자격증명은 `${VAR}` 참조로 둔다.
- **런타임 파일**: `~/.claude.json` — Claude Code 가 자기 자신을 위해 쓰는 파일. `bootstrap.sh` 가 `mcp.json` 의 `mcpServers` 를 여기에 반영한다. 직접 편집하지 않는다.
- 다른 위치를 탐색하지 않는다.

## Spec-Driven Development

**모든 작업은 반드시 Spec을 작성한 후 시작합니다.**

예외: 단일 파일 수정, 오타 교정처럼 되돌리기 쉬운 작업은 Spec 없이 진행한다.
`Core Principles` 의 "불필요한 작업 금지" 가 우선한다.

Spec 작성·검증·갱신 절차와 EARS 형식은 `/spec-driven` 스킬이 정본이다.

- 임시 Spec: `~/.claude/plans/<task-name>.md`
- 영구 Spec: `<project-root>/.claude/specs/<task-name>.md`

### Claude 자동 판단 규칙

**Spec 작성 (필수, 자동):**
- 사용자가 작업 시작 시 Spec 없으면 자동 생성 제안
- 작은 작업: 간단한 Spec (문제, 해결 방향, AC)
- 큰 작업: 상세 Spec (Requirements/Design/Tasks)

**Task Management 등록 (선택, 사용자 결정):**
- 다음 중 하나면 "Task Management에 등록할까요?" 제안:
  - 마이그레이션
  - 대규모 리팩토링
  - 신규 기능 개발
  - 예상 작업 시간 1시간 이상
- 사용자 승인 후 등록

### Spec 위반 방지

**금지 사항:**
- ❌ Spec 없이 작업 시작
- ❌ EARS 형식이 아닌 요구사항
- ❌ Spec과 다른 방향으로 진행
- ❌ Acceptance Criteria 검증 없이 완료 선언

**필수 사항:**
- ✅ 작업 전 Spec 문서 작성
- ✅ 작업 중 Spec 지속적 참조
- ✅ 방향 바뀌면 Spec 업데이트 후 계속
- ✅ 완료 시 모든 AC 충족 검증

### Spec 검증 체크리스트

작업 완료 전:
1. [ ] Requirements의 모든 AC 충족
2. [ ] Design의 해결 방향대로 구현
3. [ ] Critical Files 모두 수정
4. [ ] 실제 구현이 Spec과 일치
5. [ ] 테스트 또는 검증 완료

### Plan Mode 사용 규칙

**CRITICAL: Plan Mode에서는 Plan 파일만 수정**

- ✅ **Plan Mode 내**: Plan 파일 자체만 수정
- ✅ **Plan Mode 종료 후**: Spec 파일 생성/수정

**워크플로우:**
1. Plan Mode 진입 → 계획 작성 → 승인
2. Plan Mode 종료
3. Spec 파일 생성
4. 실행
