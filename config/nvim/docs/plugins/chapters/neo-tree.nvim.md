# neo-tree.nvim

> 公开插件 · [回到插件目录](../PLUGINS.md)

## 它解决什么问题

文件树、缓冲区清单和 Git 状态侧栏。

## 在当前配置里怎么用

`<leader>fe` 切换项目根目录文件树；`<leader>fE` 或 `<leader>e` 切换当前工作目录树；`<leader>ge` 打开 Git 状态；`<leader>be` 打开缓冲区列表。树内 Enter 打开，`h`/左方向收起，`l`/右方向展开；按 `?` 看当前视图的操作。Git 视图支持 `ga` 暂存、`gu` 取消暂存、`gr` 撤销文件修改、`gc` 提交、`gp` 推送。

## 动手练习

先按 `<leader>fe` 打开目录树，定位一个文件并按 Enter；再按 `<leader>ge` 查看修改状态，选中一个文件按 `ga` 暂存，切回 Git 状态确认标记变化。

## 注意事项

撤销和提交会实际改变 Git 工作区或仓库状态，先确认选中的文件。Neotree 报错时可用 `:Neotree` 重开并查看 `:messages`。

## 查快捷键和帮助

在 Neovim 里用 `:verbose nmap <按键>` 查看最终映射和定义来源；按 `<leader>` 后稍等可看 which-key 提示。可用命令可用 `:command <前缀>` 查询。
