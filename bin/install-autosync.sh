#!/bin/bash
# 자동 동기화 launchd 에이전트를 설치하거나 제거한다. 재실행해도 결과가 같다.
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
LABEL="com.zoeyul.claude-autosync"
SRC="$CLAUDE_DIR/$LABEL.plist"
DST="$HOME/Library/LaunchAgents/$LABEL.plist"
UID_NUM="$(id -u)"

if [ "${1:-}" = "--uninstall" ]; then
  launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
  rm -f "$DST"
  echo "자동 동기화 제거 완료"
  exit 0
fi

[ -f "$SRC" ] || { echo "plist 템플릿이 없습니다: $SRC" >&2; exit 1; }
[ -x "$CLAUDE_DIR/bin/auto-sync.sh" ] || { echo "auto-sync.sh 가 없거나 실행 권한이 없습니다" >&2; exit 1; }

# 비대화식 push 가 가능한지 먼저 확인한다.
# 조용히 실패만 하는 데몬을 세우지 않기 위해서다.
if ! GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10' \
     git -C "$CLAUDE_DIR" ls-remote --heads origin >/dev/null 2>&1; then
  echo "SSH 비대화식 접근 실패. 키 설정 후 다시 실행하세요." >&2
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents"
# plist 는 ~ 와 $HOME 을 확장하지 않는다. 설치 시점에 치환한다.
sed "s#__HOME__#$HOME#g" "$SRC" > "$DST"
plutil -lint "$DST" >/dev/null

# 재설치를 멱등하게 만든다. load/unload 는 deprecated 다.
launchctl bootout "gui/$UID_NUM/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$DST"
launchctl enable "gui/$UID_NUM/$LABEL"

echo "  자동 동기화 설치 ($LABEL, 120초 간격)"
echo "  로그: ~/.claude/.git/auto-sync.log"
echo "  제거: ~/.claude/bin/install-autosync.sh --uninstall"
