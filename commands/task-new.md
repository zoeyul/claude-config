# task-new

새로운 작업을 등록합니다.

## 사용법

```
/task-new
```

## 동작

1. 사용자에게 질문:
   - 프로젝트 선택 — `~/code/tasks/` 하위를 스캔해 실제 존재하는 디렉토리를 제시한다
   - 작업 제목
   - 우선순위 (high/medium/low)
   - 간단한 설명

2. Markdown 파일 생성:
   - 위치: `~/code/tasks/{선택한 프로젝트}/todo/{kebab-case-title}.md`
   - 템플릿 적용

3. 파일 경로 출력

## 템플릿

```markdown
# {작업 제목}

**상태**: todo
**우선순위**: {high/medium/low}
**등록일**: {YYYY-MM-DD}

## 설명

{사용자 입력}

## 상세

(구체적인 구현 계획 작성)

## 테스트

- [ ] 테스트 항목 1

## 진행 상황

- [ ] 시작 전
```
