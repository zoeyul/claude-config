#!/bin/bash
# ~/.claude 의 추적 대상 변경을 커밋하고 푸시한다.
# launchd 가 StartInterval 로 주기 실행한다. 변경이 없으면 즉시 종료한다.
#
# set -e 를 쓰지 않는다. git 변경은 모두 명시적 if 로 처리한다 —
# 중간 중단으로 스테이징만 된 인덱스가 남으면 다음 틱에 최악의 상태가 된다.
set -uo pipefail

REPO="$HOME/.claude"
LOCK="$REPO/.git/auto-sync.lock"
LOG="$REPO/.git/auto-sync.log"
STATE="$REPO/.git/auto-sync.state"
QUIET_SECONDS="${QUIET_SECONDS:-90}"
FETCH_INTERVAL="${FETCH_INTERVAL:-900}"
MAX_LOG_BYTES=1048576

# BatchMode: 자격증명 프롬프트로 데몬이 멈추지 않게 한다.
export GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=10'
export GIT_TERMINAL_PROMPT=0
# 읽기 전용 git 이 .git/index 에 기회성 쓰기를 하지 않게 한다 (대화형 git 과의 경합 방지).
export GIT_OPTIONAL_LOCKS=0

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*" >> "$LOG"; }

rotate_log() {
  [ -f "$LOG" ] || return 0
  local size
  size="$(stat -f %z "$LOG" 2>/dev/null || echo 0)"
  [ "$size" -gt "$MAX_LOG_BYTES" ] || return 0
  mv "$LOG" "$LOG.1"
}

# 120초 주기에서 지속 실패는 하루 720건이 된다. 사유별로 한 번만 알린다.
notify() {
  local reason="$1" message="$2"
  local stamp="$REPO/.git/auto-sync.notified.$reason"
  [ -f "$stamp" ] && return 0
  : > "$stamp"
  log "NOTIFY($reason) $message"
  osascript -e "display notification \"${message//\"/\\\"}\" with title \"claude-config 동기화 실패\"" 2>/dev/null || true
}

clear_notify() { rm -f "$REPO"/.git/auto-sync.notified.* 2>/dev/null || true; }

# macOS 에 flock 이 없다. mkdir 은 원자적이라 락으로 쓴다.
acquire_lock() {
  if mkdir "$LOCK" 2>/dev/null; then
    echo $$ > "$LOCK/pid"
    trap 'rm -rf "$LOCK"' EXIT HUP INT TERM
    return 0
  fi
  local owner
  owner="$(cat "$LOCK/pid" 2>/dev/null || echo "")"
  if [ -n "$owner" ] && kill -0 "$owner" 2>/dev/null; then
    exit 0
  fi
  log "stale lock (pid=${owner:-unknown}) 회수"
  rm -rf "$LOCK"
  mkdir "$LOCK" 2>/dev/null || exit 0
  echo $$ > "$LOCK/pid"
  trap 'rm -rf "$LOCK"' EXIT HUP INT TERM
}

cd "$REPO" 2>/dev/null || exit 1
rotate_log
acquire_lock

# 유저가 수동 작업 중인 레포에 손대지 않는다.
# index.lock 은 대화형 git 이 지금 돌고 있다는 뜻이다.
for marker in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD \
              REVERT_HEAD BISECT_LOG index.lock; do
  if [ -e "$REPO/.git/$marker" ]; then
    log "SKIP: 진행 중인 git 작업 ($marker)"
    exit 0
  fi
done

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "")"
if [ "$branch" != "main" ]; then
  log "SKIP: 브랜치가 main 이 아니다 (${branch:-detached})"
  exit 0
fi

# 커밋 대상 경로. .gitignore 가 런타임 데이터를 이미 걸러낸다.
# 스크립트는 그 필터를 재구현하지 않고 신뢰한다.
changed_paths() {
  { git diff --name-only HEAD --; git ls-files --others --exclude-standard; } | sort -u
}

# macOS 의 bash 3.2 에는 mapfile 이 없다. read 루프로 배열을 만든다.
PATHS=()
while IFS= read -r line; do
  [ -n "$line" ] && PATHS+=("$line")
done < <(changed_paths)
[ "${#PATHS[@]}" -gt 0 ] || exit 0

# 변경이 아직 진행 중이면 다음 틱으로 넘긴다.
# 연속 편집이 하나의 커밋으로 합쳐지고, 에디터의 부분 쓰기가 구조적으로 배제된다.
newest=0
for f in "${PATHS[@]}"; do
  [ -f "$f" ] || continue
  m="$(stat -f %m "$f" 2>/dev/null || echo 0)"
  [ "$m" -gt "$newest" ] && newest="$m"
done
if [ "$newest" -gt 0 ]; then
  age=$(( $(date +%s) - newest ))
  if [ "$age" -lt "$QUIET_SECONDS" ]; then
    log "DEBOUNCE: 최근 변경 ${age}s 전, ${QUIET_SECONDS}s 대기"
    exit 0
  fi
fi

