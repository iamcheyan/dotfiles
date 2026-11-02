#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
lf_files="$repo_root/config/lf"

if ! command -v lf >/dev/null 2>&1; then
    printf 'lf is required to validate its config\n' >&2
    exit 1
fi

lf -config "$lf_files/lfrc" -doc >/dev/null
printf 'lf config parser: OK\n'
