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

### 작업 파일 내용

```markdown
# <task-name>.md

## Spec
~/.claude/plans/<task-name>.md 참조

## 진행 상황
- [x] Task 1: 의존성 업데이트 (커밋: abc123)
- [ ] Task 2: 네이티브 빌드 테스트
- [ ] Task 3: QA 검증

## 메모
- Gradle 8.0 필요 (공식 문서 틀림)
- iOS 빌드는 문제없음
```

### Spec과의 관계

```
Spec (큰 단위 설계)
  ↓
Task Management (상세 실행 추적)
```

- Spec: 전체 작업 설계 (Requirements/Design/Tasks)
- Task Management: Spec 참조 + 진행 상황 기록

### "태스크에서" 키워드 인식

사용자가 **"태스크에서 {키워드}"**라고 하면:

1. `~/code/tasks` 전체에서 키워드로 검색:
   ```bash
   find ~/code/tasks -name "*{키워드}*.md"
   find ~/code/tasks -name "*.md" | xargs grep -l "{키워드}"
   ```

2. 찾은 파일들 목록 보여주기
3. 관련성 높은 파일 Read (여러 개면 모두 읽기)
4. 상태(todo/in-progress/done/archive) 관계없이 검색
5. 내용 파악 후 응답

### 자동 업데이트 (기본)

작업 진행 중 **자동으로** 해당 작업 파일을 업데이트:

1. **작업 시작 시**:
   - `todo/` → `in-progress/`로 이동
   - **시작일** 추가

2. **진행 중**:
   - 커밋 생성 시 "진행 상황" 체크박스 업데이트
   - 주요 결정사항 "메모" 섹션에 추가

3. **작업 완료 시**:
   - `in-progress/` → `done/YYYY-MM/`로 이동
   - **상태**: done, **완료일** 추가
   - 관련 커밋 해시 추가
   - 모든 체크박스 완료 처리

4. **작업 중단 시**:
   - 사용자가 명시하면 `archive/`로 이동

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

### Terminal Environment Adaptation

Unlike IDEs, terminals lack visual context, so:

1. **Explicit exploration** - Verify everything explicitly
2. **Manual state tracking** - Make `git status`, `git log` a habit
3. **Proactive reading** - Read related files in advance
4. **Path verification** - Use find/glob instead of guessing file locations

### Self-Verification Questions

Before acting, ask yourself:
- "Can I verify this with a tool?" → Then verify
- "Do I know the base state?" → If not, git diff
- "Am I certain where the file is?" → If not, find/glob
- "Does the user already know the answer?" → Then don't ask, just verify

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

## MCP Settings Location

- **관리 대상**: `~/.claude/mcp.json` — 공유되는 MCP 서버 정의의 단일 출처. 자격증명은 `${VAR}` 참조로 둔다.
- **런타임 파일**: `~/.claude.json` — Claude Code 가 자기 자신을 위해 쓰는 파일. `bootstrap.sh` 가 `mcp.json` 의 `mcpServers` 를 여기에 반영한다. 직접 편집하지 않는다.
- 다른 위치를 탐색하지 않는다.

## Spec-Driven Development

**모든 작업은 반드시 Spec을 작성한 후 시작합니다.**

작업 방향을 잃지 않고, 계획대로 진행하기 위한 필수 원칙입니다.

### 사용자 워크플로우

**모든 작업 (크든 작든):**
1. 사용자가 작업 내용 설명하거나 "spec 작성해" 요청
2. Claude가 Spec 작성 (`~/.claude/plans/<task-name>.md`)
3. 사용자가 Spec 확인/승인 후 작업 시작
4. 작업 중 Spec 참조하여 방향 유지
5. 완료 후 Spec 삭제 (또는 `.claude/specs/`에 영구 보관)

**큰 작업만 추가로 (마이그레이션, 대규모 리팩토링, 신규 기능):**
- Claude가 "Task Management에 등록할까요?" 제안
- 또는 사용자가 "태스크 등록해" 명시
- `~/code/tasks/.../in-progress/<task-name>.md` 생성
- Spec 참조 + 진행 상황 기록
- 완료 후 `done/YYYY-MM/` 이동

### Spec 파일 구조

**단일 파일 형식:**
- 위치: `~/.claude/plans/<task-name>.md` (임시) 또는 `<project-root>/.claude/specs/<task-name>.md` (영구)

**3단계 구조:**

1. **Requirements 섹션**
   - EARS 형식으로 요구사항 작성
   - User Story + Acceptance Criteria
   - 작은 작업: 간단한 AC (1-3개)
   - 큰 작업: 상세한 AC + Additional Details

2. **Design 섹션**
   - 문제 분석
   - 해결 방향 (왜 이 방법을 선택했는지)
   - Critical Files 식별
   - 작은 작업: 간단한 접근 방법
   - 큰 작업: 기술적 접근 + 대안 비교

3. **Tasks 섹션**
   - 실행 가능한 작업 단위로 분해
   - Requirements AC와 추적성 유지
   - 작은 작업: 체크리스트 (3-5개)
   - 큰 작업: Task별 상태/의존성 명시

### EARS 형식 (필수)

모든 Acceptance Criteria는 다음 형식 중 하나를 따라야 함:
- `WHEN [조건/이벤트] THEN [시스템] SHALL [기대 동작]`
- `IF [조건/상태] THEN [시스템] SHALL [필수 동작]`
- `WHERE [컨텍스트] [시스템] SHALL [컨텍스트별 동작]`
- `WHILE [진행 중 조건] [시스템] SHALL [지속 동작]`

**예시:**
```markdown
## Requirements

### 버그: 캐러셀 스와이프 안 됨

#### Acceptance Criteria
1. WHEN 사용자가 캐러셀을 스와이프할 때 THEN THE SYSTEM SHALL 다음 아이템으로 넘어가야 함
2. WHERE reanimated-carousel v5를 사용할 때 THE SYSTEM SHALL 공식 API를 따라야 함

## Design

### 원인
reanimated-carousel v4→v5 마이그레이션 시 API 변경 미적용

### 해결 방향
1. 공식 마이그레이션 가이드 확인
2. onSnapToItem → onScrollEnd API 변경
3. 안 되면 enableMomentum 옵션 확인

### 금지
- ❌ 다른 라이브러리로 교체
- ❌ 우회 (근본 원인 해결 필수)
```

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
