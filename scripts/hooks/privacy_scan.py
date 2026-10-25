#!/usr/bin/env python3
"""Fail-closed privacy scan for staged files and outgoing GitHub commits.

Reports finding categories and locations only; never prints matched values.
"""
from __future__ import annotations

import functools
import os
import re
import subprocess
import sys
from pathlib import Path

PATTERNS = [
    ("private-key", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----", re.I)),
    ("provider-token", re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{15,})\b")),
    ("credential-assignment", re.compile(r"(?i)(?:\b|_)(?:api[_ -]?key|access[_ -]?token|auth[_ -]?token|client[_ -]?secret|password|passwd|secret)(?:\b|_)\s*[:=]\s*[\"']?([A-Za-z0-9._/+~=-]{8,})")),
    ("authorization-value", re.compile(r"(?i)\b(?:bearer|basic)\s+[A-Za-z0-9._~+/=-]{12,}")),
    ("credential-url", re.compile(r"(?i)://[^/\s:@]+:[^/\s@]{8,}@")),
    ("personal-filesystem-path", re.compile(r"(?i)(?:/home/[^/\s`'\"]+|/users/[^/\s`'\"]+|[A-Z]:\\Users\\[^\\\s]+)")),
    ("private-mount-path", re.compile(r"(?i)/(?:data/)?NAS(?:/|\b)|/(?:mnt|media)/[^/\s`'\"]*(?:nas|private)(?:/|\b)")),
    ("private-network-address", re.compile(r"(?<![\d.])(?:10\.(?:\d{1,3}\.){2}\d{1,3}|192\.168\.(?:\d{1,3}\.)\d{1,3}|172\.(?:1[6-9]|2\d|3[01])\.(?:\d{1,3}\.)\d{1,3})(?![\d.])")),
    ("email-address", re.compile(r"(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b")),
    ("phone-number", re.compile(r"(?<!\d)(?:\+\d{1,3}[ .-]?)?(?:0[789]0|0[1-9]\d{0,2})[- .]\d{3,4}[- .]\d{4}(?!\d)")),
]
SAFE_EMAIL_DOMAINS = ("example.com", "example.org", "example.net", "users.noreply.github.com")
PLACEHOLDERS = {"placeholder", "changeme", "change-me", "your-key-here", "your-token-here", "redacted", "xxx", "xxxxxxxx", "example", "dummy", "test-value"}
MAX_BYTES = 32 * 1024 * 1024
BINARY_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".ico", ".icns",
    ".mp3", ".m4a", ".ogg", ".wav", ".mp4", ".mov", ".avi", ".webm",
    ".zip", ".gz", ".7z", ".rar", ".woff", ".woff2", ".ttf", ".otf",
}


