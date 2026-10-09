# Claude 설정 관리

여러 컴퓨터 간 Claude Code 전역 설정을 공유하는 레포. 이 레포의 작업 트리가 곧 `~/.claude` 다.

## 구조

`~/.claude` 에는 설정과 런타임 데이터가 섞여 있다. `.gitignore` 는 **전부 제외한 뒤 추적 대상만 화이트리스트**한다. 새 런타임 디렉토리가 생겨도 자동으로 걸러진다.

### 추적 대상

| 경로 | 내용 |
|---|---|
| `CLAUDE.md` | 전역 규칙 |
| `commands/` | 커스텀 커맨드 |
| `skills/` | 커스텀 스킬 |
| `agents/`, `rules/`, `output-styles/`, `themes/` | 있으면 추적 |
| `hooks/` | 직접 작성한 훅만 |
| `keybindings.json` | 키 바인딩 |
| `mcp.json` | MCP 서버 정의 |
| `settings.shared.json` | 플러그인·effortLevel·theme |
| `bootstrap.sh` | 위 두 JSON 을 런타임 파일에 반영 |
| `bin/` | 자동 동기화 스크립트 |
| `com.zoeyul.claude-autosync.plist` | 자동 동기화 launchd 에이전트 템플릿 |

### 제외 대상

- 런타임 데이터: `projects/`, `history.jsonl`, `file-history/`, `sessions/`, `cache/`, `shell-snapshots/` 등
- `settings.json`, `settings.local.json` — Claude Code 와 외부 도구가 상시 갱신한다
- `plugins/` — 마켓플레이스에서 재설치된다
- 자격증명 (`*.key`, `*.pem`, `.credentials.json` 등)

### 공유하지 않는 것과 이유

| 항목 | 이유 |
|---|---|
| `permissions` | 승인은 신뢰 결정이다. 공유하면 다른 머신이 승인한 적 없는 명령을 자동 허용한다. Claude Code 는 기본적으로 승인을 각 프로젝트의 `.claude/settings.local.json` 에 저장한다 |
| `hooks`, `statusLine` | 이 값을 쓰는 외부 도구가 머신마다 스스로 설치한다 |
| `oauthAccount`, `userID`, `machineID`, `projects` | 계정·머신 고유 상태 |

## 새 머신 셋업

### 1. 레포를 `~/.claude` 에 붙인다

`~/.claude` 를 삭제하지 않고 그 자리에 작업 트리를 얹는다. **Claude Code 세션 밖에서 실행한다.**

```bash
cp -a ~/.claude ~/.claude.backup.$(date +%Y%m%d)

cd ~/.claude
git init
git remote add origin git@github.com:zoeyul/claude-config.git
git fetch origin
git checkout -f -b main origin/main
```

### 2. 설정 반영

```bash
~/.claude/bootstrap.sh
```

`mcp.json` 의 `mcpServers` 를 `~/.claude.json` 에 반영하고, `settings.shared.json` 을 `~/.claude/settings.json` 에 병합한다. 기존 `permissions`, `oauthAccount`, 캐시는 보존된다. 재실행해도 결과가 같다.

### 3. 환경변수

`mcp.json` 이 참조하는 환경변수를 설정한다. 미설정 시 해당 서버만 연결에 실패하고 나머지는 정상 동작한다.

### 4. 선행 조건

| 대상 | 확인 |
|---|---|
| `jq` | `bootstrap.sh` 가 사용한다. `brew install jq` |

자동 동기화에 추가 의존성은 없다. 파일 와처를 쓰지 않으므로 `fswatch` 가 필요하지 않다.

### 5. Claude Code 재시작

## 다른 머신 동기화

```bash
cd ~/.claude && git pull && ./bootstrap.sh
```

## 자동 동기화

추적 대상 파일이 바뀌면 자동으로 커밋·푸시한다. 편집 주체(Claude Code, 에디터, `git pull`)와
무관하게 동작한다.

```bash
./bootstrap.sh --with-autosync          # 설치
./bin/install-autosync.sh --uninstall   # 제거
```

기본값으로는 설치되지 않는다. 설정만 필요한 머신에서 데몬이 돌지 않게 하기 위해서다.

### 동작

launchd 가 120초마다 `bin/auto-sync.sh` 를 실행한다. 상주 프로세스가 없다 —
깨어나서 `git status` 를 묻고(약 8ms) 종료한다.

| 단계 | 내용 |
|---|---|
| 선검사 | rebase·merge·cherry-pick 진행 중이거나 `main` 이 아니면 아무것도 하지 않는다 |
| 변경 판정 | `.gitignore` 화이트리스트를 통과한 변경만 대상이다. 런타임 데이터는 보이지 않는다 |
| 디바운스 | 마지막 변경 후 90초간 조용할 때까지 기다린다. 연속 편집이 커밋 하나로 합쳐지고, 에디터의 부분 쓰기가 배제된다 |
| 게이트 | 경로 허용목록 + 자격증명 파일명·내용 패턴. 통과 못 하면 **스테이징조차 하지 않고** 중단하고 알린다 |
| 커밋 | 네트워크보다 먼저. 오프라인에서도 작업이 보존된다 |
| 푸시 | fast-forward 만. 원격이 앞서 있으면 멈추고 알린다 |

### 하지 않는 것

`rebase`, `merge`, `pull`, `stash`, `reset`, `clean`, force-push 를 쓰지 않는다
(`--force-with-lease` 조차 쓰지 않는다). 쓰기 작업은 `add`·`commit`·`push`(force 없음) 세 개뿐이다.
force 없는 push 는 서버측 fast-forward 검사가 다른 머신의 작업을 덮어쓰는 것을 불가능하게 만든다.

분기 해소는 유저 판단으로 남긴다. `CLAUDE.md` 의 Git Safety Rules 를 따른다.

### 원격이 앞서 있을 때

알림이 오면 로컬 커밋은 이미 되어 있고 push 만 보류된 상태다. 직접 통합한다.

```bash
cd ~/.claude
git log --oneline origin/main..HEAD    # 로컬에만 있는 커밋
git log --oneline HEAD..origin/main    # 원격에만 있는 커밋
```

통합 방법(merge 또는 rebase)을 판단해 실행한 뒤 push 한다.

### 진단

```bash
tail -f ~/.claude/.git/auto-sync.log
launchctl print gui/$(id -u)/com.zoeyul.claude-autosync
```

| 로그 | 뜻 |
|---|---|
| `DEBOUNCE` | 변경이 진행 중. 조용해지면 커밋한다 |
| `SKIP` | git 작업 진행 중이거나 `main` 이 아니다 |
| `BLOCK` | 게이트가 막았다. 해당 파일을 확인한다 |
| `DIVERGED` | 원격이 앞서 있다. 위 절차로 통합한다 |
| `COMMIT` / `PUSH ok` | 정상 |

상태 파일은 `.git/` 안에 둔다 (`auto-sync.log`, `.lock`, `.state`, `.notified.*`).
`.gitignore` 매칭 대상이 아니므로 데몬이 자기 자신을 트리거하지 않는다.

알림은 사유별로 한 번만 보낸다. 성공하면 해제된다.

