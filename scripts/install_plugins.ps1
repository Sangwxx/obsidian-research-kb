param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string[]]$Plugins = @('dataview', 'obsidian-tasks-plugin', 'obsidian-linter', 'zotlit')
)

$ErrorActionPreference = 'Stop'
$resolvedVault = [IO.Path]::GetFullPath($VaultPath)
$pluginRoot = [IO.Path]::GetFullPath((Join-Path $resolvedVault '.obsidian/plugins'))

if (-not $pluginRoot.StartsWith($resolvedVault, [StringComparison]::OrdinalIgnoreCase)) {
    throw '插件目录不在目标 Vault 内。'
}

$catalog = @{
    'dataview'              = 'blacksmithgu/obsidian-dataview'
    'obsidian-tasks-plugin' = 'obsidian-tasks-group/obsidian-tasks'
    'obsidian-linter'       = 'platers/obsidian-linter'
    'zotlit'                = 'aidenlx/zotlit'
}

$headers = @{ 'User-Agent' = 'obsidian-research-kb' }
$enabled = @()
$enabledFile = Join-Path $resolvedVault '.obsidian/community-plugins.json'
if (Test-Path $enabledFile) {
    $enabled = @(Get-Content -Raw $enabledFile | ConvertFrom-Json)
}

foreach ($id in $Plugins) {
    if (-not $catalog.ContainsKey($id)) { throw "未知插件：$id" }
    $target = [IO.Path]::GetFullPath((Join-Path $pluginRoot $id))
    if (-not $target.StartsWith($pluginRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "非法插件路径：$target"
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    $release = Invoke-RestMethod -Headers $headers -Uri "https://api.github.com/repos/$($catalog[$id])/releases/latest"
    foreach ($name in @('manifest.json', 'main.js', 'styles.css')) {
        $asset = $release.assets | Where-Object name -eq $name | Select-Object -First 1
        if (-not $asset) { throw "$($catalog[$id]) 的最新 Release 缺少 $name。" }
        Invoke-WebRequest -Headers $headers -Uri $asset.browser_download_url -OutFile (Join-Path $target $name)
    }
    $manifest = Get-Content -Raw (Join-Path $target 'manifest.json') | ConvertFrom-Json
    if ($manifest.id -ne $id) { throw "插件 ID 不一致：期望 $id，实际 $($manifest.id)。" }
    if ($enabled -notcontains $id) { $enabled += $id }
    Write-Output "已安装：$($manifest.name) $($manifest.version)"
}

$json = ConvertTo-Json @($enabled)
[IO.File]::WriteAllText($enabledFile, "$json`n", [Text.UTF8Encoding]::new($false))
Write-Output '插件安装完成。重新打开 Obsidian 后生效。'
