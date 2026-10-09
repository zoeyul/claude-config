# task-list

Displays the list of work currently in progress.

## Usage

```
/task-list
```

## Behavior

1. Scan the `in-progress/` directory of every project
2. Read each task file's metadata:
   - Title
   - Priority
   - Created
   - Progress (completed checkboxes / total checkboxes)
3. Display grouped by project

## Options

- No argument: all projects
- Project name given: that project only
  ```
  /task-list <project>
  ```
