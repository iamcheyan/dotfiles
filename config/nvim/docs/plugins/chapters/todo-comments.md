# todo-comments.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

高亮常见代码注释标记并帮助浏览 TODO/FIXME 等待办。

## 在当前配置里怎么用

在注释里写 `TODO:`、`FIX:`、`WARN:` 等标记；`]t` 跳下一个，`[t` 跳上一个；`<leader>st` 搜全部关键词，`<leader>sT` 搜 TODO/FIX/FIXME。搜索界面由 Snacks picker 显示。

## 动手练习

在练习文件加入 `-- TODO: try this` 和 `-- FIXME: remove this` 两行；按 `]t`/`[t` 循环，再按 `<leader>st` 查看项目内所有匹配。

## 注意事项

只识别配置内的关键词格式；普通文本中并非注释的位置可能不会以相同方式处理。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
