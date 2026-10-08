# nui.nvim

> 公开依赖库 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

为 Neo-tree 等插件提供窗口、菜单、输入框和树形 UI 组件。

## 在当前配置里怎么用

没有独立命令。打开 Neo-tree、Diffview 等界面时由上层插件调用。

## 动手练习

按 `<leader>fe` 打开 Neo-tree 并浏览目录，观察浮动/分屏 UI；这些交互由上层插件和 NUI 组件共同构成。

## 注意事项

曾出现 NUI/Neo-tree 渲染错误时需根据报错栈排查具体数据和调用；不要直接删除这个被依赖的 UI 库。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
