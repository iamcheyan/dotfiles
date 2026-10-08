# dashboard-nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

Neovim 启动页。Hyper 主题把近期项目、最近文件和快捷操作放在同一屏。

## 在当前配置里怎么用

启动 Neovim 且没有恢复项目会话时自动出现。项目列表最多 8 项；选中后调用 Snacks 文件搜索器定位该项目。最近文件最多 10 项，包含不同工作目录的记录。按 `f` 找文件、`s` 搜内容、`l` 打开 Lazy；`:Dashboard` 可再次打开。

## 动手练习

打开几个不同项目的文件后执行 `:Dashboard`。先从 Recent files 选一个文件；再在 Projects 中选项目并搜索文件；最后按 `s` 搜一个你确定存在的词。用 `Esc` 关闭 picker。

## 注意事项

最近文件来自 Neovim 的旧文件记录；刚安装后列表可能很短。若 Auto Session 有可恢复会话，启动时会优先恢复会话，因此不会显示首页。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
