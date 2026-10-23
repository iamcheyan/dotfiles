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

<!-- lang:en -->

> Summary: gh is the official GitHub CLI; this repo uses it to manage repositories, PRs, Actions, and Pages.

# GitHub CLI (gh)

## Purpose

`gh` brings GitHub's common operations into the terminal: creating repositories, opening PRs, viewing Actions logs, managing releases. This repo's release flow and site deployment both depend on it.

## Source and Installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Load point | `plugins/tools/tools.zsh` |

```zsh
zi_cmd cli/cli gh
```

init.sh also installs the gh-dash extension (requires gh to already exist):

```bash
gh extension install dlvhdr/gh-dash
```

## Authentication

```bash
gh auth login              # 交互式登录
gh auth status             # 查看当前账号和权限
gh auth token              # 打印 token（谨慎使用）
```

Credentials are stored in `~/.config/gh/hosts.yml`. **Do not commit this file to any repository.**

On this machine, Git operations use SSH while the REST API uses a token. `gh auth status` shows both separately.

## Repository operations

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

When debugging a failed deployment, `gh run view <id> --log-failed` shows only the logs of the failed steps.

## Release

```bash
gh release list
gh release create v1.0.0 --generate-notes
gh release upload v1.0.0 ./artifact.tar.gz
gh release download v1.0.0 --pattern '*.tar.gz'
```

## Direct API calls

```bash
gh api repos/iamcheyan/dotfiles                    # GET
gh api repos/iamcheyan/dotfiles/pages              # Pages 配置
gh api --method POST repos/OWNER/REPO/pages -f build_type=workflow
gh api repos/OWNER/REPO/actions/runs --jq '.workflow_runs[0].status'
```

`--jq` filters the returned JSON directly, avoiding hand-written pipes. `-f` passes string fields; `-F` passes numbers/booleans.

## Commands this repo uses

When deploying the dotfiles site:

```bash
gh api repos/iamcheyan/dotfiles/pages                    # 检查 Pages 是否启用
gh api --method POST repos/iamcheyan/dotfiles/pages -f build_type=workflow
gh api --method PUT repos/iamcheyan/dotfiles/pages -f cname=dotfiles.iamcheyan.com
gh run list --workflow deploy-site.yml
gh run view <id> --json status,conclusion,jobs
```

## Security notes

| Item | Description |
|---|---|
| Token storage | `~/.config/gh/hosts.yml`, permissions should be 600 |
| Output logs | Do not run `gh auth token` and paste the output somewhere public |
| Elevation | Different commands need different scopes; when a permission is missing use `gh auth refresh -s <scope>` |

This repo's commit-check script scans for accidentally committed credentials, but do not rely on it — confirm it yourself before committing.

## Troubleshooting

**`gh: command not found`**: Zinit has not downloaded it. Confirm with `zinit list | grep cli`.

**`HTTP 404` but the repository exists**: the token lacks permission for that repository, or the repository is private and the token scope is insufficient. Check with `gh auth status`.

**`gh api` returns 403**: the token scope is insufficient. Run `gh auth refresh -s repo,workflow`.

**Git push fails but gh works**: Git uses SSH while gh uses an HTTPS token; the two paths are independent. Test SSH separately with `ssh -T git@github.com`.

**Pages API returns 404**: Pages is not enabled for that repository yet. Create it with POST.

<!-- lang:ja -->

> 要約：gh は GitHub 公式のコマンドラインツールで、本リポジトリではリポジトリ、PR、Actions、Pages の管理に使っています。

# GitHub CLI (gh)

## 用途

`gh` は GitHub のよく使う操作をターミナルに持ち込みます。リポジトリの作成、PR のオープン、Actions ログの閲覧、release の管理。本リポジトリのリリースフローとサイトデプロイはどちらもこれに依存しています。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit。GitHub Release からダウンロード |
| ロード位置 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd cli/cli gh
```

init.sh はさらに gh-dash 拡張もインストールします（gh が先に存在する必要があります）：

```bash
gh extension install dlvhdr/gh-dash
```

## 認証

```bash
gh auth login              # 交互式登录
gh auth status             # 查看当前账号和权限
gh auth token              # 打印 token（谨慎使用）
```

認証情報は `~/.config/gh/hosts.yml` に保存されます。**このファイルをどんなリポジトリにもコミットしないでください。**

本マシンの設定では、Git 操作は SSH を、REST API はトークンを使います。`gh auth status` はこの二つを別々に表示します。

## リポジトリ操作

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

デプロイ失敗を調査するときは、`gh run view <id> --log-failed` で失敗ステップのログだけを見られます。

## Release

```bash
gh release list
gh release create v1.0.0 --generate-notes
gh release upload v1.0.0 ./artifact.tar.gz
gh release download v1.0.0 --pattern '*.tar.gz'
```

## API 直接呼び出し

```bash
gh api repos/iamcheyan/dotfiles                    # GET
gh api repos/iamcheyan/dotfiles/pages              # Pages 配置
gh api --method POST repos/OWNER/REPO/pages -f build_type=workflow
gh api repos/OWNER/REPO/actions/runs --jq '.workflow_runs[0].status'
```

`--jq` は返ってきた JSON を直接フィルタリングし、手書きのパイプラインを避けられます。`-f` は文字列フィールドを、`-F` は数値/真偽値を渡します。

## 本リポジトリで使うコマンド

dotfiles サイトをデプロイするとき：

```bash
gh api repos/iamcheyan/dotfiles/pages                    # 检查 Pages 是否启用
gh api --method POST repos/iamcheyan/dotfiles/pages -f build_type=workflow
gh api --method PUT repos/iamcheyan/dotfiles/pages -f cname=dotfiles.iamcheyan.com
gh run list --workflow deploy-site.yml
gh run view <id> --json status,conclusion,jobs
```

## セキュリティ上の注意

| 項目 | 説明 |
|---|---|
| トークンの保存 | `~/.config/gh/hosts.yml`。パーミッションは 600 であるべき |
| 出力ログ | `gh auth token` の出力を公開場所に貼らない |
| 権限昇格 | コマンドごとに必要な scope が異なる。権限が足りないときは `gh auth refresh -s <scope>` |

本リポジトリのコミットチェックスクリプトは誤ってコミットされた認証情報をスキャンしますが、それに頼らないでください。コミット前に自分で確認します。

## トラブルシューティング

**`gh: command not found`**：Zinit がダウンロードしていません。`zinit list | grep cli` で確認します。

**`HTTP 404` なのにリポジトリが存在する**：トークンにそのリポジトリの権限がないか、リポジトリが非公開でトークンの scope が不足しています。`gh auth status` で確認します。

**`gh api` が 403 を返す**：トークンの scope が足りません。`gh auth refresh -s repo,workflow` を実行します。

**Git push は失敗するのに gh は使える**：Git は SSH を、gh は HTTPS トークンを使い、経路は独立しています。`ssh -T git@github.com` で SSH を別途テストします。

**Pages API が 404 を返す**：そのリポジトリで Pages がまだ有効になっていません。POST で作成します。
