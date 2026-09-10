---
name: spec-driven
description: Kiro 방식 Spec-Driven Development 워크플로우 (start/verify/update/status)
---

# Spec-Driven Development

이 skill은 Kiro 방식의 Spec-Driven Development를 지원합니다.

## 사용법

- `/spec-driven start` - 새 Spec 생성
- `/spec-driven verify` - 현재 작업 검증
- `/spec-driven update` - Spec 업데이트
- `/spec-driven status` - 진행 상황 확인

인자 없이 `/spec-driven` 호출 시 사용법 출력.

---

## start - 새 Spec 생성

### 입력 받기
1. **작업 이름** (kebab-case 권장)
2. **작업 설명** (무엇을, 왜)
3. **저장 위치** (글로벌: `~/.claude/plans/`, 프로젝트: `.claude/specs/`)

### Spec 파일 구조

```markdown
# <작업 이름>

## Requirements

### User Story
<역할>로서, <목표>를 달성하고 싶다. <이유>.

---

### Requirement 1: <제목>

#### Acceptance Criteria

1. WHEN [조건] THEN THE SYSTEM SHALL [동작]
2. WHERE [컨텍스트] THE SYSTEM SHALL [동작]
3. IF [조건] THEN THE SYSTEM SHALL [동작]

#### Additional Details
- **Priority**: High/Medium/Low
- **Complexity**: High/Medium/Low
- **Dependencies**: <의존성>
- **Assumptions**: <가정>

---

## Design

### 현재 상태 분석
<문제점, 기존 구조>

### 기술적 접근
<선택한 방식과 이유>

### Critical Files
- **수정 대상**: `<경로>` - <내용>
- **생성 대상**: `<경로>` - <내용>
- **삭제 대상**: `<경로>` - <이유>
- **검증 대상**: `<경로>` - <방법>

---

## Tasks

### Task 1: <제목>
**Status**: TODO  
**Dependencies**: None  
**Requirement**: Requirement 1 (AC1, AC2)

#### Subtasks
- [ ] <작업 1>
- [ ] <작업 2>

---

### Task 2: <제목>
...

---

## Progress Tracking

- **Total Tasks**: <숫자>
- **Completed**: 0
- **In Progress**: 0
- **TODO**: <숫자>

### Critical Path
1. Task X - <핵심 경로>
```

### EARS 형식 예시

**WHEN** - 이벤트 발생 시:
```
WHEN 사용자가 로그인 버튼을 클릭할 때 THEN THE SYSTEM SHALL 인증 API를 호출해야 함
```

**WHERE** - 컨텍스트:
```
WHERE 설정 파일이 credential을 포함할 때 THE SYSTEM SHALL 환경변수로 분리해야 함
```

**IF** - 조건:
```
IF 환경변수가 설정되지 않았을 때 THEN THE SYSTEM SHALL 오류 메시지를 출력해야 함
```

**WHILE** - 진행 중:
```
WHILE 데이터 동기화가 진행 중일 때 THE SYSTEM SHALL 진행률을 표시해야 함
```

### 실행 후
- Spec 파일 저장
- 요약 출력
- 다음 단계 안내 (Design → Tasks → 실행)

---

## verify - Spec 검증

### 1. Spec 로드
- `~/.claude/plans/` 또는 `.claude/specs/`에서 최신 Spec 찾기
- 사용자가 파일 지정하면 그것 사용

### 2. Requirements 검증

각 Acceptance Criteria에 대해:
- **충족 여부** 확인 (✅/❌/⏳)
- **근거** 제시 (파일, 명령 결과)
- **관련 파일** 명시

**예시:**
```
AC1: WHEN credential을 제외한 설정 파일이 Git 레포에 있을 때...

검증:
✅ 충족
- git ls-files로 확인: CLAUDE.md, commands/, .claude.json 존재
- .gitignore 확인: credential 파일 제외됨
```

### 3. Critical Files 검증

```bash
# 수정 대상 확인
git status | grep modified
git diff --name-only

# 생성 대상 확인
ls <파일>

# 예상 외 변경 감지
git status --short
```

**보고:**
- ✅ 수정됨: `<파일>` - <내용>
- ❌ 미수정: `<파일>` - 아직 작업 안 됨
- ⚠️ 예상 외: `<파일>` - Spec에 없음

### 4. Tasks 진행 상황

```
완료 (2/5):
- ✅ Task 1: ...
- ✅ Task 2: ...

진행 중 (1/5):
- ⏳ Task 3: ...

미완료 (2/5):
- ❌ Task 4: ...
- ❌ Task 5: ...
```

### 5. 위반 사항 요약

```
🚨 Spec 위반

Critical:
- ❌ AC3 미충족: setup.sh에 skills 링크 없음
- ❌ 누락된 파일: settings.json

Warning:
- ⚠️ 예상 외 변경: test.md

권장 사항:
1. setup.sh 수정
2. settings.json 추가
3. test.md를 Spec에 추가하거나 삭제
```

---

## update - Spec 업데이트

### 1. 변경 사항 확인
- 무엇이 바뀌었는지
- 왜 바뀌었는지

### 2. Requirements 업데이트
- 새 AC 추가
- 기존 AC 수정
- 불필요한 AC 삭제

### 3. Design 영향도 분석
- Critical Files 업데이트
- 기술적 접근 방식 수정

### 4. Tasks 동기화

**새 AC 추가** → 새 Task 생성:
```markdown
### Task N: <새 AC 구현>
**Requirement**: Requirement X (ACN)
```

**AC 삭제** → 해당 Task 제거

**AC 수정** → Task Subtasks 업데이트

### 5. Git 커밋
```bash
git add <spec-file>
git commit -m "spec: <변경 내용>"
```

---

## status - 진행 상황

### 1. Requirements 상태

```
Requirement 1: 설정 파일 공유
├─ AC1: ✅ 충족
├─ AC2: ✅ 충족
├─ AC3: ⏳ 진행 중
└─ AC4: ❌ 미충족

Requirement 2: 심볼릭 링크
├─ AC1: ✅ 충족
└─ AC2: ❌ 미충족
```

### 2. Critical Files 상태

```
수정 대상 (2/3):
✅ ~/.claude/CLAUDE.md
✅ ~/code/claude-config/setup.sh
❌ ~/code/claude-config/README.md

생성 대상 (1/2):
✅ ~/.claude/skills/spec-driven.md
❌ ~/code/claude-config/settings.json
```

### 3. Tasks 진행률

```
전체: 10개
완료: 3개 (30%)
진행 중: 2개 (20%)
미완료: 5개 (50%)

현재 작업: Task 4 - setup.sh 업데이트
다음 작업: Task 5 - README.md 재작성
```

### 4. 예상 완료 시점

```
Critical Path:
Task 1 (완료) → Task 3 (진행 중) → Task 5 (대기) → Task 8 (대기)

예상 남은 작업: 5개
현재 속도: 1 task/10분
예상 완료: ~50분 후
```

---

## 주의사항

### EARS 형식 필수
- "SHALL" 키워드 반드시 포함
- 조건부(WHEN/WHERE/IF/WHILE) 명시
- 측정 가능한 기준

### 추적성 유지
- Tasks는 Requirement AC와 연결
- Requirement 번호 + AC 번호 명시

### 근거 명시
- "충족" 또는 "미충족"만이 아니라
- **어떤 파일/명령으로 확인했는지** 명시

### 예상 외 변경 주의
- Spec에 없는 변경은 경고
- 의도적이면 Spec 업데이트 권장
- 자동 생성 파일(node_modules 등) 무시
