# 볼트

Obsidian 볼트 경로: `/Users/seoyul/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian`

먼저 그 폴더의 `CLAUDE.md`를 읽고, 거기 적힌 규칙을 이 작업에 그대로 적용한다.

- `$ARGUMENTS` 가 있으면 그것을 볼트에 던진 것으로 보고 "던진 것을 처리하는 순서"를 따른다
- `$ARGUMENTS` 가 비어 있으면 "일괄 처리" 절을 따라 `Clippings/` 와 `Inbox/` 를 정리한다

파일 경로는 항상 위 볼트 경로 기준 절대경로로 다룬다. 현재 작업 디렉토리와 무관하게 동작해야 한다.
