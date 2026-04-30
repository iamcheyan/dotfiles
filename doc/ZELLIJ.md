# Zellij Notes

This file is a practical reference for the current local Zellij setup.

## Current Setup

- Config file: `~/dotfiles/config/zellij/config.kdl`
- Layout directory: `~/dotfiles/config/zellij/layouts/`
- Current default layout: `compact-zjstatus`
- Current custom layouts:
  - `clean`
  - `compact-float`
  - `compact-zjstatus`
  - `zjstatus-setup`
  - `nvim-float`
- Local plugin binaries:
  - `notepad.wasm`
  - `zellij-attention.wasm`
  - `zellij-newtab-plus.wasm`
  - `zellij-pane-picker.wasm`
  - `zellij-switch.wasm`
  - `zjstatus.wasm`
- Plugin usage guide: `~/dotfiles/doc/ZELLIJ-PLUGINS.md`

Your config uses `clear-defaults=true`, so the keybindings below are the ones that actually matter.

## Core Concepts

- `session`: a long-lived workspace, similar to a tmux session
- `tab`: a tab inside a session
- `pane`: a split inside a tab
- `mode`: Zellij uses modal keybindings, so many keys only work after entering a mode

In your setup, the usual workflow is:

1. Enter a mode with `Ctrl+p`, `Ctrl+t`, `Ctrl+n`, `Ctrl+h`, `Ctrl+s`, or `Ctrl+o`
2. Do the action
3. Most actions return to normal mode automatically

## Session Commands

- Start or attach to `main`:

```bash
ze
```

- Start or attach to a named session:

```bash
zec my-session
```

- Start or attach to `tmp`:

```bash
zetmp
```

- List sessions:

```bash
zellij ls
```

- Attach to a session:

```bash
zellij attach SESSION_NAME
```

- Create a session if it does not exist:

```bash
zellij attach -c SESSION_NAME
```

- Delete exited sessions:

```bash
zeclear
```

- Kill a specific session:

```bash
zellij delete-session SESSION_NAME
```

- Kill all sessions:

```bash
zellij delete-all-sessions
```

## Layout Commands

- Start with built-in `default`:

```bash
zellij -l default
```

- Start with built-in `compact`:

```bash
zellij -l compact
```

- Start with built-in `classic`:

```bash
zellij -l classic
```

- Start with custom `clean`:

```bash
zellij -l clean
```

- Start a new named session with a layout:

```bash
zellij -s work -n clean
```

Notes:

- `default`: top tab bar + bottom status bar
- `compact`: one compact bar at the bottom
- `classic`: top tab bar + classic bottom status bar
- `clean`: no top tab bar, no bottom status bar, only the pane area

## Mode Keys

- `Ctrl+g`: locked mode
- `Ctrl+p`: pane mode
- `Ctrl+t`: tab mode
- `Ctrl+n`: resize mode
- `Ctrl+h`: move mode
- `Ctrl+s`: scroll mode
- `Ctrl+o`: session mode
- `Ctrl+b`: tmux-style mode
- `Esc`: back to normal mode
- `Enter`: back to normal mode in several input/search modes

## Global Keys

These work outside most special modes.

- `Alt+h/j/k/l`: move focus left/down/up/right
- `Alt+n`: create a new pane
- `Alt+f`: toggle zellij-notepad
- `Alt+Shift+f`: toggle floating panes
- `Alt+Shift+s`: run zellij-sessionizer
- `Alt+[` and `Alt+]`: previous/next swap layout
- `Alt+i` and `Alt+o`: move tab left/right
- `Alt+p`: toggle pane in group
- `Alt+Shift+p`: toggle group marking
- `Ctrl+q`: quit Zellij

## Pane Mode

Enter with:

```text
Ctrl+p
```

Then use:

- `h/j/k/l` or arrow keys: move focus
- `n`: new pane
- `d`: split down
- `r`: split right
- `s`: new stacked pane
- `p`: switch focus
- `c`: rename pane
- `e`: toggle embedded/floating
- `f`: toggle fullscreen
- `i`: toggle pinned pane
- `w`: show/hide floating panes
- `z`: toggle pane frames
- `x`: close focused pane

## Tab Mode

Enter with:

```text
Ctrl+t
```

Then use:

- `h/j/k/l` or arrow keys: previous/next tab
- `1` to `9`: jump to tab by index
- `n`: new tab
- `r`: rename tab
- `x`: close tab
- `s`: toggle active sync tab
- `tab`: toggle tab
- `b`: break pane into a new tab
- `[` and `]`: break pane left/right

## Resize Mode

Enter with:

```text
Ctrl+n
```

Then use:

- `h/j/k/l` or arrow keys: resize
- `H/J/K/L`: resize in the opposite direction
- `+`, `-`, `=`: grow or shrink

## Move Mode

Enter with:

```text
Ctrl+h
```

Then use:

- `h/j/k/l` or arrow keys: move pane
- `n` or `tab`: cycle/move pane
- `p`: move pane backwards

## Scroll and Search

Enter scroll mode:

```text
Ctrl+s
```

In scroll mode:

- `j/k` or arrow keys: scroll
- `u` / `d`: half page up/down
- `Ctrl+b` / `PageUp`: page up
- `Ctrl+f` / `PageDown`: page down
- `e`: edit scrollback in `$EDITOR`
- `s`: enter search input
- `Ctrl+c`: jump to bottom and return to normal mode

In search mode:

- `n`: next match
- `p`: previous match
- `c`: toggle case sensitivity
- `o`: toggle whole word
- `w`: toggle wrap

## Session Mode

Enter with:

```text
Ctrl+o
```

Then use:

- `a`: about plugin
- `c`: configuration plugin
- `p`: plugin manager
- `s`: share plugin
- `w`: session manager
- `d`: detach

Detaching is the safe way to leave a running session without killing it.

## Tmux Mode

Enter with:

```text
Ctrl+b
```

Useful keys there:

- `%`: split right
- `"`: split down
- `c`: new tab
- `[` : scroll mode
- `,`: rename tab
- `n` / `p`: next / previous tab
- `o`: focus next pane
- `z`: fullscreen

## Mouse

Your config has mouse mode enabled.

- Click panes to focus them
- Click tabs or bars when the layout shows them
- Drag pane borders to resize
- Mouse selection works with copy support enabled

## Practical Examples

- Start normal work session:

```bash
ze
```

- Start a temporary clean session:

```bash
zellij -s tmp -n clean
```

- Open a one-off clean layout:

```bash
zellij -l clean
```

- Attach to an existing session:

```bash
zellij attach main
```

- Recover an exited session:

```bash
zellij attach SESSION_NAME
```

If the session is listed as `EXITED - attach to resurrect`, attaching will resurrect it.

## Troubleshooting

- Keys do nothing:
  - You are probably in the wrong mode, or in locked mode
  - Press `Esc` or `Ctrl+g`

- You cannot use a key in Neovim or the shell:
  - Zellij may be catching it first
  - Try locked mode with `Ctrl+g`

- Session cleanup fails:
  - Use `zeclear`
  - This alias strips ANSI color codes before deleting exited sessions

- Layout does not change for an existing session:
  - Layout is applied when a session is created
  - Attaching to an existing session will not rebuild it with a new layout

- You forgot the built-in layouts:
  - `default`
  - `compact`
  - `classic`

## Files Worth Remembering

- Config: `~/dotfiles/config/zellij/config.kdl`
- Layouts: `~/dotfiles/config/zellij/layouts/`
- Aliases: `~/dotfiles/aliases/zellij.conf`
