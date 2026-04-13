# Health Report Template

## YAML Frontmatter

```yaml
---
date: YYYY-MM-DD
type: health
checks_run: 9
warn_count: N
info_count: N
---
```

## Report Structure

```markdown
## Health Report — [project name] — [date]

### WARN (act on these)
- [finding]

### INFO (awareness)
- [finding]

### OK (passing)
- [check name] — passed
```

Also print the report to the user. The persisted file lets `/propose`
reference health findings when drafting proposals.
