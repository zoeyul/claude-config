# Claude Configuration Management

A repository that shares global Claude Code configuration across multiple machines. The work tree of this repository is `~/.claude` itself.

## Structure

`~/.claude` mixes configuration with runtime data. `.gitignore` **excludes everything, then whitelists only the tracked paths.** New runtime directories are filtered out automatically.

### Tracked

| Path | Contents |
|---|---|
| `CLAUDE.md` | Global rules |
| `commands/` | Custom commands |
| `skills/` | Custom skills |
| `agents/`, `rules/`, `output-styles/`, `themes/` | Tracked if present |
| `hooks/` | Hand-written hooks only |
| `keybindings.json` | Key bindings |
| `mcp.json` | MCP server definitions |
| `settings.shared.json` | Plugin list, marketplaces, effortLevel, theme |
| `bootstrap.sh` | Applies the two JSON files above to the runtime files |
| `bin/` | Auto-sync and plugin sync scripts |
| `com.zoeyul.claude-autosync.plist` | launchd agent template for auto-sync |

### Excluded

- Runtime data: `projects/`, `history.jsonl`, `file-history/`, `sessions/`, `cache/`, `shell-snapshots/`, etc.
- `settings.json`, `settings.local.json` — continuously updated by Claude Code and external tools
- `plugins/` — the plugin **code** itself (47MB). Reinstalled from marketplaces
- Credentials (`*.key`, `*.pem`, `.credentials.json`, etc.)

### What is not shared, and why

| Item | Reason |
|---|---|
| `permissions` | An approval is a trust decision. Sharing it would auto-allow commands another machine never approved. By default, Claude Code stores approvals in each project's `.claude/settings.local.json` |
| `hooks`, `statusLine` | The external tools that use these values install them on each machine themselves |
| `oauthAccount`, `userID`, `machineID`, `projects` | Account- and machine-specific state |

## New Machine Setup

### 1. Attach the repository to `~/.claude`

Place the work tree over `~/.claude` without deleting it. **Run this outside a Claude Code session.**

```bash
cp -a ~/.claude ~/.claude.backup.$(date +%Y%m%d)

cd ~/.claude
git init
git remote add origin git@github.com:zoeyul/claude-config.git
git fetch origin
git checkout -f -b main origin/main
```

### 2. Apply configuration

```bash
~/.claude/bootstrap.sh
```

Applies `mcpServers` from `mcp.json` to `~/.claude.json` and merges `settings.shared.json` into `~/.claude/settings.json`. Existing `permissions`, `oauthAccount`, and caches are preserved. Re-running produces the same result.

### 3. Environment variables

Set the environment variables referenced by `mcp.json`. If one is unset, only the corresponding server fails to connect; the rest work normally.

### 4. Prerequisites

| Target | Check |
|---|---|
| `jq` | Used by `bootstrap.sh`. `brew install jq` |

Auto-sync has no additional dependencies. It uses no file watcher, so `fswatch` is not required.

### 5. Restart Claude Code

### 6. Auto-sync (optional)

```bash
~/.claude/bootstrap.sh --with-autosync
```

Install this if this machine should also commit and push changes automatically. See the `Auto-Sync` section below.

## Syncing Other Machines

```bash
cd ~/.claude && git pull && ./bootstrap.sh
```

On machines with auto-sync installed, local changes are already pushed. `git pull` alone is sufficient.

## Auto-Sync

Automatically commits and pushes when a tracked file changes. It works regardless of the editing agent (Claude Code, an editor, `git pull`).

```bash
./bootstrap.sh --with-autosync          # install
./bin/install-autosync.sh --uninstall   # uninstall
```

It is not installed by default, so that no daemon runs on machines that only need the configuration.

During installation, `git ls-remote` is attempted first with `BatchMode`. If non-interactive SSH access fails, it is not installed — to avoid setting up a daemon that only fails silently.
Re-running produces the same result.

### Behavior

launchd runs `bin/auto-sync.sh` every 120 seconds. There is no resident process — it wakes up, queries `git status` (about 8ms), and exits.

| Step | Description |
|---|---|
| Pre-check | Does nothing if `.git/` contains an in-progress operation marker (`rebase-merge`, `rebase-apply`, `MERGE_HEAD`, `CHERRY_PICK_HEAD`, `REVERT_HEAD`, `BISECT_LOG`, `index.lock`) or the branch is not `main` |
| Change detection | Only changes that pass the `.gitignore` whitelist are considered. Runtime data is invisible |
| Debounce | Waits until 90 seconds pass with no change. Consecutive edits merge into one commit, and partial writes by editors are excluded |
| Gate | Path allowlist + credential filename and content patterns + binary and >256KB blocking. On failure, it stops **without even staging** and sends a notification |
| Commit | Before any network access. Work is preserved even offline |
| Push | Fast-forward only. If the remote is ahead, it stops and sends a notification. The `fetch` used for divergence detection runs only every 15 minutes |

