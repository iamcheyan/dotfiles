> 摘要：apt、pacman、nix、cargo、npm 等包管理命令，重点在 Debian 本机与 NixOS、Arch 混用环境的差异。

# 软件包管理

这台机器的主环境是 Debian 13，但日常会碰到三种包管理：Debian 的 apt、NixOS 的 nix（HX90）、以及各种语言自己的管理器（cargo/npm/pipx）。本篇按"装、查、卸、修"四件事组织。

## Debian / Ubuntu（apt）

```bash
sudo apt update                 # 刷新软件源索引（装东西前先跑）
sudo apt install 包名            # 安装
sudo apt install ./x.deb        # 装本地 deb 文件（依赖自动解决）
sudo apt remove 包名             # 卸载（保留配置）
sudo apt purge 包名              # 卸载 + 删配置
sudo apt autoremove             # 清不再需要的依赖
sudo apt upgrade                # 升级所有可升级的
sudo apt full-upgrade           # 升级，必要时删旧包
apt search 关键词               # 搜索（不需要 sudo）
apt show 包名                   # 详情、版本、依赖
apt list --installed | rg 关键词 # 查已装的
apt policy 包名                  # 候选版本与来源
dpkg -l | rg 包名                # dpkg 层面查询
dpkg -L 包名                     # 包装了哪些文件
dpkg -S /path/to/file           # 这个文件属于哪个包（排查冲突神器）
```

**本机 Debian 的实际坑**：

| 问题 | 处理 |
|---|---|
| 源里没有某新工具（eza、fd 等） | 用 Zinit/init.sh 从 GitHub Release 装二进制，或 cargo，不强求 apt |
| `apt install` 报 `held broken packages` | `sudo apt --fix-broken install`，再看是不是手动装的 deb 冲突 |
| 装完命令不存在 | Debian 改名了：`fd-find` 的命令是 `fdfind`、`bat` 是 `batcat`。本站用 Zinit 装原名版本绕开 |
| 内核占满 `/boot` | `sudo apt autoremove --purge` 清旧内核，或手工 `dpkg --purge` 旧 `linux-image-*` |

本机 VM 磁盘 504G、当前用了 52%，但 `/boot` 分区小，**升级内核前先 `df -h /boot`**。

## Arch / Omarchy（pacman）

HX90 之外如果碰到 Arch 系（Omarchy 桌面也是 Arch）：

```bash
sudo pacman -Syu                # 全量升级（Arch 不支持局部升级，必须整系统）
sudo pacman -S 包名              # 安装
sudo pacman -Rns 包名            # 卸载 + 孤立依赖 + 配置
sudo pacman -Ss 关键词           # 搜索
sudo pacman -Qi 包名             # 已装详情
sudo pacman -Qdt                # 孤立包列表
pacman -Q --file /path/bin      # 文件属于哪个包
paccache -rk1                   # 清包缓存只留最近 1 版
```

Arch 的铁律：**不做局部升级**（`pacman -Sy foo` 是被官方禁止的操作），要么 `pacman -Syu` 全升要么不动。Arch 的 `--needed` 参数值得常带：`sudo pacman -S --needed 包名`，已装就跳过。

## NixOS（HX90）

另一台机器是 NixOS，一切声明在 `~/nixos-config`，flake host 是 `hx90`：

```bash
# 改配置 = 编辑 ~/nixos-config 里的 .nix 文件，然后：
nixos-rebuild build --impure --flake ~/nixos-config#hx90    # 先构建验证！
nixos-rebuild switch --impure --flake ~/nixos-config#hx90   # 构建通过再切换
nix flake check ~/nixos-config                              # 语法与求值检查
nix flake update --flake ~/nixos-config                     # 更新输入锁定
nix-collect-garbage -d                                      # 清旧代（释放空间）
nix store gc                                               # 同上，等价
```

**NixOS 的边界**：不要用 `/etc/nixos/configuration.nization.nix` 直接 rebuild（那是给实验用的），正规入口只有 flake；改完先 `build` 再 `switch`，构建不过就不切。日常软件在 NixOS 上优先找 flake 输入或 `environment.systemPackages`，ad-hoc 命令也可以 `nix shell nixpkgs#包名`。

## 语言级包管理

```bash
# Node（本机用 fnm 管版本，corepack 管 pnpm）
node -v && fnm ls
corepack pnpm install            # 装依赖（尊重 package.json 的 packageManager）
corepack pnpm add 包名 -D        # 加开发依赖
npm ls -g --depth=0              # 全局包列表
npm i -g 包名                    # 全局安装

# Rust
cargo install 包名               # 从 crates.io 装到 ~/.cargo/bin
cargo install --list            # 列出 cargo 装的
rustup update                    # 更新工具链

# Python（避免污染系统）
pipx install 包名                # 隔离环境装 CLI 工具（首选）
pipx list
# 系统 pip 只用于 venv 里：python3 -m venv .venv && .venv/bin/pip install x
```

**Debian 13 的 Python 是 externally-managed**：直接 `pip install` 会被 PEP 668 拦下。正确姿势是 `pipx`（CLI 工具）或 `python3 -m venv`（项目依赖）。本机各项目的 `.venv` 都是这么建的。

## GitHub Release 二进制（本站工具的主安装方式）

这套 dotfiles 的很多工具不来自发行版仓库，而是从 GitHub Release 拉二进制：

```bash
# 本站的 Zinit 用 from"gh-r" 声明，自动选最新 release
gh release list --repo owner/repo --limit 5   # 看一个仓库的 release
gh api repos/owner/repo/releases/latest --jq '.assets[].browser_download_url'
```

手动装的套路：下载 → **校验 SHA-256** → 解压到 `~/.local/bin` → `chmod +x`。校验这步不能省，尤其是从没听过的新源。

## Docker

```bash
docker ps                       # 运行中的容器
docker ps -a                    # 含停掉的
docker compose up -d            # 起（在 compose 文件目录）
docker compose down             # 停
docker compose logs -f --tail=100 服务名   # 看日志
docker compose pull && docker compose up -d  # 更新镜像重启
docker system df                # 镜像/容器/卷占用
docker image prune -f           # 清悬空镜像
```

本机的 Docker 项目（媒体、照片、文档等）都在各自目录的 `docker-compose.yml`。**动生产数据前**：`docker inspect` 看清卷映射，备份优先，绝不对着 `/data` 手滑 `compose down -v`。

## 排错

**`apt` 锁被占**：`Waiting for cache lock` 说明另一个 apt 在跑（unattended-upgrades？）。`ps aux | rg apt` 看，等它或 `sudo killall apt apt-get` 后 `sudo dpkg --configure -a`。

**`pacman -Syu` 后桌面炸了**：Arch 的老问题，看 `journalctl -b -p err`，回滚用本地缓存里的上一版包。

**`nixos-rebuild switch` 失败卡在半路**：多数是求值错误，`nixos-rebuild build` 先跑；切换失败不会留下半配置，重试即可。

**pip 装不上（PEP 668）**：`pipx install` 或建 venv，别 `--break-system-packages`。

**cargo 编译内存爆**：本机 4 核 16G，`cargo build -j 2` 限并发，或 `CARGO_PROFILE_DEV_DEBUG=0` 关调试信息。
