# mason.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在 Neovim 内安装和管理语言服务器、格式化器、调试器等外部工具。

## 在当前配置里怎么用

运行 `:Mason` 或 `<leader>cm` 打开界面；搜索包名，Enter 查看详情，`i` 安装、`X` 卸载、`U` 更新（以界面底部提示为准）。当前配置重点管理 basedpyright、lua_ls，以及 shfmt、stylua。

## 动手练习

运行 `:Mason`，搜索 `lua-language-server`，查看它的安装状态；再搜索 `stylua`。先不要卸载，练习按 Esc 退出并用 `:Mason` 再打开。

## 注意事项

Mason 安装的是外部可执行程序；插件规格可能自动安装部分工具。确认项目和机器需要后再卸载已有包。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
