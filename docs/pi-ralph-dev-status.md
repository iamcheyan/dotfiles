# Pi-Ralph 插件开发状态

## 最后更新: 2026-05-31 12:00

---

## 一、已完成的功能

### 1. pi.sh 安装脚本
- `--reinstall` 参数替代旧的 `-f`
- 会清理旧安装、重新跑 init.sh、同步缺失的 skills
- 新机器首次运行自动安装 pi-ralph 到 `~/Development/pi/fork/pi-ralph/`

### 2. init.sh（pi 安装器）
- skills 列表改为动态遍历 `skills/*/` 目录，不再硬编码
- 推送到 `iamcheyan/pi` 仓库

### 3. TUI 崩溃修复
- `RalphBusyEditor.render` 的 `line.slice(0, width)` 改为按可见宽度截断（CJK 字符 = 2 列）
- `setWorkerUiStatus` 的 label 也按 `process.stdout.columns` 截断

### 4. Worker 进程管理修复
- 子进程 stdout buffer 在 close 时 flush（防止最后一行 JSON 丢失）
- 收到 `<promise>COMPLETE</promise>` 后 1 秒自动 resolve，不等进程退出
- `safeResolve` 防止重复 resolve

### 5. 完整的 /ralph 流程（核心）

```
/ralph → 菜单 → Start new task
  ↓
📋 Step 1/4: 需求已记录
  ↓
🧠 AI 理解 + 问答（1-5 个问题，一个一个问）
  ↓
📝 Step 3/4: 生成 PRD 草稿（可循环追问）
  ↓
🔄 转换 prd.json（失败时 AI 自动诊断修复，最多 3 次）
  ↓
📋 任务总览（汇总界面）
  ↓ 确认
🚀 开始执行（Iteration 1/N...）
```

### 6. 确认对话框优化
- 两个确认（Replace Draft + Archive Task）合并为一个
- 中文提示，清晰说明归档逻辑

### 7. 通知保留
- 步骤通知用 `warning` 类型（追加新行）而非 `info`（原地替换）
- 代价：每条前面有 `Warning:` 前缀

### 8. 语言匹配
- intake 和 draft skill 都要求 AI 用用户相同的语言回复

---

## 二、当前已知问题

### ~~🔴 汇总界面被跳过（已修复）~~
- 原因：转换 worker 完成后，`status.finish("completed")` 清除 working overlay（`setWorkingVisible(false)` + `setEditorComponent(undefined)`），然后**立即**调用 `ctx.ui.confirm`
- TUI 可能还没完成 re-render，confirm 对话框被创建在未清理的 overlay 后面，或输入事件被自动消费
- 修复：在 confirm 前加 300ms delay，让 TUI 有时间完成 overlay 清理
- 同时清理了所有 `[debug]` 日志和 `reportDebugEvent` 调试基础设施

### 🟡 Max Iterations 提示已移除
- 直接用故事总数作为执行上限
- 用户如果想限制，需要通过其他方式

### 🟡 通知前缀 `Warning:`
- 所有步骤通知显示为 `Warning: 📋 Step 1/4:...`
- 原因：pi 内核的 `showStatus` 会原地替换，只有 `showWarning` 才追加
- 需要改 pi 内核加 `showInfo` 方法才能解决

---

## 三、文件位置

### 本地
- 插件源码: `/Users/tetsuya/Development/pi/fork/pi-ralph/index.ts`
- Skills: `/Users/tetsuya/Development/pi/fork/pi-ralph/skills/`
- 扩展 symlink: `~/.pi/agent/extensions/pi-ralph.ts` → 源码
- Skills 安装: `~/.pi/agent/skills/ralph-*/SKILL.md`

### 远程 (192.168.3.82)
- 插件源码: `~/development/pi/fork/pi-ralph/index.ts`
- Skills: `~/.pi/agent/skills/ralph-*/SKILL.md`
- 注意：远程的 skills 是副本（非 symlink），更新后需要手动 cp

### Git 仓库
- pi-ralph: `https://github.com/iamcheyan/pi-ralph.git`
- pi (init.sh): `https://github.com/iamcheyan/pi.git`
- dotfiles (pi.sh): `https://github.com/iamcheyan/dotfiles.git`

---

## 四、关键 Skill 文件

| Skill | 用途 | 关键规则 |
|-------|------|----------|
| ralph-intake | 理解需求 + 提问 | 1-5 个问题，语言匹配，不可返回空 |
| ralph-prd-draft | 生成 PRD 草稿 | 返回 `{type:"questions"}` 或 `{type:"draft"}`，语言匹配 |
| ralph | 转换 PRD→prd.json | 定义 prd.json 格式，静态转换 |
| ralph-worker | 执行单个故事 | 实现 + 测试 + 提交 |

---

## 五、TypeScript 类型

```typescript
interface IntakeResult {
  understanding: string
  questions: DraftQuestion[]
}

type DraftGenerationResult = DraftQuestionsResult | DraftReadyResult

interface DraftQuestionsResult {
  type: "questions"
  questions: DraftQuestion[]
}

interface DraftReadyResult {
  type: "draft"
  prdPath: string
  title: string
  summary: string
}

interface PrdJson {
  project: string
  branchName: string
  description: string
  userStories: UserStory[]
}

interface UserStory {
  id: string
  title: string
  description: string
  acceptanceCriteria: string[]
  priority: number
  passes: boolean
  notes: string
}
```

---

## 六、下一步 TODO

1. ~~**修复汇总界面被跳过的问题**~~ — ✅ 已修复（加 300ms delay）
2. **去掉 `Warning:` 前缀** — 需要改 pi 内核加 `showInfo` 方法
3. **远程机器完整测试** — 确认所有修复都生效
4. ~~**清理 debug 日志**~~ — ✅ 已清理（移除所有 `[debug]` 和 `reportDebugEvent`）
