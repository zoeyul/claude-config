---
description: Add a new document to ~/code/docs/
---

Ask the user for the topic of the document they want to write, then write it as a markdown file in the ~/code/docs/ directory.

Follow these steps:

1. **Confirm the topic**: ask what the document should cover
2. **Propose a filename**: suggest a kebab-case filename matching the topic (e.g. `aws-lambda-deployment.md`)
3. **Write the content**: write the document based on the user's explanation
4. **Save**: save to the path `/Users/seoyul/code/docs/{filename}`

Document format:
- Title: `# {topic}`
- Structured sections
- Code examples included (when applicable)
- Real cases included (when applicable)
- Reference links

Check existing document style:
```bash
ls ~/code/docs/
```
