#!/usr/bin/env python3
"""Deterministic spec and hygiene checks for Agent Skills.

Usage: check_skill.py <skill-dir> [skill-dir ...]
Exit code 1 when at least one error is reported.
"""

import re
import sys
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NAME_MAX = 64
DESC_MAX = 1024
DESC_MIN = 40
COMPAT_MAX = 500
BODY_WARN_LINES = 350
BODY_MAX_LINES = 500
BODY_WARN_TOKENS = 5000
TOC_MIN_LINES = 100
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")
CODE_PATH_RE = re.compile(r"`([A-Za-z0-9_./-]+\.(?:md|py|sh|json|ya?ml|txt|ts|js))`")
SKIP_DIRS = {".git", "node_modules", "__pycache__", "evals", "eval-viewer"}
OPTIONAL_PREFIXES = ("evals/", "references/<", "scripts/<", "assets/<")


class Report:
    def __init__(self, skill):
        self.skill = skill
        self.rows = []

    def add(self, level, check, message):
        self.rows.append((level, check, message))

    def error(self, check, message):
        self.add("ERROR", check, message)

    def warn(self, check, message):
        self.add("WARN", check, message)

    def info(self, check, message):
        self.add("INFO", check, message)

    @property
    def errors(self):
        return sum(1 for level, _, _ in self.rows if level == "ERROR")

    @property
    def warnings(self):
        return sum(1 for level, _, _ in self.rows if level == "WARN")

    def render(self):
        order = {"ERROR": 0, "WARN": 1, "INFO": 2}
        lines = [f"== {self.skill} =="]
        if not self.rows:
            lines.append("  ok: no findings")
        for level, check, message in sorted(self.rows, key=lambda r: order[r[0]]):
            lines.append(f"  {level:5} {check}: {message}")
        lines.append(f"  totals: {self.errors} error(s), {self.warnings} warning(s)")
        return "\n".join(lines)


def split_frontmatter(text):
    if not text.startswith("---"):
        return None, text
    lines = text.splitlines()
    end = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end = index
            break
    if end is None:
        return None, text
    return lines[1:end], "\n".join(lines[end + 1:])


def parse_frontmatter(lines):
    data = {}
    index = 0
    while index < len(lines):
        line = lines[index]
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not match:
            index += 1
            continue
        key, value = match.group(1), match.group(2)
        if value in (">", "|", ">-", "|-", ">+", "|+"):
            block = []
            index += 1
            while index < len(lines) and (
                not lines[index].strip() or lines[index][:1] in (" ", "\t")
            ):
                block.append(lines[index].strip())
                index += 1
            data[key] = " ".join(part for part in block if part)
            continue
        data[key] = value.strip().strip("'\"")
        index += 1
    return data


def strip_code_fences(text):
    kept = []
    inside = False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            inside = not inside
            continue
        if not inside:
            kept.append(line)
    return "\n".join(kept)


def referenced_paths(text):
    found = set()
    for match in LINK_RE.finditer(text):
        target = match.group(1).split("#")[0].strip()
        if target and not target.startswith(("http://", "https://", "mailto:")):
            found.add(target)
    for match in CODE_PATH_RE.finditer(text):
        target = match.group(1)
        if "/" in target or target.endswith(".md"):
            found.add(target)
    return found


def has_toc(text):
    return bool(re.search(r"^\s*[-*]\s+\[[^\]]+\]\(#", text, re.MULTILINE))


def read(path):
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return ""


