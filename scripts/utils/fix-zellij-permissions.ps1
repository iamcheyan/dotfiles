# 修复 Windows (PowerShell) 下的 zellij 插件权限缓存
# 当权限弹窗无法点击时，运行此脚本重新生成权限缓存文件

$cacheDirs = @(
    "$env:USERPROFILE\.cache\zellij",
    "$env:LOCALAPPDATA\zellij",
    "$env:APPDATA\zellij"
)

# 获取用户家目录并将路径反斜杠转为正斜杠以适配 Zellij 内部路径格式
$homeDir = $env:USERPROFILE.Replace('\', '/')
$kdlContent = @"
"$homeDir/.config/zellij/plugins/zellij-cb.wasm" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
}
"@

foreach ($cacheDir in $cacheDirs) {
    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
    }
    Set-Content -Path "$cacheDir\permissions.kdl" -Value $kdlContent -Encoding UTF8
    Write-Host "Zellij permissions cache fixed: $cacheDir\permissions.kdl"
}
