---
name: obsidian-research-kb
description: 初始化或升级面向科研与课题项目的 Obsidian 知识库，并将文献、实验、会议和 AI 对话整理为可追溯 Markdown。用户提到新建科研知识库、复用 Obsidian 工作流、归档研究对话、配置 Zotero/ZotLit 或检查 Vault 时使用。
---

# Obsidian Research KB

为一个具体研究项目建立本地优先、普通 Markdown 驱动的 Obsidian 知识库。

## 模式

根据请求选择最小模式：

- **初始化**：新项目或新 Vault。运行 `scripts/init_research_vault.ps1`。
- **升级**：已有 Vault。先审计文件和配置，只补缺失结构，不覆盖用户笔记。
- **插件安装**：用户明确要求后，运行 `scripts/install_plugins.ps1`。
- **知识归档**：把当前对话提炼为待审核笔记，更新 AI 索引。
- **文献整理**：保留 ZotLit 管理区，只填写人工研究区并关联研究问题。
- **验证**：运行 `scripts/validate_vault.ps1` 检查结构和内部链接。

需要目录、属性和证据链约定时，读取 [references/schema.md](references/schema.md)。

## 初始化流程

1. 确认目标 Vault 路径、项目名称和研究领域；可从当前项目合理推断时不重复询问。
2. 执行：

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/init_research_vault.ps1 `
     -VaultPath "<绝对路径>" `
     -ProjectName "<项目名称>" `
     -ResearchDomain "<研究领域>"
   ```

3. 默认不覆盖已有文件。只有用户明确要求重建模板时才使用 `-Force`。
4. 用户明确要求插件时，再运行安装脚本；不要默认扩大网络访问或插件权限。
5. 运行验证脚本并报告实际结果。

## 知识归档

用户说“归档到知识库”“总结并写入 Obsidian”或同义表达时：

1. 删除寒暄、重复过程和无长期价值内容，不机械保存完整聊天。
2. 区分已确认事实、AI 推测、待验证内容、技术决策和下一步行动。
3. 写入 `<Vault>/05-AI知识/00-待审核`，默认 `审核状态: 待审核`。
4. 更新 `<Vault>/05-AI知识/AI知识索引.md`。
5. 长期技术决策另建 ADR；没有用户确认不得标记为已审核。

## Zotero 与 ZotLit

- Zotero 管理原始文献、PDF 和标注；Obsidian 管理研究理解和跨主题链接。
- ZotLit 模板与 Obsidian 核心模板互相独立。
- 不修改 `%%zt-managed%%` 与 `%%/zt-managed%%` 之间的内容。
- “更新文献笔记”只刷新管理区；只有新建且尚无个人内容的测试笔记才可使用“覆盖文献笔记”。
- 文献结论必须区分原文证据与研究者判断。

## 安全边界

- 不移动或改写原始资料，除非用户明确要求。
- 不覆盖已有用户笔记；同名文件默认跳过并报告。
- 不保存 API 密钥、密码、访问令牌或个人隐私。
- 不把 AI 推测写成实验事实；性能数字必须有论文、日志或实测来源。
- 删除、批量移动、公开发布 Vault 前必须再次确认精确范围。

## 完成检查

- 首页能进入研究问题、文献、实验、会议、AI 知识和成果模块。
- 模板包含可复现环境、证据来源和状态属性。
- 内部 Wiki 链接没有缺失目标。
- 插件只是增强层；禁用插件后 Markdown 仍可阅读。
