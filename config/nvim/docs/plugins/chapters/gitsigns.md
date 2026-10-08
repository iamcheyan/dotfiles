# gitsigns.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在行号旁显示 Git 新增、修改、删除标记，并提供 hunk 操作。

## 在当前配置里怎么用

`[h`/`]h` 跳前后 hunk；`<leader>gp` 预览，`<leader>gs` 暂存 hunk，`<leader>gr` 重置 hunk；`<leader>gS` 暂存文件，`<leader>gR` 重置文件，`<leader>gu` 取消暂存，`<leader>gb` 当前行 blame，`<leader>gB` 文件 blame。

## 动手练习

在 Git 项目里修改一行并保存，观察行号旁标记；按 `<leader>gp` 预览；用 `<leader>gs` 暂存，再运行 `git diff --cached` 或查看 Neo-tree 状态确认。

## 注意事项

重置会丢弃修改，执行 `<leader>gr`/`<leader>gR` 前检查预览；文件必须位于 Git 仓库。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
