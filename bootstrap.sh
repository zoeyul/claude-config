#!/bin/bash
# 레포의 공유 설정을 Claude Code 런타임 파일에 주입한다.
# ~/.claude.json 과 ~/.claude/settings.json 은 Claude Code 와 외부 도구가
# 상시 갱신하므로 통째로 교체하지 않고 필요한 키만 반영한다. 재실행해도 결과가 같다.

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
CONFIG="$HOME/.claude.json"

command -v jq >/dev/null 2>&1 || { echo "jq 가 필요합니다: brew install jq" >&2; exit 1; }

backup() { [ -f "$1" ] && cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"; }

# mcpServers 는 레포가 단일 출처다. 통째로 교체한다.
# 머신 전용 서버가 필요하면 mcp.json 에 추가한다.
apply_mcp() {
  local src="$CLAUDE_DIR/mcp.json"
  [ -f "$src" ] || return 0
  [ -f "$CONFIG" ] || echo '{}' > "$CONFIG"
  backup "$CONFIG"
  jq --slurpfile m "$src" '.mcpServers = $m[0].mcpServers' "$CONFIG" > "$CONFIG.tmp"
  mv "$CONFIG.tmp" "$CONFIG"
  echo "  mcpServers -> ~/.claude.json ($(jq '.mcpServers | length' "$src")개, 교체)"
}

# 공유 설정은 병합한다. permissions·hooks·statusLine 등 머신 고유 값은 보존된다.
apply_settings() {
  local src="$CLAUDE_DIR/settings.shared.json"
  local dst="$CLAUDE_DIR/settings.json"
  [ -f "$src" ] || return 0
  [ -f "$dst" ] || echo '{}' > "$dst"
  backup "$dst"
  jq -s '.[0] * .[1]' "$dst" "$src" > "$dst.tmp"
  mv "$dst.tmp" "$dst"
  echo "  settings.shared.json -> settings.json (병합)"
}

echo "Claude 설정 적용"
apply_mcp
apply_settings

# mcp.json 이 참조하는 환경변수 중 미설정인 것을 알린다.
report_unset_vars() {
  local src="$CLAUDE_DIR/mcp.json" missing=""
  [ -f "$src" ] || return 0
  # 기본값(${VAR:-...})이 있는 변수는 제외한다
  for v in $(grep -oE '\$\{[A-Za-z_][A-Za-z0-9_]*\}' "$src" | sed 's/^\${//; s/}$//' | sort -u); do
    [ -n "${!v-}" ] || missing="$missing $v"
  done
  [ -n "$missing" ] || return 0
  echo ""
  echo "미설정 환경변수:$missing"
  echo "  해당 MCP 서버만 연결에 실패하고 나머지는 정상 동작합니다."
}

report_unset_vars
echo ""
echo "완료. Claude Code 를 재시작하세요."
