# diffview.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

用分屏视图审查分支差异和 Git 文件历史。

## 在当前配置里怎么用

`<leader>gd` 或 `<leader>gv` 打开与基线的差异；`<leader>gD` 看当前文件历史；`<leader>gV` 看仓库历史；`<leader>gq` 关闭。命令是 `:DiffviewOpen`、`:DiffviewFileHistory`、`:DiffviewClose`。

## 动手练习

在有提交记录的仓库执行 `<leader>gD` 查看当前文件历史；选一条历史记录比较；按 `<leader>gq` 关闭。随后用 `<leader>gd` 查看工作分支差异。

## 注意事项

需要 Git 仓库和可比较的提交。此处 `<leader>gd` 是 Git 差异；不带 leader 的 `gd` 是定义跳转。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
