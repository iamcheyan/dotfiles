# aerial.nvim

> 公开插件（COBOL/Batch 后端由私有层扩展） · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

把函数、类、段落等符号整理成可搜索的大纲，快速浏览较长文件。

## 在当前配置里怎么用

`<leader>cs` 或 `:AerialToggle` 开关侧栏；`:AerialOpen` 打开；`:AerialInfo` 查看当前文件可用的符号来源。大纲里选中符号可跳转；按 `?` 看操作帮助。普通语言使用 LSP/Treesitter 等后端，COBOL 和 Batch 由私有插件提供后端。

## 动手练习

打开一个有多个函数的源文件，按 `<leader>cs`；在大纲中找某函数并 Enter 跳过去；再试着输入函数名筛选。打开 COBOL 文件可观察段落是否出现在大纲中。

## 注意事项

结果依赖语言服务器或对应 parser/backend。若为空，先检查 `:AerialInfo` 和文件类型。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
