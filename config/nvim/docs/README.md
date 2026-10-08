# Neovim 文档导航

Neovim 的说明文档按用途集中放在 `config/nvim/docs/`。配置源文件仍位于 `config/nvim/lua/`。

## 插件

- [Neovim 插件使用书](plugins/PLUGINS.md)：44 个公开、私有插件和依赖的分类目录；每一项都链接到独立章节，含操作方法和练习。
- 之前的合并版手册仍保留在本机私有配置中，供查阅历史整理内容；逐插件学习以本书章节为入口。

## 参考

- [Treesitter 运行要求与故障排查](reference/TREESITTER.md)：改动 Treesitter 配置前先读。
- [Filetype 与大小写不敏感扩展名](reference/FILETYPE-DETECTION.md)。

## 使用指南

- [鼠标与剪贴板](guides/MOUSE-AND-CLIPBOARD.md)。
- [Caps Lock 状态指示器](guides/CAPS-LOCK.md)。
- [Visual Multi 多光标逐行扩展](guides/VISUAL-MULTI.md)。

## 开发说明

- [状态栏交互菜单](development/STATUSLINE-MENUS.md)：Heirline 菜单实现约定与 UI 回归检查。
- [浮窗 UI 设计与实现](development/FLOATING-WINDOW-UI.md)：布局、排版、配色，以及 NUI／Noice 和全局浮窗样式之间的配合规则。

## 清理记录

已移除配置的临时审计报告、审计提示词、旧插件清理日志和已删除的 `hunk-review.nvim` 使用说明；它们描述的状态过期或功能已不存在。插件历史以 Git 提交记录为准。
