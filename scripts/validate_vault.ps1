param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath
)

$ErrorActionPreference = 'Stop'
$resolvedVault = [IO.Path]::GetFullPath($VaultPath)
if (-not (Test-Path -LiteralPath $resolvedVault)) { throw 'Vault 不存在。' }

$files = Get-ChildItem -Path $resolvedVault -Recurse -File
$markdownFiles = @($files | Where-Object Extension -eq '.md')
$keys = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)

foreach ($file in $files) {
    $relative = $file.FullName.Substring($resolvedVault.Length + 1).Replace([char]92, [char]47)
    [void]$keys.Add($relative)
    [void]$keys.Add($relative.Substring(0, $relative.Length - $file.Extension.Length))
    [void]$keys.Add($file.Name)
    [void]$keys.Add($file.BaseName)
}

$missing = @()
foreach ($file in $markdownFiles) {
    $content = [IO.File]::ReadAllText($file.FullName, [Text.Encoding]::UTF8)
    foreach ($match in [regex]::Matches($content, '\[\[([^\]|#]+)')) {
        $target = $match.Groups[1].Value.Trim()
        if (-not $keys.Contains($target)) {
            $missing += [pscustomobject]@{
                File = $file.FullName.Substring($resolvedVault.Length + 1)
                Target = $target
            }
        }
    }
}

Write-Output "Markdown 文件：$($markdownFiles.Count)"
Write-Output "缺失内部链接：$($missing.Count)"
if ($missing.Count -gt 0) {
    $missing | Sort-Object File, Target -Unique | Format-Table -AutoSize
    exit 1
}

Write-Output '验证通过。'
