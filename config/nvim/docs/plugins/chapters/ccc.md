# ccc.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在编辑器里交互选择颜色或转换颜色表示。

## 在当前配置里怎么用

光标放在颜色值上按 `<leader>cp` 或 `:CccPick` 打开颜色滑块；`<leader>cC` 或 `:CccConvert` 转换颜色格式；也可双击颜色值打开 picker。

## 动手练习

在 CSS 练习文件写 `#4488cc`，把光标放在色值按 `<leader>cp` 调整 RGB/HSV 后确认；再按 `<leader>cC` 查看格式转换。

## 注意事项

会修改光标附近的颜色文字。常驻色块由 mini.hipatterns 提供；本配置关闭了 ccc 常驻高亮。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
