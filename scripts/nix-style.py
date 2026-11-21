#!/usr/bin/env python3
"""Start of the repo's Nix style formatter.

Rules implemented (mechanical, safe):
  - single-line non-empty lists under `=` become one item per line;
  - single-line non-empty attrsets under `=` become one attr per line;
  - `}: {` becomes `}:` + `{` on the next line.

Semantic rules (dotted option paths, trivial `services.foo.enable` blocks) are
not guessed here: they need human judgment and are described in AGENTS.md.

Usage:
  nix-style.py [--check] [FILES...]
Default without --check rewrites files in place, so `nix fmt` can use it.
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = (
    pathlib.Path.cwd()
    if (pathlib.Path.cwd() / "flake.nix").exists()
    else pathlib.Path(__file__).resolve().parent.parent
)
SKIP_PARTS = {".git", "vendor", "result", "result-iso-custom", "result-iso-lite"}


def split_items(text: str) -> list[str]:
    """Split Nix list/set contents at top level, respecting quotes and ()."""
    items: list[str] = []
    buf: list[str] = []
    depth = 0
    quote = ""
    i = 0
    while i < len(text):
        ch = text[i]
        if quote:
            buf.append(ch)
            if ch == quote and (i == 0 or text[i - 1] != "\\"):
                quote = ""
        elif ch in "'\"":
            quote = ch
            buf.append(ch)
        elif ch in "([{":
            depth += 1
            buf.append(ch)
        elif ch in ")]}":
            depth -= 1
            buf.append(ch)
        elif ch == ";" and depth == 0:
            items.append("".join(buf).strip())
            buf = []
        elif ch.isspace() and depth == 0:
            if buf:
                items.append("".join(buf).strip())
                buf = []
        else:
            buf.append(ch)
        i += 1
    if buf:
        items.append("".join(buf).strip())
    return [item for item in items if item]


def format_line(line: str) -> list[str]:
    newline = line.rstrip("\n")
    indent = len(newline) - len(newline.lstrip())
    pad = " " * indent

    # `}: {` -> `}:` then `{`
    match = re.match(r"^(\s*)\}: \{\s*$", newline)
    if match:
        return [f"{match.group(1)}}}:", f"{match.group(1)}{{"]

    # key = [ ... ];
    match = re.match(r"^(\s*)(.*?=\s*)\[([^\[\]]*)\];\s*(#.*)?$", newline)
    if match and match.group(3).strip():
        items = split_items(match.group(3))
        if items:
            out = [f"{pad}{match.group(2)}["]
            out += [f"{pad}  {item}" for item in items]
            tail = f"  {match.group(4)}" if match.group(4) else ""
            out.append(f"{pad}];{tail}")
            return out

    # key = { a = 1; b = 2; };
    match = re.match(r"^(\s*)(.*?=\s*)\{([^{}]*)\};\s*(#.*)?$", newline)
    if match and match.group(3).strip():
        items = [item for item in split_items(match.group(3)) if item.endswith(";")]
        if items and len(items) > 1:
            out = [f"{pad}{match.group(2)}{{"]
            out += [f"{pad}  {item}" for item in items]
            tail = f"  {match.group(4)}" if match.group(4) else ""
            out.append(f"{pad}}};{tail}")
            return out

    return [newline]


def format_text(text: str) -> str:
    lines: list[str] = []
    for line in text.splitlines():
        lines.extend(format_line(line))
    return "\n".join(lines) + ("\n" if text.endswith("\n") else "")


def targets(args: list[str]) -> list[pathlib.Path]:
    repo = ROOT.resolve()
    if args:
        files: list[pathlib.Path] = []
        for arg in args:
            path = pathlib.Path(arg)
            if path.is_dir():
                files += [
                    child
                    for child in path.rglob("*.nix")
                    if repo in child.resolve().parents
                ]
            elif path.suffix == ".nix" and repo in path.resolve().parents:
                files.append(path)
        if files:
            return sorted(set(files))
    files = []
    for path in ROOT.rglob("*.nix"):
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        files.append(path)
    return sorted(files)


def main() -> int:
    check = "--check" in sys.argv
    args = [arg for arg in sys.argv[1:] if arg != "--check"]
    changed: list[pathlib.Path] = []
    for path in targets(args):
        if not path.exists():
            continue
        old = path.read_text(encoding="utf-8")
        new = format_text(old)
        if new != old:
            changed.append(path)
            if not check:
                path.write_text(new, encoding="utf-8")
    if check:
        for path in changed:
            print(f"style: {path}", file=sys.stderr)
        return 1 if changed else 0
    for path in changed:
        print(f"formatted {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
