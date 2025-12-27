# Karabiner 映射方案（JIS → ANSI）

本目录包含 Karabiner-Elements 配置（`karabiner.json`），用于将日文 JIS 键盘映射为标准英文（ANSI）配列，以便在 macOS 上获得更接近英文键盘的输入体验，降低切换成本。

## 适用场景
- 使用日文 JIS 键盘，但希望按键布局、符号位置尽可能与英文 ANSI 键盘一致
- 需要统一跨平台快捷键（与常见 IDE/编辑器一致）

## 依赖工具
- Karabiner-Elements（macOS 键盘改键工具）
  - 下载： [Karabiner-Elements 官方下载页](https://karabiner-elements.pqrs.org/)
  - GitHub Releases： [pqrs-org/Karabiner-Elements](https://github.com/pqrs-org/Karabiner-Elements/releases)

## 主要映射思路（示例）
- 将 JIS 布局中的特定符号键位重映射为 ANSI 的对应位置
- 统一修饰键组合，尽量贴近英文键盘的快捷键习惯
- 保留常用功能键行为（如 Fn、媒体键等）

提示：具体规则以 `karabiner.json` 为准，可在 Karabiner 的「Complex Modifications」中导入/启用。

## 使用方法（macOS）
1. 安装 Karabiner-Elements（见上方下载链接）
2. 备份原设置：
   ```bash
   cp ~/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json.bak 2>/dev/null || true
   ```
3. 将本目录中的 `karabiner.json` 覆盖到系统配置：
   ```bash
   mkdir -p ~/.config/karabiner
   cp ./karabiner.json ~/.config/karabiner/karabiner.json
   ```
4. 打开 Karabiner-Elements，进入「Complex Modifications / Profiles」，确认配置已生效

## 仓库同步
本目录作为独立公开仓库同步（适合分享/复用）：
- 公开仓库： `git@github.com:iamcheyan/karabiner.git`
- 本 dotfiles 会通过 `git subtree` 将 `config/karabiner` 目录同步到公开仓库
- 你也可以独立克隆该仓库，仅使用 Karabiner 配置

## 常见问题
- 按键未生效：检查是否已给予 Karabiner-Elements 输入监控权限（系统设置 → 隐私与安全）
- 个别应用快捷键冲突：可在 Karabiner 中为应用定义条件映射或在应用内重设快捷键

---
如需个性化调整，建议在 Karabiner 的「Complex Modifications」中逐条启用/禁用或编辑规则，并将修改同步回此目录。
