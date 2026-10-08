# nvim-treesitter-textobjects

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

让操作和跳转按函数、类、参数等语法结构工作。

## 在当前配置里怎么用

和 mini.ai 组合使用 `vaf`/`dif`（函数）、`vac`/`dic`（类）、`vaa`/`dia`（参数）；`]f`/`[f` 移动到函数边界，`]c`/`[c` 移动到类，`]a`/`[a` 移动到参数。具体对象依赖语法 parser。

## 动手练习

在有函数的 Lua/Python 文件里把光标放进函数，按 `vaf` 观察整段函数被选中；按 Esc 后试 `dif` 删除函数体，再用 `u` 撤销；按 `]f` 跳到函数起点。

## 注意事项

COBOL 当前没有 Treesitter parser，不能在 COBOL 上依赖这些语法对象；COBOL 导航见独立章节。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