# 경로 허용목록. .gitignore 와 의도적으로 중복시킨다 —
# .gitignore 자체가 자동 커밋되므로, 잘못된 수정으로 커밋 범위가 넓어지는 것을 막는다.
PATH_ALLOW='^(\.gitignore|README\.md|bootstrap\.sh|CLAUDE\.md|mcp\.json|settings\.shared\.json|keybindings\.json|com\.zoeyul\.claude-autosync\.plist)$|^(commands|skills|agents|rules|output-styles|themes|bin)/'
NAME_DENY='(^|/)\.?(credentials|secrets?)\.json$|\.(key|pem|p12|pfx|token)$|(^|/)\.env'
CONTENT_DENY='(ghp_|github_pat_|gho_|ghs_)[A-Za-z0-9_]{16,}|sk-[A-Za-z0-9]{20,}|sk-ant-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.'

# 작업 트리를 검사한다. 인덱스는 건드리지 않으므로 차단 시 정리 경로가 필요 없다.
# 시크릿을 로그에 쓰지 않는다 — 경로와 사유 코드만 남긴다.
scan() {
  local blocked=0 f size
  for f in "${PATHS[@]}"; do
    [ -n "$f" ] || continue
    if ! printf '%s' "$f" | grep -qE "$PATH_ALLOW"; then
      log "BLOCK 허용목록 밖 경로: $f"; blocked=1; continue
    fi
    if printf '%s' "$f" | grep -qiE "$NAME_DENY"; then
      log "BLOCK 자격증명 파일명: $f"; blocked=1; continue
    fi
    [ -f "$f" ] || continue
    if [ "$(file -b --mime-encoding "$f" 2>/dev/null)" = binary ]; then
      log "BLOCK 바이너리: $f"; blocked=1; continue
    fi
    size="$(stat -f %z "$f" 2>/dev/null || echo 0)"
    if [ "$size" -gt 262144 ]; then
      log "BLOCK 비정상 크기 (>256KB): $f"; blocked=1; continue
    fi
    if grep -nEI "$CONTENT_DENY" "$f" >/dev/null 2>&1; then
      log "BLOCK 자격증명 내용: $f"; blocked=1; continue
    fi
  done
  return $blocked
}

if ! scan; then
  notify secret "자격증명 또는 예상 밖 파일이 감지되어 커밋을 중단했습니다. 로그: .git/auto-sync.log"
  exit 1
fi

# 변경 내용만 적는다. 범위가 넓으면 경로를 나열하지 않고 개수로 요약한다.
compose_message() {
  local n="${#PATHS[@]}" scopes count
  if [ "$n" -eq 1 ]; then
    printf '%s 수정' "${PATHS[0]}"
    return
  fi
  scopes="$(printf '%s\n' "${PATHS[@]}" | sed 's#/.*##' | sort -u)"
  count="$(printf '%s\n' "$scopes" | wc -l | tr -d ' ')"
  if [ "$count" -le 3 ]; then
    printf '%s 수정 (%d개 파일)' "$(printf '%s\n' "$scopes" | paste -sd, -)" "$n"
  else
    printf '설정 %d개 파일 수정' "$n"
  fi
}

# 경로를 명시해 스테이징한다. -A / . 를 쓰지 않는다.
if ! git add -- "${PATHS[@]}" 2>>"$LOG"; then
  log "ERROR: add 실패"
  notify add "스테이징에 실패했습니다. 로그: .git/auto-sync.log"
  exit 1
fi

msg="$(compose_message)"

# 커밋은 네트워크와 무관하게 먼저 한다. 오프라인에서도 작업이 보존된다.
if ! git commit --quiet -m "$msg" 2>>"$LOG"; then
  log "ERROR: 커밋 실패"
  notify commit "커밋에 실패했습니다. 로그: .git/auto-sync.log"
  exit 1
fi
log "COMMIT $(git rev-parse --short HEAD) $msg"

# fetch 는 읽기 전용이다. 네트워크 비용 때문에 주기를 둔다.
now="$(date +%s)"
last_fetch="$(cat "$STATE" 2>/dev/null || echo 0)"
if [ $(( now - last_fetch )) -ge "$FETCH_INTERVAL" ]; then
  if git fetch --quiet origin main 2>>"$LOG"; then
    echo "$now" > "$STATE"
  else
    log "WARN: fetch 실패 (오프라인 가능). 커밋은 로컬에 남는다"
  fi
fi

# origin/main 이 HEAD 의 조상이 아니면 분기 상태다.
# 복구를 시도하지 않는다 — rebase/merge/reset/force-push 는 유저 판단으로 남긴다.
if ! git merge-base --is-ancestor origin/main HEAD 2>/dev/null; then
  behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo '?')"
  ahead="$(git rev-list --count origin/main..HEAD 2>/dev/null || echo '?')"
  log "DIVERGED: ahead=$ahead behind=$behind — push 하지 않는다"
  notify diverge "원격이 ${behind}커밋 앞서 있습니다. 로컬 ${ahead}커밋은 커밋되었고 push 는 보류했습니다. ~/.claude 에서 직접 통합하세요."
  exit 0
fi

# force 를 쓰지 않는다. 서버측 fast-forward 검사가 덮어쓰기를 불가능하게 만든다.
if git push --quiet origin main 2>>"$LOG"; then
  log "PUSH ok -> origin/main"
  clear_notify
else
  log "WARN: push 거부됨 (원격이 갱신되었다). 다음 틱에서 재시도"
  notify push "push 가 거부되었습니다. 원격 변경을 확인하세요."
  exit 0
fi
