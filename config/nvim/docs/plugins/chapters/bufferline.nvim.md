# bufferline.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

在窗口顶部显示已打开缓冲区，便于在文件间切换。它显示的是 buffer，不是 Vim tab page。

## 在当前配置里怎么用

点击标签切换；鼠标中键关闭；右键打开本配置的缓冲区菜单；右侧加号创建空 buffer。键盘用 `Shift+h`/`Shift+l` 或 `<leader>bh`/`<leader>bl` 切换，`<leader>bb` 回到前一个 buffer。

## 动手练习

打开两个文件，使用 `Shift+l` 和 `Shift+h` 来回切换；按 `<leader>bb` 回到前一个；再新建空 buffer 并观察标签变化。

## 注意事项

退出当前 buffer 用 `<leader>bd`。标签栏项目多时会滚动；`:tabs` 查看的是另一套 tab page。设置 `WDIFF_NVIM=1` 时本插件禁用。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
