> 摘要：gh 是 GitHub 官方命令行，本仓库用它管理仓库、PR、Actions 和 Pages。

# GitHub CLI (gh)

## 用途

`gh` 把 GitHub 的常用操作搬到终端：创建仓库、开 PR、看 Actions 日志、管理 release。本仓库的发布流程和站点部署都依赖它。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd cli/cli gh
```

init.sh 还会装 gh-dash 扩展（需要 gh 已存在）：

```bash
gh extension install dlvhdr/gh-dash
```

## 认证

```bash
gh auth login              # 交互式登录
gh auth status             # 查看当前账号和权限
gh auth token              # 打印 token（谨慎使用）
```

认证信息存在 `~/.config/gh/hosts.yml`。**不要把这个文件提交到任何仓库。**

本机配置里 Git 操作用 SSH，REST API 用 token。`gh auth status` 会分别显示这两项。

## 仓库操作

```bash
gh repo view                       # 查看当前仓库信息
gh repo view --web                 # 在浏览器打开
gh repo clone iamcheyan/dotfiles   # 克隆
gh repo create my-project --public # 创建
gh repo list iamcheyan --limit 20  # 列出仓库
gh repo edit --visibility public   # 改可见性
```

## Pull Request

```bash
gh pr create --fill                # 用提交信息创建 PR
gh pr list                         # 列出 PR
gh pr view 42                      # 查看某个 PR
gh pr checkout 42                  # 检出到本地
gh pr diff 42                      # 看 diff
gh pr review 42 --approve          # 批准
gh pr merge 42 --squash            # 合并
```

## Actions

```bash
gh run list --limit 10                      # 最近 10 次运行
gh run view 12345                           # 查看某次运行
gh run view 12345 --log                     # 完整日志
gh run watch 12345                          # 实时跟踪
gh run rerun 12345                          # 重跑
gh workflow list                            # 列出 workflow
gh workflow run deploy-site.yml             # 手动触发
```

排查部署失败时，`gh run view <id> --log-failed` 只看失败步骤的日志。

## Release

```bash
gh release list
gh release create v1.0.0 --generate-notes
gh release upload v1.0.0 ./artifact.tar.gz
gh release download v1.0.0 --pattern '*.tar.gz'
```

## API 直调

```bash
gh api repos/iamcheyan/dotfiles                    # GET
gh api repos/iamcheyan/dotfiles/pages              # Pages 配置
gh api --method POST repos/OWNER/REPO/pages -f build_type=workflow
gh api repos/OWNER/REPO/actions/runs --jq '.workflow_runs[0].status'
```

`--jq` 直接对返回的 JSON 做筛选，避免手写管道。`-f` 传字符串字段，`-F` 传数字/布尔。

## 本仓库用到的命令

部署 dotfiles 站点时：

```bash
gh api repos/iamcheyan/dotfiles/pages                    # 检查 Pages 是否启用
gh api --method POST repos/iamcheyan/dotfiles/pages -f build_type=workflow
gh api --method PUT repos/iamcheyan/dotfiles/pages -f cname=dotfiles.iamcheyan.com
gh run list --workflow deploy-site.yml
gh run view <id> --json status,conclusion,jobs
```

## 安全注意

| 事项 | 说明 |
|---|---|
| token 存储 | `~/.config/gh/hosts.yml`，权限应为 600 |
| 输出日志 | 不要 `gh auth token` 后把输出贴到公开位置 |
| 提权 | 不同命令需要不同 scope，缺权限时 `gh auth refresh -s <scope>` |

本仓库的提交检查脚本会扫描是否误提交了凭据，但不要依赖它——提交前自己确认。

## 排错

**`gh: command not found`**：Zinit 未下载。`zinit list | grep cli` 确认。

**`HTTP 404` 但仓库确实存在**：token 没有该仓库权限，或仓库是私有的且 token scope 不足。`gh auth status` 检查。

**`gh api` 返回 403**：token scope 不够。`gh auth refresh -s repo,workflow`。

**Git push 失败但 gh 能用**：Git 走 SSH，gh 走 HTTPS token，两条路独立。`ssh -T git@github.com` 单独测试。

**Pages API 返回 404**：该仓库还没启用 Pages。用 POST 创建。
