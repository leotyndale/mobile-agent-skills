# Contributing to Mobile Agent Skills

Thank you for helping make AI coding agents genuinely reliable for production mobile engineering!

## Skill Design Principles

Every skill in `skills/<skill-name>/SKILL.md` must follow these rules:

1. **Actionable Engineering Depth**: Avoid generic advice ("write clean code"). Include concrete checks, real framework APIs, measurable thresholds, and anti-patterns.
2. **Required Frontmatter**:
   ```yaml
   ---
   name: kebab-case-skill-name
   description: One-sentence trigger description specifying what the skill does and when an agent should activate it.
   ---
   ```
3. **Required Markdown Sections**:
   - `## When to Use`
   - `## Workflow`
   - `## Checklist`
   - `## Output Format`
4. **Zero Broken References**: Any relative links inside `SKILL.md` or `README*.md` must resolve to existing files in the repository.

## Local Validation

Before opening a Pull Request, run both checks locally:

```bash
python3 scripts/validate_skills.py
bash scripts/install.sh --dry-run --target all
```

Both commands must exit `0`.

## Pull Request Checklist

- [ ] Skill folder is named `skills/<kebab-case-name>/SKILL.md` and matches `name:` in frontmatter
- [ ] `python3 scripts/validate_skills.py` passes with zero errors
- [ ] `bash scripts/install.sh --dry-run --target all` succeeds
- [ ] Added the new skill to `README.md` and `README_ZH.md` catalog tables
