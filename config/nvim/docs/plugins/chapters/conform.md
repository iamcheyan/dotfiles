# conform.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

调用外部 formatter 格式化当前文件或选区。

## 在当前配置里怎么用

手动格式化按 `<leader>F`；`:ConformInfo` 查看当前 filetype 的 formatter；`<leader>uf` 切换保存时格式化，`<leader>uF` 切换到相反状态。配置按语言选择 stylua、shfmt、Ruff、Prettier、rustfmt、gofumpt 等。

## 动手练习

先在 Git 项目中打开一个格式略乱的 Lua 文件，运行 `:ConformInfo` 确认 formatter，再按 `<leader>F` 并查看 diff；可以用 `u` 撤销。之后运行 `<leader>uf` 开启保存格式化，再切回 `<leader>uf`。

## 注意事项

formatter 必须安装并在 PATH 中可用；保存格式化默认关闭。格式化会改文件，先查看 diff。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
