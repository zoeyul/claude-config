---
name: task-archive
description: Use when tracked work under ~/code/tasks/ is being stopped, dropped, cancelled, or shelved indefinitely rather than completed. Converts the task file to the archive template, records the reason, and moves it to archive/.
argument-hint: <task-filename>
---

# task-archive

Marks work stopped or dropped.

## Usage

```
/task-archive <task-filename>
```

## Behavior

1. Find the task file in `in-progress/` or `todo/`
2. Read the file
3. Convert to the archive template:
   - **Status**: archived
   - **Stopped**: today's date
   - Add a **Reason stopped** section
4. Move to the `archive/` directory
5. Delete the original file

## Example

```bash
# Stop in-progress/old-feature.md
/task-archive old-feature

# Result: archive/old-feature.md created
```

## Use Cases

- Cancelled due to a requirements change
- Deprioritized and held indefinitely
- No longer needed because it was solved another way
