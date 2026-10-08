# nvim-web-devicons

> 公开依赖 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

按扩展名和文件类型提供图标，供文件树、buffer 标签和 Dashboard 显示。

## 在当前配置里怎么用

没有单独快捷键。打开 Neo-tree 或 Dashboard 看文件名前的图标；终端字体需支持 Nerd Font 图标。

## 动手练习

运行 `:Neotree` 查看 `.lua`、`.md` 等文件图标；再打开启动页观察最近文件图标。

## 注意事项

如果图标显示为方框或乱码，检查终端字体是否为 Nerd Font。图标插件本身没有必要单独调用。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
