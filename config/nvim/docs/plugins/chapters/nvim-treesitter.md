# nvim-treesitter

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

使用语法树为代码提供结构高亮、折叠、文本对象等基础能力。

## 在当前配置里怎么用

检查安装 parser 用 `:TSInstallInfo`；安装语言用 `:TSInstall lua`；升级或重建用 `:TSUpdate`；查看日志用 `:TSLog`。本配置 parser 安装到 Neovim site parser 目录。

## 动手练习

打开一份 Lua 文件并观察语法高亮；运行 `:TSInstallInfo` 找一种尚未安装但常用的语言；如要安装，使用 `:TSInstall <语言名>`，再打开该语言文件。

## 注意事项

最低 Neovim 0.11；Treesitter 与 textobjects 固定 `main`。换分支或跨版本升级后运行 `:TSUpdate` 重建 parser。细节看[Treesitter 配置说明](../../reference/TREESITTER.md)。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
