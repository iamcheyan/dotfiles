"""Exercise installation without touching host package managers or Python."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]

class PipxInstallTests(unittest.TestCase):
    def run_install(self, manager, args, installed=False, fail=False):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            binaries = base / 'bin'
            binaries.mkdir()
            log = base / 'calls'
            def executable(name, body):
                path = binaries / name
                path.write_text('#!/bin/bash\n' + body)
                path.chmod(0o755)
            executable('sudo', 'exec "$@"\n')
            executable('pipx-template', 'echo "pipx $*" >> "$CALLS"\n')
            executable(manager, 'echo "' + manager + ' $*" >> "$CALLS"\n' +
                       ('exit 1\n' if fail else '/bin/cp "$BIN/pipx-template" "$BIN/pipx"\n'))
            executable('python3', 'echo forbidden-python >> "$CALLS"; exit 99\n')
            if installed:
                executable('vd', 'exit 0\n')
            env = dict(os.environ, HOME=str(base / 'user'), PATH=str(binaries),
                       CALLS=str(log), BIN=str(binaries))
            result = subprocess.run(['/bin/bash', str(ROOT / 'scripts/install/install_pipx_tool.sh'),
                                     *args], env=env, text=True, capture_output=True)
            return result, log.read_text() if log.exists() else ''

    def test_arch_bootstraps_pipx_and_installs_visidata(self):
        result, calls = self.run_install('pacman', ['visidata', 'vd'])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn('pacman -S --needed --noconfirm python-pipx', calls)
        self.assertIn('pipx ensurepath', calls)
        self.assertIn('pipx install visidata', calls)
        self.assertNotIn('python', calls.replace('python-pipx', ''))

    def test_fedora_and_debian_use_packages(self):
        for manager in ['dnf', 'apt-get', 'brew']:
            with self.subTest(manager=manager):
                result, calls = self.run_install(manager, ['toolong', 'tl'])
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn('pipx ensurepath', calls)
                self.assertIn('pipx install toolong', calls)
                self.assertNotIn('forbidden-python', calls)

    def test_existing_app_skips_bootstrap(self):
        result, calls = self.run_install('pacman', ['visidata', 'visidata', 'vd'], installed=True)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(calls, '')

    def test_package_failure_never_falls_back_to_pip(self):
        result, calls = self.run_install('pacman', ['toolong', 'tl'], fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('forbidden-python', calls)
        self.assertNotIn('pipx install', calls)

    def test_httpie_pip_requires_virtual_environment(self):
        for virtual in [False, True]:
            with self.subTest(virtual=virtual), tempfile.TemporaryDirectory() as tmp:
                base = Path(tmp)
                python = base / 'python3'
                log = base / 'calls'
                python.write_text('#!/bin/bash\nif [[ "$1" == -c ]]; then exit ' +
                                  ('0' if virtual else '1') +
                                  '; fi\necho "$*" >> "$CALLS"\n')
                python.chmod(0o755)
                env = dict(os.environ, PATH=tmp, CALLS=str(log))
                result = subprocess.run(['/bin/bash', str(ROOT / 'scripts/install/install_httpie.sh'),
                                         '--method', 'pip'], env=env, capture_output=True)
                self.assertEqual(result.returncode == 0, virtual)
                if virtual:
                    self.assertIn('-m pip install --upgrade httpie', log.read_text())
                    self.assertNotIn('--user', log.read_text())
                else:
                    self.assertFalse(log.exists())

if __name__ == '__main__':
    unittest.main()