def git(*args: str, data: bytes | None = None) -> bytes:
    p = subprocess.run(["git", *args], input=data, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if p.returncode:
        raise RuntimeError(p.stderr.decode("utf-8", "replace").strip() or f"git {' '.join(args)} failed")
    return p.stdout


def safe_email_match(match: re.Match[str]) -> bool:
    value = match.group(0).lower()
    domain = value.rsplit("@", 1)[-1]
    return domain in SAFE_EMAIL_DOMAINS or domain.endswith(".example")


@functools.lru_cache(maxsize=1)
def private_identifiers() -> list[str]:
    values = [os.environ.get("USER", ""), Path.home().name, *os.environ.get("GIT_PRIVACY_DENYLIST", "").splitlines()]
    for scope in ("--global", "--local"):
        for key in ("user.name", "user.email"):
            result = subprocess.run(["git", "config", scope, "--get", key], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            if result.returncode == 0:
                values.append(result.stdout.decode("utf-8", "replace").strip())
    allowed = set(os.environ.get("GIT_PRIVACY_PUBLIC_IDENTIFIERS", "").splitlines())
    allowed.update(subprocess.run(["git", "config", "--get-all", "privacy.public-identifiers"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL).stdout.decode("utf-8", "replace").splitlines())
    return [value for value in dict.fromkeys(value.strip() for value in values if len(value.strip()) >= 3) if value not in allowed]


def findings(path: str, content: bytes) -> list[tuple[str, int]]:
    if Path(path).suffix.lower() in BINARY_SUFFIXES or b"\0" in content[:8192]:
        return []
    # The scanner's own pattern definitions contain literal path examples;
    # scanning itself would always self-flag.
    if Path(path).name.replace("-", "_") == "privacy_scan.py":
        return []
    if len(content) > MAX_BYTES:
        return [("oversize-file-review-required", 1)]
    text = content.decode("utf-8", "replace")
    result: list[tuple[str, int]] = []
    for category, regex in PATTERNS:
        for match in regex.finditer(text):
            if category == "email-address" and safe_email_match(match):
                continue
            if category == "credential-assignment":
                value = match.group(1).strip("'\".,;: ").lower()
                if value in PLACEHOLDERS or value.startswith(("your_", "${", "$", "<")):
                    continue
            result.append((category, text.count("\n", 0, match.start()) + 1))
    folded = text.casefold()
    if not path.startswith("<commit-identity>"):
        for identity in private_identifiers():
            index = folded.find(identity.casefold())
            if index >= 0:
                result.append(("local-personal-identifier", text.count("\n", 0, index) + 1))
    return result


def staged_files() -> dict[str, bytes]:
    names = git("diff", "--cached", "--name-only", "--diff-filter=ACMR", "-z").split(b"\0")
    out: dict[str, bytes] = {}
    for raw in names:
        if not raw:
            continue
        path = raw.decode("utf-8", "surrogateescape")
        try:
            out[path] = git("show", f":{path}")
        except RuntimeError:
            continue
    return out


def commit_files(commit: str) -> dict[str, bytes]:
    names = git("diff-tree", "--no-commit-id", "--name-only", "--diff-filter=ACMR", "-r", "-z", commit).split(b"\0")
    out: dict[str, bytes] = {}
    for raw in names:
        if not raw:
            continue
        path = raw.decode("utf-8", "surrogateescape")
        try:
            out[path] = git("show", f"{commit}:{path}")
        except RuntimeError:
            continue
    return out


def tip_files(sha: str) -> dict[str, bytes]:
    names = git("ls-tree", "-r", "--name-only", "-z", sha).split(b"\0")
    out: dict[str, bytes] = {}
    for raw in names:
        if not raw:
            continue
        path = raw.decode("utf-8", "surrogateescape")
        try:
            out[path] = git("show", f"{sha}:{path}")
        except RuntimeError:
            continue
    return out


def scan(files: dict[str, bytes], label: str) -> list[str]:
    errors: list[str] = []
    for path, content in files.items():
        for category, line in findings("<path-name>", path.encode("utf-8", "replace")):
            errors.append(f"{label}: {path}: {category}")
        for category, line in findings(path, content):
            errors.append(f"{label}: {path}:{line}: {category}")
    return errors


def scan_commit_message(message_path: str) -> int:
    message = Path(message_path).read_bytes()
    identity = git("var", "GIT_AUTHOR_IDENT") + git("var", "GIT_COMMITTER_IDENT")
    errors = scan({"<commit-message>": message}, "commit-message")
    errors.extend(scan({"<commit-identity>": identity}, "commit-identity"))
    if errors:
        print("Privacy scan blocked commit; matched values are intentionally hidden:", file=sys.stderr)
        print("\n".join(errors), file=sys.stderr)
        return 1
    return 0


def scan_staged() -> int:
    files = staged_files()
    errors = scan(files, "staged")
    if errors:
        print("Privacy scan blocked commit; matched values are intentionally hidden:", file=sys.stderr)
        print("\n".join(errors), file=sys.stderr)
        print("Remove personal/private data or credentials, then rerun the commit.", file=sys.stderr)
        return 1
    print(f"Privacy scan passed for {len(files)} staged file(s).")
    print("Manual review is still required for personally identifying names, narrative context, and generated/published artifacts.")
    return 0


def scan_commit_metadata(commit: str) -> list[str]:
    identity = git("show", "-s", "--format=%an%n%ae%n%cn%n%ce", commit)
    message = git("show", "-s", "--format=%B", commit)
    label = f"outgoing {commit[:12]}"
    errors = scan({"<commit-identity>": identity}, label)
    errors.extend(scan({"<commit-message>": message}, label))
    return errors


def scan_push() -> int:
    lines = sys.stdin.buffer.read().splitlines()
    failed = False
    for line in lines:
        parts = line.split()
        if len(parts) < 4:
            continue
        local_ref, local_sha, remote_ref, remote_sha = [p.decode("utf-8", "replace") for p in parts[:4]]
        ref_errors = scan({"<ref-name>": (local_ref + " " + remote_ref).encode()}, "ref")
        if ref_errors:
            failed = True
            print("Privacy scan blocked push; matched values are intentionally hidden:", file=sys.stderr)
            print("\n".join(ref_errors), file=sys.stderr)
        if set(local_sha) == {"0"}:
            continue
        commits = git("rev-list", local_sha, "--not", remote_sha).decode().splitlines() if set(remote_sha) != {"0"} else git("rev-list", local_sha).decode().splitlines()
        errors: list[str] = []
        for commit in commits:
            errors.extend(scan(commit_files(commit), f"outgoing {commit[:12]}"))
            errors.extend(scan_commit_metadata(commit))
        if errors:
            failed = True
            print("Privacy scan blocked push; matched values are intentionally hidden:", file=sys.stderr)
            print("\n".join(errors), file=sys.stderr)
    if failed:
        print("Remove findings from outgoing commits; rerun the push.", file=sys.stderr)
        return 1
    print("Privacy scan passed for outgoing commits.")
    print("Manual review is still required for personally identifying names, narrative context, and generated/published artifacts.")
    return 0


def scan_all() -> int:
    sha = git("rev-parse", "HEAD").decode().strip()
    errors = scan(tip_files(sha), f"full-tree {sha[:12]}")
    if errors:
        print("Full repository scan found findings; matched values are intentionally hidden:", file=sys.stderr)
        limit = 100
        print("\n".join(errors[:limit]), file=sys.stderr)
        if len(errors) > limit:
            print(f"... {len(errors) - limit} additional findings omitted", file=sys.stderr)
        return 1
    print("Full repository privacy scan passed.")
    return 0


if __name__ == "__main__":
    try:
        mode = sys.argv[1] if len(sys.argv) > 1 else "--staged"
        if mode == "--staged":
            sys.exit(scan_staged())
        if mode == "--push":
            sys.exit(scan_push())
        if mode == "--all":
            sys.exit(scan_all())
        if mode == "--commit-msg" and len(sys.argv) > 2:
            sys.exit(scan_commit_message(sys.argv[2]))
        sys.exit(2)
    except Exception as exc:
        print(f"Privacy scan failed closed: {type(exc).__name__}: {exc}", file=sys.stderr)
        sys.exit(2)
