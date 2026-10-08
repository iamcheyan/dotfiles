# nvim-ufo

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

管理代码折叠并预览折叠区域。

## 在当前配置里怎么用

`zR` 全部展开，`zM` 全部折叠，`zr`/`zm` 逐层展开/折叠，`zp` 预览光标下折叠。折叠范围由 Treesitter 或缩进推断。

## 动手练习

打开有多个函数的源文件，按 `zM` 收起后按 `zR` 展开；定位一个函数按 `zc` 收起，再用 `zp` 看预览，最后 `zo` 展开。

## 注意事项

折叠结果取决于 filetype、Treesitter parser 和缩进。promise-async 是内部依赖，见其章节。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
