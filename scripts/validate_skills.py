#!/usr/bin/env python3
"""Validate all SKILL.md files and local Markdown links in mobile-agent-skills."""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"

REQUIRED_SECTIONS = [
    "## When to Use",
    "## Workflow",
    "## Checklist",
    "## Output Format",
]

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def parse_frontmatter(text: str, path: pathlib.Path) -> tuple[dict[str, str], str]:
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: missing opening YAML frontmatter '---'")
    end_idx = text.find("\n---\n", 4)
    if end_idx == -1:
        raise ValueError(f"{path}: missing closing YAML frontmatter '---'")
    raw_fm = text[4:end_idx]
    body = text[end_idx + 5 :]

    meta: dict[str, str] = {}
    for line in raw_fm.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if ":" not in stripped:
            raise ValueError(f"{path}: invalid frontmatter line: {line!r}")
        k, v = stripped.split(":", 1)
        meta[k.strip()] = v.strip().strip('"').strip("'")
    return meta, body


def check_local_links(md_path: pathlib.Path, text: str) -> list[str]:
    errors: list[str] = []
    # Strip fenced code blocks before scanning links
    cleaned = re.sub(r"```.*?```", "", text, flags=re.DOTALL)
    for match in LINK_RE.finditer(cleaned):
        target = match.group(1).strip()
        if not target or target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        rel_path = target.split("#", 1)[0]
        if not rel_path:
            continue
        resolved = (md_path.parent / rel_path).resolve()
        if not resolved.exists():
            errors.append(f"{md_path.relative_to(ROOT)}: broken local link '{target}'")
    return errors


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print(f"ERROR: skills directory not found at {SKILLS_DIR}", file=sys.stderr)
        return 1

    skill_dirs = sorted(p for p in SKILLS_DIR.iterdir() if p.is_dir())
    if not skill_dirs:
        print("ERROR: no skill directories found under skills/", file=sys.stderr)
        return 1

    errors: list[str] = []
    seen_names: set[str] = set()

    for sdir in skill_dirs:
        skill_file = sdir / "SKILL.md"
        if not skill_file.is_file():
            errors.append(f"{sdir.relative_to(ROOT)}: missing SKILL.md")
            continue

        content = skill_file.read_text(encoding="utf-8")
        try:
            meta, body = parse_frontmatter(content, skill_file.relative_to(ROOT))
        except ValueError as exc:
            errors.append(str(exc))
            continue

        name = meta.get("name", "")
        desc = meta.get("description", "")
        if not name:
            errors.append(f"{skill_file.relative_to(ROOT)}: missing 'name' in frontmatter")
        elif not NAME_RE.match(name):
            errors.append(f"{skill_file.relative_to(ROOT)}: invalid kebab-case name '{name}'")
        elif name != sdir.name:
            errors.append(
                f"{skill_file.relative_to(ROOT)}: frontmatter name '{name}' != directory '{sdir.name}'"
            )

        if name in seen_names:
            errors.append(f"Duplicate skill name: '{name}'")
        seen_names.add(name)

        if len(desc) < 20:
            errors.append(f"{skill_file.relative_to(ROOT)}: description is missing or too short")

        for sec in REQUIRED_SECTIONS:
            if sec not in body:
                errors.append(f"{skill_file.relative_to(ROOT)}: missing required section '{sec}'")

        if len(body.splitlines()) < 35:
            errors.append(
                f"{skill_file.relative_to(ROOT)}: skill body too thin ({len(body.splitlines())} lines)"
            )

        errors.extend(check_local_links(skill_file, content))

    for top_md in ["README.md", "README_ZH.md", "CONTRIBUTING.md"]:
        p = ROOT / top_md
        if p.is_file():
            errors.extend(check_local_links(p, p.read_text(encoding="utf-8")))

    if errors:
        print(f"FAILED: {len(errors)} validation error(s):", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"PASSED: {len(skill_dirs)}/{len(skill_dirs)} skills validated cleanly.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
