# Hunk - Terminal diff viewer

**Hunk** is a review-first terminal diff viewer for agent-authored changesets. It provides a rich UI for diff inspection, AI/agent annotations, and more.

## Install

The repository’s init script installs Hunk automatically. You can also install it manually:

```sh
npm i -g hunkdiff
# or, if you use Homebrew
brew install modem-dev/tap/hunk
```

## Usage

```sh
hunk <command> [options]
```

### Commands
- `hunk diff [target] [-- <pathspec...>]` – review working tree changes or compare against a target.
- `hunk diff --staged` – review staged changes.
- `hunk diff <left> <right>` – compare two concrete files.
- `hunk show [target]` – review the last commit or a given target.
- `hunk stash show [ref]` – review a stash entry (git only).
- `hunk patch [file]` – review a patch file or stdin.
- `hunk pager` – general Git pager wrapper with diff detection.
- `hunk difftool <left> <right> [path]` – review Git difftool file pairs.
- `hunk session <subcommand>` – inspect or control a live Hunk session.
- `hunk skill path` – print the bundled Hunk review skill path.
- `hunk daemon serve` – run the local Hunk session daemon.

### Global options
- `-h, --help` – show help.
- `-v, --version` – show version.

### Review options
- `--mode <mode>` – layout mode (`auto`, `split`, `stack`).
- `--watch` – auto‑reload when diff input changes.
- `--pager` – use pager‑style chrome and controls.
- `--line-numbers` / `--no-line-numbers` – toggle line numbers.
- `--wrap` / `--no-wrap` – toggle line wrapping.
- `--theme <theme>` – override theme.

### Git diff options
- `--staged`, `--cached` – review staged changes.
- `--exclude-untracked` – hide untracked files.

Refer to `hunk <command> --help` for command‑specific syntax.

## Integration with dotfiles

The dotfiles wrap Hunk with a launcher script at `plugins/hunk/hunk.sh`.
That wrapper:

- loads `nvm`
- prefers the current Node version if it already has `hunk`
- falls back to the `nvm default` version
- finally falls back to any installed Node version that contains `hunk`

Shell shortcuts are provided through `aliases.conf`:

```sh
alias hunk="$HOME/dotfiles/plugins/hunk/hunk.sh"
alias hdiff='$HOME/dotfiles/plugins/hunk/hunk.sh diff'
alias hshow='$HOME/dotfiles/plugins/hunk/hunk.sh show'
```

Use `hunk`, `hdiff`, or `hshow` through those wrappers rather than relying on
the current Node version to expose `hunk` on `PATH`.

## Further resources

- Repository: https://github.com/modem-dev/hunk
- Full documentation: https://github.com/modem-dev/hunk/blob/main/README.md
