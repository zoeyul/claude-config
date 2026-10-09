# task-find

Searches task files by keyword.

## Usage

```
/task-find <keyword>
```

## Behavior

1. Search all of `~/code/tasks` by keyword:
   - Filename search: `find ~/code/tasks -name "*{keyword}*.md"`
   - Content search: `find ~/code/tasks -name "*.md" | xargs grep -l "{keyword}"`

2. Display the list of files found:
   - Status (todo/in-progress/done/archive)
   - Project
   - File path

3. Read the most relevant files

4. Provide a content summary

## Example

```bash
# Find SDK-related work
/task-find sdk

# Find migration-related work
/task-find migration
```
