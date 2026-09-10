# task-archive

작업을 중단/드롭 처리합니다.

## 사용법

```
/task-archive <작업파일명>
```

## 동작

1. `in-progress/` 또는 `todo/`에서 작업 파일 찾기
2. 파일 읽기
3. archive 템플릿으로 변환:
   - **상태**: archived
   - **중단일**: 오늘 날짜
   - **중단 사유** 섹션 추가
4. `archive/` 디렉토리로 이동
5. 원본 파일 삭제

## 예시

```bash
# in-progress/old-feature.md를 중단 처리
/task-archive old-feature

# 결과: archive/old-feature.md 생성
```

## 사용 시나리오

- 요구사항 변경으로 취소
- 우선순위 밀려서 무기한 보류
- 다른 방식으로 해결되어 불필요해짐
