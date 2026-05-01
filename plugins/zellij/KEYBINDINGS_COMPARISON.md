# Zellij Default Keybindings Guide

This document uses the official Zellij default keybindings as the main learning path, and only adds the few extra bindings you keep on top.

Current state:

- Your Zellij keybindings are now back to the official defaults
- You can learn Zellij by following the default keybindings only
- Going forward, your rule is: add bindings, but do not change default bindings

Reference environment:

- Zellij version: `0.43.1`
- Default config source: `zellij setup --dump-config`
- Current config file: [`config/zellij/config.kdl`](${DOTFILES_DIR:-$HOME/dotfiles}/config/zellij/config.kdl)

Official docs:

- https://zellij.dev/documentation/keybindings
- https://zellij.dev/documentation/keybinding-presets
- https://zellij.dev/documentation/keybindings-possible-actions.html

## Core Idea

The main thing to learn in Zellij is not a random list of shortcuts. The real model is:

- enter a mode
- use `h/j/k/l` or arrow keys inside that mode
- return to `normal` with `Esc` or `Enter`

The most important modes are:

- `pane`: switch panes, create panes, close panes
- `move`: move pane positions
- `resize`: resize panes
- `tab`: switch tabs, create tabs, close tabs
- `scroll`: scroll back through pane history
- `search`: search inside scrollback
- `session`: session management
- `tmux`: tmux-compatible mode

## The First 10 Keys To Memorize

1. `Ctrl+p`: enter `pane` mode
2. `Ctrl+h`: enter `move` mode
3. `Ctrl+n`: enter `resize` mode
4. `Ctrl+t`: enter `tab` mode
5. `Ctrl+s`: enter `scroll` mode
6. `Ctrl+o`: enter `session` mode
7. `Ctrl+b`: enter `tmux` mode
8. `Alt+h/j/k/l`: quickly move focus between panes or tabs
9. `Alt+n`: create a new pane directly
10. `Esc` / `Enter`: exit most modes

## Global Shared Keybindings

These are available in most modes.

| Shortcut | Action |
|---|---|
| `Ctrl+g` | Enter `locked` mode |
| `Ctrl+p` | Enter `pane` mode |
| `Ctrl+n` | Enter `resize` mode |
| `Ctrl+s` | Enter `scroll` mode |
| `Ctrl+o` | Enter `session` mode |
| `Ctrl+t` | Enter `tab` mode |
| `Ctrl+h` | Enter `move` mode |
| `Ctrl+b` | Enter `tmux` mode |
| `Ctrl+q` | Quit Zellij |
| `Enter` / `Esc` | Return to `normal` |
| `Alt+n` | Create a new pane directly |
| `Alt+h` / `Alt+Left` | Move focus left, or move across tabs if needed |
| `Alt+l` / `Alt+Right` | Move focus right, or move across tabs if needed |
| `Alt+j` / `Alt+Down` | Move focus down |
| `Alt+k` / `Alt+Up` | Move focus up |
| `Alt+i` | Move tab left |
| `Alt+o` | Move tab right |
| `Alt+=` / `Alt++` | Increase size |
| `Alt+-` | Decrease size |
| `Alt+[` | Previous layout |
| `Alt+]` | Next layout |
| `Alt+f` | Toggle floating panes |
| `Alt+p` | Toggle pane group |
| `Alt+Shift+p` | Toggle group marking |

## `pane` Mode

Enter with: `Ctrl+p`

| Shortcut | Action |
|---|---|
| `Ctrl+p` | Exit `pane` mode |
| `h/j/k/l` or arrow keys | Move focus between panes |
| `n` | Create a new pane |
| `d` | Split downward |
| `r` | Split right |
| `s` | Create a stacked pane |
| `x` | Close the current pane |
| `f` | Toggle fullscreen for the current pane |
| `z` | Toggle pane frames |
| `w` | Toggle floating panes |
| `e` | Toggle embedded / floating for the current pane |
| `c` | Rename pane |
| `i` | Pin pane |
| `p` | Switch focus |

## `move` Mode

Enter with: `Ctrl+h`

| Shortcut | Action |
|---|---|
| `Ctrl+h` | Exit `move` mode |
| `h/j/k/l` or arrow keys | Move the current pane in that direction |
| `n` / `Tab` | Cycle to the next move option |
| `p` | Move backwards |

