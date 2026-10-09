# task-new

Registers new work.

## Usage

```
/task-new
```

## Behavior

1. Ask the user:
   - Project selection — scan under `~/code/tasks/` and present the directories that actually exist
   - Task title
   - Priority (high/medium/low)
   - Brief description

2. Create the Markdown file:
   - Location: `~/code/tasks/{selected project}/todo/{kebab-case-title}.md`
   - Apply the template

3. Print the file path

## Template

```markdown
# {task title}

**Status**: todo
**Priority**: {high/medium/low}
**Created**: {YYYY-MM-DD}

## Description

{user input}

## Details

(write the concrete implementation plan)

## Tests

- [ ] Test item 1

## Progress

- [ ] Not started
```
