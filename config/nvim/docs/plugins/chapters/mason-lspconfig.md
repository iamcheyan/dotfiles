# mason-lspconfig.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

连接 Mason 安装的 LSP 服务器与 Neovim LSP 配置。它主要在后台工作。

## 在当前配置里怎么用

日常无需直接操作。先用 `:Mason` 安装服务器，再打开相应语言文件；通过 `:LspInfo` 查看该服务器是否附加。服务器名可能与 Mason 包名不同，映射由本插件协调。

## 动手练习

安装或确认 `lua-language-server` 已就绪，打开一个 `.lua` 文件，运行 `:LspInfo`；确认出现 lua_ls 后在 `vim.` 上触发补全或对符号按 `gd`。

## 注意事项

如果服务器未连接，检查可执行文件、文件类型和项目根目录；本插件不会替语言服务器实现语义功能。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
