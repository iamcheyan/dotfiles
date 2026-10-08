# nvim-lspconfig

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

把 Neovim 内置 LSP 客户端连接到语言服务器，提供定义、引用、重命名、悬浮文档等代码理解功能。

## 在当前配置里怎么用

服务附加后常用：`gd` 定义、`gD` 声明、`gI` 实现、`gy` 类型定义、`K` 悬浮文档、`<leader>ca` 代码操作、`<leader>cr` 重命名、`<leader>co` 整理 imports、`<leader>cl` 查看客户端。

## 动手练习

在支持的 Lua/Python 文件中将光标放在一个函数名上按 `gd`，再按 `Ctrl-o` 返回；把光标放到变量上按 `K` 看文档；试运行 `<leader>cr` 并 Esc 取消。

## 注意事项

须安装并启动对应语言服务器。用 `:LspInfo`/`:checkhealth vim.lsp` 查看连接。COBOL 的 `gd` 由私有 cobol.nvim 接管；全局诊断显示目前关闭。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