def check_metadata(report, root, data, body_text):
    name = data.get("name")
    description = data.get("description")

    if not name:
        report.error("frontmatter", "name is required")
    else:
        if len(name) > NAME_MAX:
            report.error("name", f"{len(name)} characters, limit {NAME_MAX}")
        if not NAME_RE.match(name):
            report.error(
                "name",
                f"invalid value {name!r}: use lowercase letters, digits, single hyphens, no leading or trailing hyphen",
            )
        if name != root.name:
            report.error("name", f"{name!r} does not match directory name {root.name!r}")

    if not description:
        report.error("frontmatter", "description is required")
    else:
        if len(description) > DESC_MAX:
            report.error("description", f"{len(description)} characters, limit {DESC_MAX}")
        if len(description) < DESC_MIN:
            report.warn("description", f"only {len(description)} characters, likely too vague to trigger reliably")
        if "<" in description or ">" in description:
            report.error("description", "contains XML angle brackets")
        lowered = description.lower()
        if re.match(r"^\s*i\s+(can|will|help)", lowered) or "i can help" in lowered:
            report.error("description", "written in first person, write in the third person")
        if not re.search(r"\b(use|activate|when|triggers? on)\b", lowered):
            report.warn("description", "no activation wording, add 'Use when ...'")
        if not re.search(r"[`\"']\w[\w -]*[\"']?", description) and "," not in description:
            report.warn("description", "no concrete trigger phrases or enumerations")

    compatibility = data.get("compatibility")
    if compatibility and len(compatibility) > COMPAT_MAX:
        report.error("compatibility", f"{len(compatibility)} characters, limit {COMPAT_MAX}")

    body_lines = body_text.splitlines()
    body_tokens = len(body_text) // 4
    if len(body_lines) > BODY_MAX_LINES:
        report.error("length", f"body is {len(body_lines)} lines, limit {BODY_MAX_LINES}; move detail to references/")
    elif len(body_lines) > BODY_WARN_LINES:
        report.warn("length", f"body is {len(body_lines)} lines, target is 150-300")
    if body_tokens > BODY_WARN_TOKENS:
        report.warn("length", f"body is roughly {body_tokens} tokens, recommended limit {BODY_WARN_TOKENS}")

    if not body_lines:
        report.error("body", "no instructions after frontmatter")
    elif not any(line.strip() for line in body_lines):
        report.error("body", "body is whitespace only")


def check_links(report, root, body_text):
    for target in sorted(referenced_paths(body_text)):
        if target.startswith(OPTIONAL_PREFIXES):
            continue
        path = (root / target).resolve()
        if not path.exists():
            top = target.split("/")[0]
            if top in ("references", "scripts", "assets"):
                report.error("references", f"SKILL.md points at missing file {target}")
            else:
                report.warn(
                    "references",
                    f"{target} not found in the skill directory; if it is not a project file the agent will look for, remove or correct the reference",
                )
            continue
        if path.is_file() and "references" in path.parts and path.suffix == ".md":
            text = read(path)
            if len(text.splitlines()) > TOC_MIN_LINES and not has_toc(text):
                report.warn("references", f"{target} is over {TOC_MIN_LINES} lines without a table of contents")
            nested = [
                item
                for item in sorted(referenced_paths(text))
                if item.endswith(".md") and "/" in item
            ]
            for item in nested:
                report.warn("references", f"{target} links to {item}, link reference files directly from SKILL.md instead")


def check_duplication(report, root, body_text):
    body_lines = {
        line.strip()
        for line in body_text.splitlines()
        if len(line.strip()) > 40 and not line.strip().startswith(("#", "-", "*", "|"))
    }
    if not body_lines:
        return
    for path in sorted(root.rglob("*.md")):
        relative = path.relative_to(root)
        if relative.as_posix() == "SKILL.md" or any(part in SKIP_DIRS for part in relative.parts):
            continue
        other = {line.strip() for line in read(path).splitlines() if len(line.strip()) > 40}
        shared = body_lines & other
        if len(shared) >= 3:
            sample = next(iter(shared))[:60]
            report.warn("duplication", f"{len(shared)} long lines shared with {relative.as_posix()}, e.g. {sample!r}")


def check_scripts(report, root):
    scripts = root / "scripts"
    if not scripts.is_dir():
        return
    for path in sorted(scripts.rglob("*")):
        if path.is_file() and path.suffix in (".py", ".sh"):
            text = read(path)
            if len(text.splitlines()) > 400:
                report.warn("scripts", f"{path.relative_to(root).as_posix()} is {len(text.splitlines())} lines, confirm it earns its place")
            if not text.strip():
                report.error("scripts", f"{path.relative_to(root).as_posix()} is empty")


def check_skill(root):
    report = Report(root.as_posix())
    skill_md = root / "SKILL.md"
    if not skill_md.is_file():
        report.error("structure", "SKILL.md not found")
        return report

    text = read(skill_md)
    front_lines, body_text = split_frontmatter(text)
    if front_lines is None:
        report.error("frontmatter", "no YAML frontmatter delimited by --- lines")
        return report

    data = parse_frontmatter(front_lines)
    check_metadata(report, root, data, body_text)
    check_links(report, root, strip_code_fences(body_text))
    check_duplication(report, root, strip_code_fences(body_text))
    check_scripts(report, root)
    return report


def main(argv):
    if len(argv) < 2:
        print("usage: check_skill.py <skill-dir> [skill-dir ...]", file=sys.stderr)
        return 2
    failed = False
    for arg in argv[1:]:
        root = Path(arg).expanduser()
        if not root.is_dir():
            print(f"== {arg} ==\n  ERROR structure: not a directory", file=sys.stderr)
            failed = True
            continue
        report = check_skill(root)
        print(report.render())
        failed = failed or report.errors > 0
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))