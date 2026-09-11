# Obsidian Research KB

一个可复用的 Codex Skill，用于初始化和维护面向科研项目的 Obsidian 知识库。

## 能做什么

- 初始化项目首页、研究问题、文献、教程、实验、会议、成果和 AI 知识目录
- 生成实验、会议和 AI 摘要模板
- 可选安装 Dataview、Tasks、Linter 和 Zotlit
- 将 AI 对话提炼到待审核目录
- 检查 Vault 内部 Wiki 链接

## 使用

```text
$obsidian-research-kb 初始化一个科研知识库，路径是 D:\\我的项目，项目名称是室内机器人视觉，研究领域是机器人视觉。
```

安装插件：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install_plugins.ps1 `
  -VaultPath "D:\\我的项目"
```

验证 Vault：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate_vault.ps1 `
  -VaultPath "D:\\我的项目"
```

## 安全设计

AI 内容先写入 `05-AI知识/00-待审核`，不会直接成为已确认事实。初始化脚本默认不覆盖已有文件；插件安装需要用户明确请求。
