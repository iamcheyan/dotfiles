# bookmark.nvim

> 私有插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

给源码行加书签，并按项目保存，以后快速跳回重要位置。

## 在当前配置里怎么用

`<leader>mt` 或 `:BookmarkToggle` 切换当前行；`<leader>mm` 或 `:BookmarkList` 打开列表；`]b`/`[b` 下一个/上一个；`<leader>mc` 清当前 buffer，`<leader>mC` 清当前项目。列表使用 Snacks picker。

## 动手练习

在一个项目的重要逻辑行按 `<leader>mt` 加标记；再移动到别处按 `<leader>mm` 选中刚才的书签；按 `]b` 跳转；再次 `<leader>mt` 删除当前行书签。

## 注意事项

书签保存位置由私有插件管理，项目间分开。`[b`/`]b` 被书签占用；切换 buffer 请用 `Shift+h/l` 或 `<leader>bh/bl`。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
