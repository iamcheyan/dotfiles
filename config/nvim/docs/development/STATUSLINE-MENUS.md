# Statusline menu behavior

The clickable menus in the bottom statusline share `open_statusline_menu()` in
`lua/plugins/heirline.lua`. Keep their behavior consistent through that shared
entry point so file, encoding, LSP, mode, Git, and navigation menus receive the
same fixes.

## Focus and bar colors

Open the popup with `nvim_open_win(buf, false, ...)` so the editor buffer stays
current. Focusing the temporary, unlisted menu buffer changes BufferLine's
selected tab and makes the editor's top winbar inactive. That is why the top
bar used to turn dark while a bottom menu was open.

Because the popup does not take focus, temporarily forward menu navigation,
selection, dismissal, and wheel events from the source buffer. Save and restore
any buffer-local mappings when the popup closes. Track lifecycle events on the
source buffer and popup window; the popup itself is not the current buffer.

Keep menu-open state (`_statusline_menu_id`) separate from statusline styling.
Opening a menu must not recolor the clicked statusline component. The popup's
selected row can continue to use the theme's `PmenuSel` highlight.

## Popup surface and scrolling

The source editor enables a cursor-column guide, so a minimal float inherits it
unless it is explicitly disabled. Set `cursorcolumn = false` and
`signcolumn = "no"` on the popup to remove the bright strip at the left edge.
Clear inherited `winbar`, `wrap`, and scroll margins as well.

Set popup height to the smaller of its row count and the space above the
statusline. Intercept wheel events over the popup: consume them when every row
fits, and move the popup viewport only when rows overflow. Wheel events outside
the popup should close it and replay the event after restoring source mappings.

## Regression check

Run `python3 config/nvim/tests/statusline_menu_ui_spec.py` from the dotfiles
repository. The attached-UI check covers unchanged source focus and bar state,
the absence of the inherited cursor marker, no scrolling for a fitting menu,
scrolling for an overflowing menu, and mouse selection.
