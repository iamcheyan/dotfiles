---
name: OpenJLPT 项目状态
description: 离线JLPT考试App项目，当前在构建N2题库阶段，有12个JSON题库文件和3个AI出题供应商
type: project
originSessionId: 1d2ab625-c22a-41d8-a16a-9a4a0a601a0e
---
OpenJLPT — 完全离线的JLPT模拟考试App，架构 WebView + 静态HTML/JS + 本地JSON，部署在GitHub Pages。

**Why:** 用户需要一个能在电子墨水屏设备上使用的日语考试练习工具。

**How to apply:**
- 当前阶段：N2题库构建。详细进度见 `PROGRESS.md`
- 出题程序 `generate_bank.py` 使用3个模型（智谱/ARK/MiMo）各出题，用智谱审核
- ARK端点是 `/api/coding/v3/chat/completions`（不是 `/api/v3/`）
- 题库文件在 `data/n2/*.json`，每道题包含 `generated_by`/`reviewed_by`/`review_explanation`
- 下一步：补全题库→写拼卷HTML→交互功能
