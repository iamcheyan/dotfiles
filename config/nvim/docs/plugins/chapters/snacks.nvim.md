# snacks.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

当前配置的搜索和交互工具集合，提供文件/内容 picker、通知、状态列、终端、LazyGit 等。Snacks 自带 Dashboard 已关闭。

## 在当前配置里怎么用

常用搜索：`<leader>ff` 文件、`<leader>fr` 最近文件、`<leader>fg` 内容、`<leader>fb` 缓冲区、`<leader>fh` 帮助；`<leader>gg` 从 Git 根目录打开 LazyGit，`<leader>gG` 从当前目录打开。picker 中输入筛选，Enter 打开，Esc 关闭；`Alt-h` 显示隐藏文件，`Alt-i` 切换忽略文件。

## 动手练习

在项目里按 `<leader>ff` 搜一个文件；再按 `<leader>fg` 搜该文件里的一段文字；按 Alt-h 看隐藏文件，最后 Esc 退出。然后按 `<leader>fr` 找刚才打开的文件。

## 注意事项

LazyGit 入口需要系统安装 `lazygit`。Dashboard 请看 dashboard-nvim 章节。私有书签和 VimQuest 的历史选择也使用 Snacks picker。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
