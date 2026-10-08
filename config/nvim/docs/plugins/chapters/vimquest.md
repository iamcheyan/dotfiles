# VimQuest.nvim

> 私有插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在 Neovim 中练习英语词汇并复习词义。

## 在当前配置里怎么用

`:VimQuestStart` 开始，`:VimQuestNext`/`:VimQuestPrev` 前后切题，`:VimQuestNextRound` 下一轮，`:VimQuestStop` 结束。

## 动手练习

运行 `:VimQuestStart`，先尝试回忆当前单词；按 `:VimQuestNext` 看下一题，`:VimQuestPrev` 返回，结束后运行 `:VimQuestStop`。按插件界面提示输入答案或查看释义。

## 注意事项

词库和详细答题流程见私有插件 README。它是独立练习工具，不影响代码编辑功能。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
