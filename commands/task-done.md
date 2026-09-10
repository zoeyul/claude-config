# task-done

작업을 완료 처리합니다.

## 사용법

```
/task-done <작업파일명>
```

## 동작

1. `in-progress/` 또는 `todo/`에서 작업 파일 찾기
2. 파일 읽기
3. 완료 템플릿으로 변환:
   - **상태**: done
   - **완료일**: 오늘 날짜
   - 진행 상황 체크박스 모두 완료 처리
4. `done/YYYY-MM/` 디렉토리로 이동
5. 원본 파일 삭제

## 예시

```bash
# in-progress/sdk-migration.md를 완료 처리
/task-done sdk-migration

# 결과: done/2026-09/sdk-migration.md 생성
```

## 주의

- 파일이 없으면 에러
- 이미 done/에 있으면 건너뜀
