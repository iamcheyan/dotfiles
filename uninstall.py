#!/usr/bin/env python3
"""Preview or remove this checkout's dotlink links and generated files."""
import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent


def links(home):
    rules = ROOT / 'dotlink' / 'dotlinkrc'
    section = ''
    for line in rules.read_text().splitlines():
        line = re.split(r'\s*#', line, maxsplit=1)[0].strip()
        if line.startswith('[') and line.endswith(']'):
            section = line[1:-1].split(':', 1)[0]
        elif section == 'link' and ':' in line:
            left, right = (part.strip().replace('\\ ', ' ') for part in line.split(':', 1))
            if not left.startswith('$HOME/dotfiles/') or not right.startswith('$HOME/'):
                continue
            source = ROOT / left[len('$HOME/dotfiles/'):]
            target = home / right[len('$HOME/'):]
            if '*' in source.name and not any(c in str(source.parent) for c in '*?['):
                for entry in source.parent.glob(source.name):
                    yield entry, target / entry.name
            elif not any(c in str(source) for c in '*?['):
                yield source, target
    # Older deployments also linked the legacy tmux config directly.
    yield ROOT / 'config/tmux/tmux.conf', home / '.tmux.conf'


def generated():
    scopes = ['build/site', ':(glob)**/__pycache__/*.pyc']
    result = subprocess.check_output(['git', '-C', str(ROOT), 'ls-files', '-z',
                                      '--others', '--ignored', '--exclude-standard', '--', *scopes])
    for name in filter(None, result.split(b'\0')):
        path = ROOT / os.fsdecode(name)
        if path.parent.resolve() == path.parent and not path.is_symlink() and path.is_file():
            yield path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true', help='perform the previewed operations')
    parser.add_argument('--clean-only', action='store_true', help='only remove ignored generated files')
    parser.add_argument('--clean', action='store_true', help='also remove ignored generated files')
    args = parser.parse_args()
    home = Path.home().resolve()
    if os.geteuid() == 0 or home == Path('/') or home.is_relative_to(ROOT):
        parser.error('run as the owner of a normal HOME outside the checkout')
    backup = None
    if not args.clean_only:
        seen = set()
        for source, target in links(home):
            if target in seen or not target.is_symlink() or '..' in target.parts:
                continue
            if not target.is_relative_to(home) or target.parent.resolve() != target.parent:
                continue
            # Compare the immediate link destination, not the final referent of
            # a chain. Never take ownership of links to a standalone editor.
            destination = Path(os.path.normpath(target.parent / os.readlink(target)))
            if destination != source or not destination.is_relative_to(ROOT):
                continue
            seen.add(target)
            print('Archive link:', target.relative_to(home))
            if args.apply:
                if backup is None:
                    backup = Path(tempfile.mkdtemp(prefix='.dotfiles-uninstall-', dir=home))
                    print('Backup:', backup, flush=True)
                saved = backup / target.relative_to(home)
                saved.parent.mkdir(parents=True, exist_ok=True)
                # Keep the same referent even when the original link was relative.
                saved.symlink_to(destination)
                target.unlink()
    if args.clean or args.clean_only:
        count = size = 0
        for path in generated():
            count += 1
            size += path.stat().st_size
            print('Generated:', path.relative_to(ROOT))
            if args.apply:
                path.unlink()
        print(f'{"Removed" if args.apply else "Would remove"} {count} generated files ({size} bytes).')
    if not args.apply:
        print('Preview only. Add --apply to make changes.')


if __name__ == '__main__':
    main()
