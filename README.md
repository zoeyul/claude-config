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

### 5. Claude Code 재시작

## 다른 머신 동기화

```bash
cd ~/.claude && git pull && ./bootstrap.sh
```

