---
name: task-done
description: Use when work that is tracked under ~/code/tasks/ is finished - the user says a task is complete, done, or shipped. Converts the task file to the completion template and moves it to done/YYYY-MM/.
argument-hint: <task-filename>
---

# task-done

Marks work complete.

## Usage

```
/task-done <task-filename>
```

## Behavior

1. Find the task file in `in-progress/` or `todo/`
2. Read the file
3. Convert to the completion template:
   - **Status**: done
   - **Completed**: today's date
   - Mark every Progress checkbox complete
4. Move to the `done/YYYY-MM/` directory
5. Delete the original file

## Example

```bash
# Mark in-progress/sdk-migration.md complete
/task-done sdk-migration

# Result: done/2026-09/sdk-migration.md created
```

## Notes

- Error when the file does not exist
- Skip when it is already in done/