Example: move the right pane to the left side

1. Focus the right pane
2. Press `Ctrl+h`
3. Press `h`

## `resize` Mode

Enter with: `Ctrl+n`

| Shortcut | Action |
|---|---|
| `Ctrl+n` | Exit `resize` mode |
| `h/j/k/l` or arrow keys | Increase in that direction |
| `H/J/K/L` | Decrease in that direction |
| `=` / `+` | Increase overall |
| `-` | Decrease overall |

## `tab` Mode

Enter with: `Ctrl+t`

| Shortcut | Action |
|---|---|
| `Ctrl+t` | Exit `tab` mode |
| `h/k/Left/Up` | Previous tab |
| `l/j/Right/Down` | Next tab |
| `n` | New tab |
| `x` | Close tab |
| `r` | Rename tab |
| `s` | Toggle tab sync input |
| `b` | Break the current pane into a new tab |
| `[` | Break the current pane to the tab on the left |
| `]` | Break the current pane to the tab on the right |
| `1..9` | Jump to tab by number |
| `Tab` | Toggle tab |

## `scroll` Mode

Enter with: `Ctrl+s`

| Shortcut | Action |
|---|---|
| `Ctrl+s` | Return to `normal` |
| `Ctrl+c` | Scroll to bottom and return to `normal` |
| `e` | Open scrollback in your editor |
| `s` | Enter search input |
| `j/k` or arrow keys | Scroll down / up |
| `Ctrl+f` / `PageDown` / `l` / `Right` | Page down |
| `Ctrl+b` / `PageUp` / `h` / `Left` | Page up |
| `d` | Half page down |
| `u` | Half page up |
| `Esc` / `Enter` | Return to `normal` |

## `search` Mode

| Shortcut | Action |
|---|---|
| `n` | Next match |
| `p` | Previous match |
| `c` | Toggle case sensitivity |
| `w` | Toggle wrap |
| `o` | Toggle whole word |
| `j/k` or arrow keys | Scroll |
| `Ctrl+f` / `PageDown` / `l` / `Right` | Page down |
| `Ctrl+b` / `PageUp` / `h` / `Left` | Page up |
| `d` | Half page down |
| `u` | Half page up |
| `Ctrl+s` / `Ctrl+c` / `Esc` / `Enter` | Exit or return through the normal flow |

## `session` Mode

Enter with: `Ctrl+o`

| Shortcut | Action |
|---|---|
| `Ctrl+o` | Return to `normal` |
| `d` | Detach |
| `w` | Open session manager |
| `c` | Open configuration |
| `p` | Open plugin manager |
| `a` | Open about |
| `s` | Open share |

## `tmux` Mode

Enter with: `Ctrl+b`

| Shortcut | Action |
|---|---|
| `[` | Enter scroll mode |
| `Ctrl+b` | Send the prefix key itself |
| `"` | Split downward |
| `%` | Split right |
| `z` | Toggle fullscreen for the current pane |
| `c` | New tab |
| `,` | Rename tab |
| `p` | Previous tab |
| `n` | Next tab |
| `h/j/k/l` or arrow keys | Move focus between panes |
| `o` | Focus next pane |
| `d` | Detach |
| `Space` | Next layout |
| `x` | Close the current pane |

## Rename And Search Input Modes

### `renametab`

| Shortcut | Action |
|---|---|
| `Ctrl+c` | Return to `normal` |
| `Esc` | Cancel and return to `tab` |

### `renamepane`

| Shortcut | Action |
|---|---|
| `Ctrl+c` | Return to `normal` |
| `Esc` | Cancel and return to `pane` |

### `entersearch`

| Shortcut | Action |
|---|---|
| `Ctrl+c` / `Esc` | Return to `scroll` |
| `Enter` | Enter `search` |

## Your Extra Bindings

These three are not part of the official defaults. They are the additions you keep on top of the default layout.

| Location | Shortcut | Action |
|---|---|---|
| Global shared bindings | no `Ctrl+q` | You intentionally removed the default quit shortcut |
| `tab` mode | `a` | Open `zellij-pane-picker` |
| `session` mode | `x` | Quit Zellij directly |

## Learning Advice

Your learning path can now stay simple:

1. Treat the official default keybindings as the primary model
2. Only memorize the three extra bindings at the end

This keeps your setup easy to maintain and close to upstream behavior.