### What it never does

It never uses `rebase`, `merge`, `pull`, `stash`, `reset`, `clean`, or force-push
(not even `--force-with-lease`). Its only write operations are `add`, `commit`, and `push` (without force).
A push without force lets the server-side fast-forward check make it impossible to overwrite another machine's work.

Resolving divergence is left to the user. Follow the Git Safety Rules in `CLAUDE.md`.

### When the remote is ahead

When a notification arrives, the local commit has already been made and only the push is pending. Integrate manually.

```bash
cd ~/.claude
git log --oneline origin/main..HEAD    # commits only in local
git log --oneline HEAD..origin/main    # commits only in remote
```

Decide on the integration method (merge or rebase), run it, then push.

### Plugin sharing

When a plugin is installed, **it is automatically added to the shared list and pushed.** Nothing needs to be remembered.

What is shared is **the list, not the code.**

| | Contents | Tracked |
|---|---|---|
| `settings.shared.json` | Which plugins are used and where they come from | O |
| `plugins/` | Downloaded plugin code (47MB) | X |

Running `bootstrap.sh` on a new machine merges the list into `settings.json`,
and Claude Code reads that list and downloads the plugins itself. No manual installation is needed.
This is the same relationship as `package.json` and `node_modules/`.

#### Only public marketplaces are added automatically

**This repository is public.** Adding marketplaces automatically without distinction would expose internal marketplace names and source URLs. The daemon's secret gate does not catch this —
a marketplace name is not a credential pattern.

`bin/sync-plugins.sh` queries each marketplace's GitHub repository **unauthenticated**.

| Response | Verdict |
|---|---|
| 200 | Public → added automatically |
| 404 | Private or nonexistent → not added (cached permanently) |
| Other (000, 5xx, 429) | Check failed → not added, **retried on the next run** (not cached) |

Why unauthenticated: authenticating with `gh` returns 200 for private repositories the user can access, which makes the verdict meaningless. An unauthenticated 200 means "anyone can see it."

**Only 404 is cached**, so that a transient failure does not become a permanent verdict.
This prevents a public repository from never syncing because of a single network error.

To share an internal plugin, edit `settings.shared.json` directly.

#### Diagnostics

```bash
grep sync-plugins ~/.claude/.git/auto-sync.log
cat ~/.claude/.git/plugin-visibility.cache
```

Deleting the verdict cache causes the next run to query again.

### Tunable values

| Value | Default | Location |
|---|---|---|
| Run interval | 120 seconds | `StartInterval` in `com.zoeyul.claude-autosync.plist` |
| Debounce | 90 seconds | `QUIET_SECONDS` in `bin/auto-sync.sh` |
| `fetch` interval | 900 seconds | `FETCH_INTERVAL` in `bin/auto-sync.sh` |
| Log rotation | 1MB | `MAX_LOG_BYTES` in `bin/auto-sync.sh` |

The worst case from the last edit to push is about 3.5 minutes. Lowering the interval and debounce to 60/60 makes it about 2 minutes.
Setting `StartInterval` below 60 seconds has no effect (launchd enforces a lower bound on spawn rate).

`QUIET_SECONDS` and `FETCH_INTERVAL` can also be overridden with environment variables. Use this for manual runs.

```bash
QUIET_SECONDS=0 ~/.claude/bin/auto-sync.sh    # run immediately without debounce
```

### Diagnostics

```bash
tail -f ~/.claude/.git/auto-sync.log
launchctl print gui/$(id -u)/com.zoeyul.claude-autosync
```

| Log | Meaning |
|---|---|
| `DEBOUNCE` | Changes are in progress. Commits once quiet |
| `SKIP` | A git operation is in progress, or the branch is not `main` |
| `BLOCK` | The gate blocked it. Check the file in question |
| `DIVERGED` | The remote is ahead. Integrate using the procedure above |
| `COMMIT` / `PUSH ok` | Normal |

Failures of the script itself (syntax errors, etc.) are not recorded in `auto-sync.log`.
Check `.git/auto-sync.launchd.log` — the stderr received by launchd. It is empty when everything is normal.

State files are kept inside `.git/` (`auto-sync.log`, `.launchd.log`, `.lock`, `.state`, `.notified.*`).
They do not match `.gitignore`, so the daemon does not trigger itself.

Each notification is sent only once per reason. It is cleared on success.
