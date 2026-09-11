param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$ResearchDomain,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$resolvedVault = [IO.Path]::GetFullPath($VaultPath)

if ([string]::IsNullOrWhiteSpace($ProjectName)) { throw '项目名称不能为空。' }
if ([string]::IsNullOrWhiteSpace($ResearchDomain)) { throw '研究领域不能为空。' }

New-Item -ItemType Directory -Path $resolvedVault -Force | Out-Null

$directories = @(
    '00-首页', '01-研究问题', '02-文献', '02-文献/文献笔记', '03-教程',
    '04-实验', '05-AI知识', '05-AI知识/00-待审核', '05-AI知识/01-已整理',
    '05-AI知识/02-技术决策', '06-会议', '07-成果', '08-项目管理',
    '99-模板', '99-模板/zotlit', '附件', '.obsidian'
)

foreach ($directory in $directories) {
    $target = [IO.Path]::GetFullPath((Join-Path $resolvedVault $directory))
    if (-not $target.StartsWith($resolvedVault, [StringComparison]::OrdinalIgnoreCase)) {
        throw "目录越出 Vault：$target"
    }
    New-Item -ItemType Directory -Path $target -Force | Out-Null
}

function Write-VaultFile {
    param([string]$RelativePath, [string]$Content)

    $target = [IO.Path]::GetFullPath((Join-Path $resolvedVault $RelativePath))
    if (-not $target.StartsWith($resolvedVault, [StringComparison]::OrdinalIgnoreCase)) {
        throw "文件越出 Vault：$target"
    }
    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        Write-Output "跳过已有文件：$RelativePath"
        return
    }
    $parent = Split-Path -Parent $target
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    [IO.File]::WriteAllText($target, $Content, [Text.UTF8Encoding]::new($false))
    Write-Output "已创建：$RelativePath"
}

$today = Get-Date -Format 'yyyy-MM-dd'

Write-VaultFile '00-首页/知识库首页.md' @"
---
类型: 项目首页
项目: $ProjectName
研究领域: $ResearchDomain
更新日期: $today
---

# $ProjectName 知识库

## 快速入口

- [[01-研究问题/研究问题清单]]
- [[02-文献/文献索引]]
- [[03-教程/教程索引]]
- [[04-实验/实验索引]]
- [[05-AI知识/AI知识索引]]
- [[06-会议/会议索引]]
- [[07-成果/成果索引]]
- [[08-项目管理/项目待办]]

## 当前目标

- [ ] 定义第一个可验证研究问题
- [ ] 建立基线
- [ ] 完成第一次可复现实验
"@

Write-VaultFile '01-研究问题/研究问题清单.md' @"
# 研究问题清单

研究领域：$ResearchDomain

## RQ-001

**问题：**

**基线：**

**主要变量：**

**评价指标：**

**关联文献：**

**关联实验：**
"@

Write-VaultFile '02-文献/文献索引.md' @"
# 文献索引

## 待读

## 阅读中

## 已完成

## 返回

- [[00-首页/知识库首页]]
"@

Write-VaultFile '03-教程/教程索引.md' "# 教程索引`n`n## 学习中`n`n## 已掌握`n`n- [[00-首页/知识库首页]]`n"
Write-VaultFile '04-实验/实验索引.md' "# 实验索引`n`n## 设计中`n`n## 进行中`n`n## 已完成`n`n## 失败案例`n`n- [[00-首页/知识库首页]]`n"
Write-VaultFile '05-AI知识/AI知识索引.md' "# AI 知识索引`n`n## 待审核`n`n## 已整理`n`n## 技术决策`n`n- [[00-首页/知识库首页]]`n"
Write-VaultFile '06-会议/会议索引.md' "# 会议索引`n`n## 最近会议`n`n## 待落实决策`n`n- [[00-首页/知识库首页]]`n"
Write-VaultFile '07-成果/成果索引.md' "# 成果索引`n`n## 报告`n`n## 论文`n`n## 演示`n`n- [[00-首页/知识库首页]]`n"
Write-VaultFile '08-项目管理/项目待办.md' "# 项目待办`n`n## 本周`n`n- [ ] 定义研究问题`n- [ ] 建立实验基线`n`n## 已完成`n"

Write-VaultFile 'AGENTS.md' @"
# 科研知识库 AI 协作规则

- 当前 Vault 是本项目的 Obsidian 知识库。
- 用户说“归档到知识库”“总结并写入 Obsidian”时，将有长期价值的内容写入 `05-AI知识/00-待审核`。
- 在项目语境下，“帮我总结”默认按上述归档处理；无关内容只在对话中回答。
- AI 笔记必须区分已确认事实、推测、待验证内容、技术决策和下一步行动。
- 未经审核不得把 AI 内容标记为已整理或已确认事实。
- 不修改 ZotLit 的 `%%zt-managed%%` 管理区，不移动或改写原始资料。
- 实验必须记录硬件、软件、模型、数据集、参数、指标和原始结果。
"@

Write-VaultFile '99-模板/AI知识模板.md' @"
---
类型: AI知识摘要
日期: {{date}}
项目: $ProjectName
来源: AI对话
审核状态: 待审核
可信度: 待核验
标签:
  - AI知识摘要
---

# {{title}}

## 一句话结论

## 问题背景

## 核心知识

## 已确认事实

## 推测与待验证内容

- [ ]

## 技术决策

## 下一步行动

- [ ]

## 证据与来源
"@

Write-VaultFile '99-模板/实验模板.md' @"
---
类型: 实验
实验编号:
日期: {{date}}
项目: $ProjectName
状态: 设计中
研究问题:
硬件:
系统版本:
模型版本:
数据集版本:
---

# {{title}}

## 研究问题与假设

## 基线与对照

## 环境与版本

## 数据集与划分

## 唯一主要变量

## 执行步骤

## 原始结果

| 配置 | 指标 | 结果 | 备注 |
|---|---|---:|---|

## 失败案例

## 结论

## 可复现入口

## 下一步
"@

Write-VaultFile '99-模板/会议模板.md' @"
---
类型: 会议
日期: {{date}}
项目: $ProjectName
状态: 待整理
---

# {{title}}

## 会议目标

## 讨论与证据

## 已达成决策

## 未解决问题

## 行动项

- [ ] 负责人：；截止日期：；交付物：
"@

Write-VaultFile '.obsidian/app.json' "{`n  `"attachmentFolderPath`": `"附件`",`n  `"alwaysUpdateLinks`": true`n}`n"
Write-VaultFile '.obsidian/templates.json' "{`n  `"folder`": `"99-模板`"`n}`n"

Write-Output "初始化完成：$resolvedVault"
