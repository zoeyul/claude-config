#!/bin/bash
# 이 머신에서 활성화된 플러그인을 공유 목록에 반영한다.
# 공개 GitHub 마켓플레이스에서 오는 것만 추가한다 — 레포가 public 이므로
# 사내·비공개 마켓플레이스 이름이 공개되는 것을 막는다.
set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
LIVE="$CLAUDE_DIR/settings.json"
SHARED="$CLAUDE_DIR/settings.shared.json"
KNOWN="$CLAUDE_DIR/plugins/known_marketplaces.json"
CACHE="$CLAUDE_DIR/.git/plugin-visibility.cache"

command -v jq >/dev/null 2>&1 || exit 0
[ -f "$LIVE" ] && [ -f "$SHARED" ] || exit 0

say() { printf 'sync-plugins: %s\n' "$*"; }

# 공유 목록에 없는 활성 플러그인만 후보가 된다.
candidates="$(jq -r --slurpfile sh "$SHARED" '
  (.enabledPlugins // {}) as $live
  | ($sh[0].enabledPlugins // {}) as $shared
  | $live | to_entries
  | map(select(.value == true and ($shared[.key] | not)))
  | .[].key
' "$LIVE" 2>/dev/null)"

[ -n "$candidates" ] || exit 0

# GitHub API 미인증 조회. 인증하면 유저가 접근 가능한 비공개 레포도 200 이 되어
# 판정이 무의미해진다. 미인증 200 은 "누구나 볼 수 있다" 와 같다.
is_public() {
  local repo="$1" cached code
  if [ -f "$CACHE" ]; then
    cached="$(grep -E "^${repo}[[:space:]]" "$CACHE" 2>/dev/null | awk '{print $2}' | head -1)"
    [ -n "$cached" ] && { [ "$cached" = public ]; return $?; }
  fi
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
          "https://api.github.com/repos/$repo" 2>/dev/null || echo 000)"
  code="${code: -3}"
  if [ "$code" = 200 ]; then
    printf '%s\tpublic\n' "$repo" >> "$CACHE"; return 0
  fi
  # 404 만 영구 판정으로 캐시한다. 000(연결 실패)·5xx·429 는 일시적 장애이거나
  # 프록시 응답일 수 있어, 공개 레포를 private 로 굳히면 이후 영구히 동기화되지 않는다.
  if [ "$code" = 404 ]; then
    printf '%s\tprivate\n' "$repo" >> "$CACHE"
    return 1
  fi
  return 2
}

add_plugins=() add_markets=()
while IFS= read -r plugin; do
  [ -n "$plugin" ] || continue
  market="${plugin##*@}"
  [ -n "$market" ] && [ "$market" != "$plugin" ] || { say "SKIP $plugin (마켓플레이스 불명)"; continue; }

  src="$(jq -r --arg m "$market" '.[$m].source.source // empty' "$KNOWN" 2>/dev/null)"
  repo="$(jq -r --arg m "$market" '.[$m].source.repo // empty' "$KNOWN" 2>/dev/null)"

  if [ "$src" != github ] || [ -z "$repo" ]; then
    say "SKIP $plugin (github 레포가 아님: ${src:-정의없음})"
    continue
  fi
  is_public "$repo"; vis=$?
  if [ "$vis" = 1 ]; then
    say "SKIP $plugin ($repo 비공개 — public 레포에 올리지 않는다)"
    continue
  elif [ "$vis" != 0 ]; then
    say "SKIP $plugin ($repo 공개 여부 확인 실패 — 다음 실행에서 재시도)"
    continue
  fi
  add_plugins+=("$plugin")
  add_markets+=("$market")
  say "ADD $plugin ($repo)"
done <<< "$candidates"

[ "${#add_plugins[@]}" -gt 0 ] || exit 0

pj="$(printf '%s\n' "${add_plugins[@]}" | jq -R . | jq -s .)"
mj="$(printf '%s\n' "${add_markets[@]}" | jq -R . | jq -s 'unique')"

tmp="$SHARED.tmp.$$"
jq --argjson plugins "$pj" --argjson markets "$mj" --slurpfile known "$KNOWN" '
  .enabledPlugins = ((.enabledPlugins // {}) + ($plugins | map({key: ., value: true}) | from_entries))
  | .extraKnownMarketplaces = ((.extraKnownMarketplaces // {}) +
      ($markets | map({key: ., value: {source: $known[0][.].source}}) | from_entries))
' "$SHARED" > "$tmp" 2>/dev/null || { rm -f "$tmp"; say "ERROR jq 실패"; exit 1; }

jq empty "$tmp" 2>/dev/null || { rm -f "$tmp"; say "ERROR 결과가 유효한 JSON 이 아니다"; exit 1; }

# 내용이 같으면 쓰지 않는다. 데몬이 자기 변경으로 다시 깨어나는 루프를 막는다.
if cmp -s "$SHARED" "$tmp"; then
  rm -f "$tmp"
  exit 0
fi

cp "$SHARED" "$SHARED.bak.$(date +%Y%m%d%H%M%S)"
mv "$tmp" "$SHARED"
say "공유 목록 갱신 (${#add_plugins[@]}개 추가)"
