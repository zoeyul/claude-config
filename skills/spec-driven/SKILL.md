---
name: spec-driven
description: Kiro-style Spec-Driven Development workflow (start/verify/update/status)
---

# Spec-Driven Development

This skill supports Kiro-style Spec-Driven Development.

## Usage

- `/spec-driven start` - create a new Spec
- `/spec-driven verify` - verify current work
- `/spec-driven update` - update the Spec
- `/spec-driven status` - check progress

Calling `/spec-driven` with no argument prints usage.

---

## start - create a new Spec

### Collect input
1. **Task name** (kebab-case recommended)
2. **Task description** (what, why)
3. **Save location** (global: `~/.claude/plans/`, project: `.claude/specs/`)

### Spec file structure

```markdown
# <task name>

## Requirements

### User Story
As a <role>, I want to achieve <goal>. <reason>.

---

### Requirement 1: <title>

#### Acceptance Criteria

1. WHEN [condition] THEN THE SYSTEM SHALL [behavior]
2. WHERE [context] THE SYSTEM SHALL [behavior]
3. IF [condition] THEN THE SYSTEM SHALL [behavior]

#### Additional Details
- **Priority**: High/Medium/Low
- **Complexity**: High/Medium/Low
- **Dependencies**: <dependencies>
- **Assumptions**: <assumptions>

---

## Design

### Current state analysis
<problems, existing structure>

### Technical approach
<chosen approach and reason>

### Critical Files
- **To modify**: `<path>` - <content>
- **To create**: `<path>` - <content>
- **To delete**: `<path>` - <reason>
- **To verify**: `<path>` - <method>

---

## Tasks

### Task 1: <title>
**Status**: TODO  
**Dependencies**: None  
**Requirement**: Requirement 1 (AC1, AC2)

#### Subtasks
- [ ] <item 1>
- [ ] <item 2>

---

### Task 2: <title>
...

---

## Progress Tracking

- **Total Tasks**: <number>
- **Completed**: 0
- **In Progress**: 0
- **TODO**: <number>

### Critical Path
1. Task X - <critical path>
```

### EARS format examples

**WHEN** - on event occurrence:
```
WHEN the user clicks the login button THEN THE SYSTEM SHALL call the authentication API
```

**WHERE** - context:
```
WHERE the configuration file contains a credential THE SYSTEM SHALL separate it into an environment variable
```

**IF** - condition:
```
IF the environment variable is not set THEN THE SYSTEM SHALL print an error message
```

**WHILE** - in progress:
```
WHILE data synchronization is in progress THE SYSTEM SHALL display the progress rate
```

### After execution
- Save the Spec file
- Print a summary
- Guide the next step (Design → Tasks → execution)

---

## verify - verify the Spec

### 1. Load the Spec
- Find the latest Spec in `~/.claude/plans/` or `.claude/specs/`
- When the user names a file, use that one

### 2. Verify Requirements

For each Acceptance Criterion:
- Check **whether it is satisfied** (✅/❌/⏳)
- Present the **evidence** (file, command result)
- State the **related files**

**Example:**
```
AC1: WHEN configuration files excluding credentials are in the Git repo...

Verification:
✅ Satisfied
- Confirmed with git ls-files: CLAUDE.md, commands/, .claude.json exist
- Confirmed .gitignore: credential files excluded
```

### 3. Verify Critical Files

```bash
# Check what was modified
git status | grep modified
git diff --name-only

# Check what was created
ls <file>

# Detect unexpected changes
git status --short
```

**Report:**
- ✅ Modified: `<file>` - <content>
- ❌ Not modified: `<file>` - not done yet
- ⚠️ Unexpected: `<file>` - not in the Spec

### 4. Tasks progress

```
Completed (2/5):
- ✅ Task 1: ...
- ✅ Task 2: ...

In progress (1/5):
- ⏳ Task 3: ...

Incomplete (2/5):
- ❌ Task 4: ...
- ❌ Task 5: ...
```

### 5. Violation summary

```
🚨 Spec violations

Critical:
- ❌ AC3 not satisfied: no skills link in setup.sh
- ❌ Missing file: settings.json

Warning:
- ⚠️ Unexpected change: test.md

Recommendations:
1. Modify setup.sh
2. Add settings.json
3. Add test.md to the Spec or delete it
```

---

## update - update the Spec

### 1. Confirm the changes
- What changed
- Why it changed

### 2. Update Requirements
- Add new ACs
- Modify existing ACs
- Delete unnecessary ACs

### 3. Analyze Design impact
- Update Critical Files
- Revise the technical approach

### 4. Synchronize Tasks

**New AC added** → create a new Task:
```markdown
### Task N: <implement the new AC>
**Requirement**: Requirement X (ACN)
```

**AC deleted** → remove the corresponding Task

**AC modified** → update the Task Subtasks

### 5. Git commit
```bash
git add <spec-file>
git commit -m "spec: <change>"
```

---

## status - progress

### 1. Requirements status

```
Requirement 1: configuration file sharing
├─ AC1: ✅ Satisfied
├─ AC2: ✅ Satisfied
├─ AC3: ⏳ In progress
└─ AC4: ❌ Not satisfied

Requirement 2: symbolic links
├─ AC1: ✅ Satisfied
└─ AC2: ❌ Not satisfied
```

### 2. Critical Files status

```
To modify (2/3):
✅ ~/.claude/CLAUDE.md
✅ ~/code/claude-config/setup.sh
❌ ~/code/claude-config/README.md

To create (1/2):
✅ ~/.claude/skills/spec-driven.md
❌ ~/code/claude-config/settings.json
```

### 3. Tasks progress rate

```
Total: 10
Completed: 3 (30%)
In progress: 2 (20%)
Incomplete: 5 (50%)

Current task: Task 4 - update setup.sh
Next task: Task 5 - rewrite README.md
```

### 4. Estimated completion

```
Critical Path:
Task 1 (done) → Task 3 (in progress) → Task 5 (waiting) → Task 8 (waiting)

Estimated remaining: 5
Current rate: 1 task/10min
Estimated completion: ~50min
```

---

## Cautions

### EARS format required
- Always include the "SHALL" keyword
- State the conditional (WHEN/WHERE/IF/WHILE)
- Measurable criteria

### Maintain traceability
- Link Tasks to Requirement ACs
- State the Requirement number + AC number

### State the evidence
- Not just "satisfied" or "not satisfied"
- State **which file or command confirmed it**

### Watch for unexpected changes
- Warn on changes not in the Spec
- When intentional, recommend updating the Spec
- Ignore auto-generated files (node_modules and the like)
