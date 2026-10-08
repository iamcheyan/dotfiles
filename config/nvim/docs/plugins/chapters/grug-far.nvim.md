# grug-far.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

跨文件查找并替换文本。

## 在当前配置里怎么用

`<leader>sr` 打开项目范围搜索替换；Visual 选中文本再按 `<leader>sr` 会带入选区；`<leader>sR` 限定当前文件。也可用 `:GrugFar` 和 `:GrugFarWithin`。先填写 Search、Replace 和文件过滤，再浏览匹配，确认后才执行替换。

## 动手练习

在一个可丢弃的练习文件里写两处 `old_name`。打开 `<leader>sr`，搜索 `old_name`、替换成 `new_name`，检查结果只命中目标文件后执行；用撤销或 Git diff 确认改动。

## 注意事项

这是会改文件的工具。先使用预览和文件过滤确认范围，不要在不清楚匹配范围时直接应用。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
