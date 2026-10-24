"""Ranger colors based on the Neovim Blue / Nostalgia palette."""

from ranger.colorschemes.default import Default
from ranger.gui.color import (
    black,
    bold,
    cyan,
    dim,
    green,
    red,
    reverse,
    white,
    yellow,
    BRIGHT,
)


class Scheme(Default):
    progress_bar_color = green

    def use(self, context):
        fg, bg, attr = super().use(context)

        if context.in_browser:
            # Give ordinary files an explicit theme color instead of inheriting
            # Ranger's default white/gray foreground.
            fg = green + BRIGHT
            if context.selected:
                # Cyan is the theme's selection accent; use dark text on it.
                fg, bg = black, cyan
                attr &= ~reverse
                attr |= bold
            elif context.directory:
                fg = cyan + BRIGHT
            elif context.executable and not any(
                (context.media, context.container, context.fifo, context.socket)
            ):
                fg = green + BRIGHT
            elif context.inactive_pane:
                fg = cyan

            if context.vcsfile and not context.selected:
                if context.vcsconflict:
                    fg = red + BRIGHT
                elif context.vcsuntracked:
                    fg = yellow + BRIGHT
                elif context.vcschanged:
                    fg = yellow
                elif context.vcsstaged or context.vcssync:
                    fg = green + BRIGHT
                elif context.vcsignored:
                    fg = green + BRIGHT
                    attr |= dim

        elif context.in_titlebar:
            if context.hostname:
                fg = red + BRIGHT if context.bad else green + BRIGHT
            elif context.directory:
                fg = yellow + BRIGHT
            elif context.tab and context.good:
                fg, bg = black, green
            elif context.link:
                fg = cyan + BRIGHT

        elif context.in_statusbar:
            # Match Neovim's teal status surface.
            fg, bg = black, cyan
            if context.message and context.bad:
                fg, bg = white, red
            elif context.marked:
                fg, bg = black, yellow
                attr |= bold
            elif context.frozen:
                fg, bg = black, cyan
                attr |= bold
            elif context.loaded:
                bg = green

        elif context.in_taskview:
            if context.title:
                fg = cyan + BRIGHT
            if context.selected:
                fg, bg = black, cyan
                attr &= ~reverse
                attr |= bold
            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        return fg, bg, attr
