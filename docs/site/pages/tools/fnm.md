> 摘要：fnm 管理 Node 版本，本仓库用惰性加载包装器避免每次启动 shell 都付出初始化成本。

# fnm

## 用途

`fnm`（Fast Node Manager）是 Node 版本管理器，用 Rust 写成。它安装多个 Node 版本，按目录或全局切换。

本仓库对它的改造在 `scripts/setup/setup_fnm.sh`：把 `node`、`npm`、`npx`、`corepack` 包成惰性函数，第一次真正调用时才初始化。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | init.sh 的 `install_fnm` 步骤 |
| 默认目录 | `~/.fnm` |
| 包装器 | `scripts/setup/setup_fnm.sh` |

安装方式由 init.sh 决定：Linux/macOS 用官方安装脚本，NixOS 提示由系统配置管理。

## 为什么惰性加载

标准做法：

```zsh
eval "$(fnm env --use-on-cd)"
```

每次启动 shell 都执行一次子进程，约 20–50ms。本仓库把它推迟到第一次用 Node 时：

```zsh
node() { __fnm_lazy_dispatch node "$@"; }
npm()  { __fnm_lazy_dispatch npm "$@"; }
```

代价是第一次 `node` 调用稍慢，收益是每个新 shell 都省一次初始化。

## 包装器的工作流程

```text
调用 node
  └── __fnm_lazy_dispatch node
        ├── 找 fnm 二进制（__fnm_bin）
        │     ├── 找到 → __fnm_lazy_load
        │     │     ├── eval "$(fnm env --shell zsh --use-on-cd)"
        │     │     ├── fnm use default
        │     │     └── 没有 default 时选本地最新版本
        │     └── 找不到 → 删掉包装函数，调用系统 node
        └── unfunction node npm npx corepack; hash -r
        └── command node "$@"
```

`unfunction` + `hash -r` 是关键：执行一次后就把包装器拆掉，后续调用直接走真实二进制，不再有函数调用开销。

## 基本用法

```bash
fnm list                       # 已安装版本
fnm list-remote --lts          # 可安装的 LTS 列表
fnm install --lts              # 装最新 LTS
fnm install 20.11.0            # 装指定版本
fnm use 20                     # 当前 shell 切到 20.x
fnm default 20                 # 设为全局默认
fnm current                    # 当前版本
fnm uninstall 18               # 卸载
fnm env                        # 打印环境变量设置
```

## --use-on-cd

包装器里用了 `fnm env --shell zsh --use-on-cd`，它注册了 `chpwd` hook：进入含 `.nvmrc` 或 `.node-version` 的目录时自动切换版本。

```bash
cd ~/projects/legacy-app    # .nvmrc 写着 16
node --version              # v16.x.x
cd ~/projects/new-app       # .nvmrc 写着 20
node --version              # v20.x.x
```

## 版本文件优先级

| 文件 | 说明 |
|---|---|
| `.node-version` | fnm 原生格式 |
| `.nvmrc` | 兼容 nvm |

内容可以是 `20`、`20.11`、`20.11.0`、`lts/*`、`latest`。

## 与 direnv 的关系

两者都能在 `cd` 时改变环境：

| | fnm | direnv |
|---|---|---|
| 触发 | `.nvmrc` / `.node-version` | `.envrc`（需 allow） |
| 范围 | 只改 Node | 任意变量 |
| 安全 | 无需授权 | 需显式 allow |

同时使用时，direnv 可以调用 `use node` 让 fnm 接管版本切换，避免两套 hook 争抢。

## 环境变量

| 变量 | 作用 |
|---|---|
| `FNM_DIR` | fnm 安装目录，默认 `~/.fnm` |
| `__FNM_LAZY_LOADED` | 内部标志，标记是否已初始化 |

## 排错

**`node: command not found`**：fnm 没装，且系统也没 Node。跑 `bash init.sh` 或手动装 fnm。

**`Error: fnm not found. Run init.sh`**：包装器找不到 fnm 二进制。`ls ~/.fnm ~/.fnm/bin` 检查目录。

**版本切换不生效**：`.nvmrc` 内容不被识别。用 `fnm use` 手动测试，确认版本已安装。

**`npm install -g` 装的命令找不到**：npm 全局 bin 目录没进 PATH。`npm prefix -g` 看路径，确认它在 PATH 里。

**每次 cd 都卡顿**：`--use-on-cd` 在有大 `.nvmrc` 树的目录里会频繁切换。可以关掉它，改为手动 `fnm use`。

**NixOS 上包装器报错**：系统用声明式配置提供 Node，没有 fnm。包装器的 fallback 会删掉函数并调用系统 `node`，应该能正常工作；若报错，检查 `__fnm_bin` 的探测路径。
