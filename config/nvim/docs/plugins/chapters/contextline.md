# contextline.nvim

> 私有插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

为顶部上下文栏提供当前函数、类、Division/Paragraph 等层级信息和跳转菜单。

## 在当前配置里怎么用

自动随光标更新；`<leader>cb` 或 `:ContextlineMenu` 打开层级菜单，选择父级结构跳转。它优先用 LSP/navic 信息，必要时用 Treesitter 回退，并有 COBOL/Batch 适配。

## 动手练习

在包含多个函数的文件中移动光标，观察顶部上下文变化；按 `<leader>cb` 选择上层函数/类并跳转。再打开 COBOL 文件观察 Division/Paragraph 层级。

## 注意事项

可识别的层级取决于 filetype 和语言后端；没有符号信息时上下文栏可能简化。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
