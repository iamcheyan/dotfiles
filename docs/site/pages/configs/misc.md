> 摘要：nano 配置的边界与部署方式。

# nano

该配置文件体量小，或只部分部署，放在一起说明。

## nano

### 位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/nano/nanorc` |
| 部署目标 | `~/.nanorc` |
| 是否自动链接 | 是 |

### 用途

Nano 的语法高亮和默认选项。适合在没有 Vim 的环境里应急编辑。

### 注意

`~/.nanorc` 会被 Nano 读取，如果文件里有语法错误，Nano 会报错但通常仍能启动。

本仓库的 `nanorc` 内容较短，主要是语法高亮包含和少量默认项。

Nano 标题栏用蓝底黄字，状态栏用青色，选区和行号沿用 Neovim Blue 的蓝／青色强调。

### 验证

```bash
nano --version
nano /tmp/test.txt
```

### 排错

**Nano 启动报语法错误**：`nanorc` 里有不兼容当前 Nano 版本的指令。注释掉对应行。

**没有语法高亮**：`include` 路径不对，或 Nano 编译时没启用语法支持。


<!-- lang:en -->

> Summary: The boundaries and deployment of the Nano configuration.

# nano

This configuration file is small, so it is documented here.

## nano

### Location

| Item | Path |
|---|---|
| Repository source file | `config/nano/nanorc` |
| Deployment target | `~/.nanorc` |
| Auto-linked | Yes |

### Purpose

Syntax highlighting and default options for Nano. Useful for quick edits in environments without Vim.

### Notes

Nano reads `~/.nanorc`; if the file contains a syntax error, Nano reports it but usually still starts.

The `nanorc` in this repository is short, consisting mainly of syntax highlighting includes and a few default options.

The Nano title bar uses yellow on blue, the status bar cyan, and the selection and line numbers follow Neovim Blue's blue/cyan accents.

### Verification

```bash
nano --version
nano /tmp/test.txt
```

### Troubleshooting

**Nano reports a syntax error on startup**: the `nanorc` contains a directive incompatible with the current Nano version. Comment out the offending line.

**No syntax highlighting**: the `include` path is wrong, or Nano was built without syntax support.


<!-- lang:ja -->

> 要約：nano 設定の境界とデプロイ方法。

# nano

この設定ファイルは小さいため、ここで説明します。

## nano

### 場所

| 項目 | パス |
|---|---|
| リポジトリのソースファイル | `config/nano/nanorc` |
| デプロイ先 | `~/.nanorc` |
| 自動リンクの対象 | はい |

### 用途

Nano のシンタックスハイライトとデフォルトオプションです。Vim のない環境での応急編集に適しています。

### 注意

`~/.nanorc` は Nano に読み込まれます。ファイルに文法エラーがあると、Nano はエラーを報告しますが、通常は起動自体はできます。

本リポジトリの `nanorc` は短く、主にシンタックスハイライトの include と少数のデフォルト項目からなります。

Nano のタイトルバーは青地に黄色、ステータスバーはシアンを使い、選択範囲と行番号は Neovim Blue の青／シアンのアクセントに合わせています。

### 検証

```bash
nano --version
nano /tmp/test.txt
```

### トラブルシューティング

**Nano 起動時に文法エラーが出る**：`nanorc` に現在の Nano バージョンと互換性のないディレクティブがあります。該当行をコメントアウトしてください。

**シンタックスハイライトが出ない**：`include` のパスが間違っているか、Nano がシンタックスサポート無しでビルドされています。
