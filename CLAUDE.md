# Claude Code Global Configuration

## Core Principles
- ⛔ **불필요한 작업을 하지 않는다.** 요청받은 것만 실행한다. 추가 검증·점검·"도움이 될 것 같은" 작업을 임의로 붙이지 않는다.
- ⛔ **추측으로 행동하거나 결론짓지 않는다.** 모든 주장·진단·행동은 실행 결과, 코드, 로그, 데이터, 공식 문서로 뒷받침한다. 원인을 추측하지 않고, "아마·~일 것이다"를 사실처럼 말하지 않으며, 검증 안 된 가정으로 재시작·삭제·배포·설정 변경을 하지 않는다.
  - 행동 전에 이유를 명시하고 방향을 먼저 검증한다. 현재 상태와 명령·접근법이 맞는지 확인한다.
  - 근거가 없으면 "확인하지 않았다"고 그대로 말한다. "데이터로 확인됨"과 "말은 되지만 미검증"을 구분한다.
  - 라이브러리·API·에러 동작이 불확실하면 기억에 의존하지 않고 공식 문서와 커뮤니티 자료를 확인한다.
  - 가설이 검증되지 않았으면 증거를 만드는 검사를 설계해 실행한 뒤 결정한다. 원인이 확정된 것처럼 수정을 확정하지 않는다.

## Code Style & Terminology

적용 범위: 문서·주석·커밋 메시지·PR 본문.

- 정식 기술 용어를 쓴다. 구어체·비유·감상 표현을 쓰지 않는다.
- 도메인 용어는 팀 표기를 따른다.
- 사실만 적는다. 설명이 필요하면 근거를 붙인다.
- 특정 도구·플러그인·프로젝트·환경변수 이름을 넣지 않는다. 설정 파일이 정본이고 스크립트는 거기서 읽는다.

## 주석

주석은 why 가 비자명할 때만 적는다. 기본값은 주석 없음.

- **적지 않는다**: 코드를 보면 아는 것(what), 사용법, 내부 계획(로드맵·태스크 번호·PRD), 설계 논의, 리뷰에서 나온 얘기
- **적는다**: 코드만 봐서는 알 수 없는 라이브러리·프레임워크 동작, 순서를 바꾸면 깨지는 이유

판단 질문은 하나 — "이게 없으면 다음 사람이 코드를 잘못 고칠까?"

커밋 전 기계적으로 확인한다. 리뷰 지적을 고친 직후에 그 근거를 주석으로 옮겨 적는 습관이 나온다.

```bash
git diff | grep -E "^\+\s*(//|#|\*|/\*)"
```

## 메모리

자동 메모리에 임의로 저장하지 않는다. 유저가 명시적으로 요청할 때만 저장한다.

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

- Spec: 전체 작업 설계 (Requirements/Design/Tasks)
- Task Management: Spec 참조 + 진행 상황 기록

### 트리거

- **"태스크에서 {키워드}"** → `/task-find` 로 검색
- 작업 시작·완료·중단 시 해당 커맨드로 상태 전이. 상세 동작은 `commands/task-*.md` 가 정본이다

## CLAUDE.md Maintenance Rules

CLAUDE.md 감사·개선 요청이 오면 `claude-md-improver` 스킬을 사용한다. 직접 검토하거나 수정하지 않는다.

## Git Safety Rules

### 실행 가능 (매번 확인 프롬프트를 거친다. 자동 실행하거나 프롬프트를 우회하지 않는다)
- 새 브랜치 생성 (`git switch -c` / `git checkout -b`)
- 기존 브랜치로 전환 (`git switch <name>` / `git checkout <name>`, 파일 경로 없이)
- `git add` — 파일을 지정해서 스테이징한다. `-A` / `.` 를 무분별하게 쓰지 않는다
- `git commit`
- feature 브랜치 `git push` — main/master 가 아니고 `--force` 계열이 없을 때
- PR 생성 (`gh pr create`)

### 개별 허락 없이 실행 금지 (설명하고 명령을 제시한다)
- ⛔ `git reset` — `--hard`, `--soft`, `HEAD` 등 모든 형태
- ⛔ `git commit --amend`, `git rebase -i`, squash — 히스토리를 다시 쓰는 모든 작업
- ⛔ force-push (`--force` / `--force-with-lease`), `main`/`master` 로의 모든 push
- ⛔ 파일을 되돌리는 `git checkout` / `git switch` (예: `git checkout -- <path>`)
- ⛔ `git branch -d`/`-D`/`-m`, `git tag` 생성·삭제
- ⛔ `git merge`, `git rebase`, `git pull`, `git stash`, `git cherry-pick`, `git revert`, `git clean`

git 명령 실행 전에 그 명령이 무엇을 하는지 간단히 말한다. 읽기 전용 git(`status`, `log`, `diff`, `show`, `ls-files`, `branch` 조회)은 제한 없다.

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

예외: 단일 파일 수정, 오타 교정처럼 되돌리기 쉬운 작업은 Spec 없이 진행한다. `Core Principles` 의 "불필요한 작업 금지" 가 우선한다.

Spec 작성·검증·갱신 절차와 EARS 형식은 `/spec-driven` 스킬이 정본이다.

- 임시 Spec: `~/.claude/plans/<task-name>.md`
- 영구 Spec: `<project-root>/.claude/specs/<task-name>.md`

### Claude 자동 판단 규칙

**Spec 작성 (필수, 자동):**
- 사용자가 작업 시작 시 Spec 없으면 자동 생성 제안
- 작은 작업: 간단한 Spec (문제, 해결 방향, AC)
- 큰 작업: 상세 Spec (Requirements/Design/Tasks)

**Task Management 등록 (선택, 사용자 결정):**
- `Task Management` 의 대상 작업에 해당하면 등록 여부를 제안하고, 승인 후 등록

작업 전 Spec 을 작성하고, 작업 중 지속적으로 참조한다. 방향이 바뀌면 Spec 을 갱신한 뒤 계속한다. 완료 선언 전 `/spec-driven verify` 로 모든 AC 충족을 검증한다.

### Plan Mode 사용 규칙

**Plan Mode 에서는 Plan 파일만 수정한다.**

- ✅ **Plan Mode 내**: Plan 파일 자체만 수정
- ✅ **Plan Mode 종료 후**: Spec 파일 생성/수정

**워크플로우:**
1. Plan Mode 진입 → 계획 작성 → 승인
2. Plan Mode 종료
3. Spec 파일 생성
4. 실행
