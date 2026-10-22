> 摘要：说明公开仓库边界、维护路径、测试入口与更新方法，区分通用配置和个人环境。

# 维护与边界

## 哪些内容属于这里

`iamcheyan/dotfiles` 是公开基础层：Zsh、通用 CLI、应用设置、安装脚本和 dotlink。Neovim 在独立仓库中维护，通过子模块记录分发版本。NixOS 系统包、服务和硬件属于系统配置；机器专属应用编排、Agent、输入法和凭据属于私有配置。

不要把密码、Token、API key、SSH 私钥、私有服务器地址和个人 Agent wrapper 放到公开仓库。`local/` 只跟踪 README；Zsh 在公共配置最后加载用户自己创建的覆盖文件。`aliases/` 是独立仓库内容，按它自己的权限和可见性管理。

## 更新

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
bash dotlink/dotlink link
```

Neovim 子模块只更新到主仓库记录的 gitlink 版本；要分发新版，维护者需先提交 nvim 仓库，再更新本仓库的子模块指针。运行过 init.sh 的 clone 会启用递归子模块更新。

本地 Neovim 稳定版通过 `nvim-update` 更新；NixOS 使用声明式系统配置更新。

## 修改和检查

直接编辑仓库源文件，避免通过 `~/.zshrc` 软链接绕回目标修改。新增部署项时编辑 `dotlink/dotlinkrc` 并核对映射。

```bash
zsh -d -n zshrc
bash -n init.sh
bash -n aliases.conf
git diff --check
```

Neovim 专项测试在子模块内；Neovim updater fixture 测试为 `bash scripts/tests/nvim_update_test.sh`。Vim 测试文件位于 `config/vim/tests/`。

## 私人覆盖

```bash
mkdir -p ~/dotfiles/local
$EDITOR ~/dotfiles/local/custom.zsh
```

Zsh 会在所有公开设置之后 source `local/` 普通文件。该目录除 README 外被 Git 忽略，所以个人 alias、环境变量和函数不会进入公开提交。
