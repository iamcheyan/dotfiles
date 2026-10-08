# batch.nvim

> 私有插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

解析 Windows Batch 的 label、跳转和结构，并提供诊断、大纲和预览。

## 在当前配置里怎么用

`:BatchCheck` 检查结构；`:BatchJumpToLabel` 选择 label，也可带名称；`:BatchReferences` 查引用；`:BatchOutline` 打开大纲；`:BatchPeek` 预览目标。默认不抢占通用按键。

## 动手练习

在练习 `.bat` 文件创建 `:START` 和 `goto START`，运行 `:BatchCheck`；再运行 `:BatchJumpToLabel START` 跳到定义；用 `:BatchReferences` 查看引用。

## 注意事项

文件类型需识别为 batch/dosbatch。插件快捷键默认关闭；参阅私有 batch.nvim 文档了解可选键位和更多语法。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
