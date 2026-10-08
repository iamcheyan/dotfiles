# markview.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在 Markdown、Quarto、R Markdown 等文件中渲染标题、列表、代码围栏等结构。

## 在当前配置里怎么用

打开支持的文档自动附着；`<leader>um` 切换预览。它改变显示效果，不会把渲染结果写回源文件。

## 动手练习

打开一个 Markdown 文件，观察标题和列表；按 `<leader>um` 关闭渲染并编辑原始 Markdown，再按一次恢复渲染；保存后检查文件仍是普通文本标记。

## 注意事项

若显示异常，先确认文件类型和插件状态；可用 `:set filetype?` 查看当前 filetype。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
