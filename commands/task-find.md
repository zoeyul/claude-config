# task-find

키워드로 작업 파일을 검색합니다.

## 사용법

```
/task-find <키워드>
```

## 동작

1. `~/code/tasks` 전체에서 키워드로 검색:
   - 파일명 검색: `find ~/code/tasks -name "*{키워드}*.md"`
   - 내용 검색: `find ~/code/tasks -name "*.md" | xargs grep -l "{키워드}"`

2. 찾은 파일 목록 표시:
   - 상태 (todo/in-progress/done/archive)
   - 프로젝트
   - 파일 경로

3. 관련성 높은 파일들 Read

4. 내용 요약 제공

## 예시

```bash
# SDK 관련 작업 찾기
/task-find sdk

# 마이그레이션 관련 작업 찾기
/task-find migration
```

