# Mobile Agent Skills（移动端 AI Coding Agent 工程技能库）

<p align="center">
  <b>面向 Android、iOS、Flutter 与移动端架构师的生产级 AI Agent 技能规范库</b><br />
  <sub>开箱即用，一键安装到 Claude Code、Cursor、OpenAI Codex、Antigravity、Gemini CLI 与 Windsurf</sub>
</p>

<p align="center">
  <a href="https://github.com/leotyndale/mobile-agent-skills/stargazers"><img src="https://img.shields.io/github/stars/leotyndale/mobile-agent-skills?style=flat-square&color=f59e0b" alt="Stars" /></a>
  <a href="https://github.com/leotyndale/mobile-agent-skills/actions/workflows/validate.yml"><img src="https://img.shields.io/github/actions/workflow/status/leotyndale/mobile-agent-skills/validate.yml?style=flat-square&label=CI" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-22c55e?style=flat-square" alt="License" /></a>
  <a href="https://developers.google.com/profile/u/fly"><img src="https://img.shields.io/badge/Author-Android_GDE-1f2937?style=flat-square&logo=google&logoColor=white" alt="Android GDE" /></a>
  <a href="README.md"><img src="https://img.shields.io/badge/Docs-English-334155?style=flat-square" alt="English Docs" /></a>
</p>

> **绝大多数通用 AI Coding Agent 写移动端代码像在写后端脚本**：主线程同步读盘、把 `ViewModel` 传进 Compose 子组件、忽略国产 ROM 碎片化与生命周期状态恢复、在端侧 AI 场景下把 4GB 内存低端机直接打 OOM。
>
> **Mobile Agent Skills** 将一线大厂移动端架构经验、Android GDE 工程规范与上线门禁沉淀为 **10 个可直接触发的 `SKILL.md` / `.mdc` 技能**，让你的 AI 编程助手立刻具备资深移动端架构师的审视视角。

---

## 工作原理

```mermaid
flowchart LR
    A[你的移动端仓库<br/>Android / iOS / Flutter / KMP] --> B[bash scripts/install.sh<br/>--target claude|cursor|codex|antigravity|gemini|all]
    B --> C{Agent 技能运行时}
    C --> D[架构与 UI<br/>Compose · SwiftUI · Flutter · DDD]
    C --> E[稳定性与端侧 AI<br/>性能体检 · 崩溃归因 · 端侧推理]
    C --> F[安全与发版门禁<br/>客户端安全 · PR 评审 · 上线核验]
    D & E & F --> G[结构化风险清单 + 生产级修复代码]
```

---

## 多 Agent 工具兼容性

| AI 编程工具 | `--target` 参数 | 项目级安装路径 | 自动生成格式 |
| --- | --- | --- | --- |
| **Claude Code** | `--target claude` | `.claude/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Cursor** | `--target cursor` | `.cursor/rules/<skill>.mdc` | Cursor `.mdc` 规则 |
| **OpenAI Codex** | `--target codex` | `.agents/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Antigravity** | `--target antigravity` | `.agent/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Gemini CLI** | `--target gemini` | `.gemini/skills/<skill>/SKILL.md` | `SKILL.md` |
| **一键全装** | `--target all` | 同时安装以上 5 个目录 | 自动适配格式 |

---

## 30 秒快速安装

### 方式一：安装到当前移动端项目

```bash
git clone https://github.com/leotyndale/mobile-agent-skills.git /tmp/mobile-agent-skills
bash /tmp/mobile-agent-skills/scripts/install.sh --target claude --dest /path/to/your-mobile-app
```

如果团队同时使用 Claude Code、Cursor、Codex、Antigravity，直接一条命令全量装好：

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target all --dest /path/to/your-mobile-app
```

### 方式二：安装到全局（所有项目生效）

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target claude --scope global
```

### 方式三：按需安装单个技能

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target cursor --skill android-compose-architect
```

---

## 10 个核心生产技能目录

| # | 技能名 | 领域 | 核心把关点 |
| --- | --- | --- | --- |
| 1 | [`android-compose-architect`](skills/android-compose-architect/SKILL.md) | Jetpack Compose | 严格单向数据流 UDF、`@Immutable` 稳定性、`collectAsStateWithLifecycle()`、延迟状态读取、`LazyColumn` key/contentType |
| 2 | [`android-performance-audit`](skills/android-performance-audit/SKILL.md) | Android 性能 | 冷启动 I/O 剥离、Baseline Profiles、内存泄漏审计、`TransactionTooLargeException`、R8 全量混淆裁剪 |
| 3 | [`android-crash-triage`](skills/android-crash-triage/SKILL.md) | 崩溃与 ANR 归因 | R8/NDK tombstone 堆栈定位、`onSaveInstanceState`/`BadTokenException` 时序竞争、ANR 锁链、ROM 崩溃与业务 Bug 区分 |
| 4 | [`ios-swiftui-architect`](skills/ios-swiftui-architect/SKILL.md) | SwiftUI & Swift 6 | `@Observable` 所有权边界、`@MainActor`/`Sendable` 并发安全、`.task(id:)` 自动取消、`UIViewRepresentable` 幂等性 |
| 5 | [`flutter-architecture-audit`](skills/flutter-architecture-audit/SKILL.md) | Flutter / Dart | Widget 重建隔离（`const` / `.select()`）、`Isolate.run()` 计算卸载、Controller 释放、Pigeon/FFI 与 `FlutterEngineGroup` |
| 6 | [`mobile-ddd-modularization`](skills/mobile-ddd-modularization/SKILL.md) | 模块化与 DDD | `:api`/`:impl` 隔离、限界上下文、DTO/Domain/DB 防腐层映射、无环 Gradle/SPM/Melos 依赖与 Konsist 守卫 |
| 7 | [`mobile-ondevice-ai`](skills/mobile-ondevice-ai/SKILL.md) | 端侧与端云协同 AI | 内存/NPU/温控分级门禁、Play Asset/Apple ODR 动态下发 + SHA-256 校验、`INT4`/`INT8` 预算、Prompt 与工具调用安全 |
| 8 | [`mobile-security-review`](skills/mobile-security-review/SKILL.md) | 客户端安全 | Keystore/Keychain 密钥存储、TLS/ATS/TrustManager 审计、导出组件与 DeepLink 校验、WebView JSBridge 防护 |
| 9 | [`mobile-pr-review`](skills/mobile-pr-review/SKILL.md) | 移动端 PR 评审 | 生命周期并发竞争、N-2 数据库/Proto 兼容迁移、Loading/Content/Empty/Retry 四态完整度、新增权限审计 |
| 10 | [`mobile-release-readiness`](skills/mobile-release-readiness/SKILL.md) | 发版上线门禁 | R8 `@Keep` 实测、`mapping.txt`/`.dSYM` 符号表上传、`PrivacyInfo.xcprivacy` 与 Play Data Safety、`1% -> 100%` 灰度策略 |

---

## 本地校验与贡献

仓库内置自动化校验脚本与 GitHub Actions CI：

```bash
python3 scripts/validate_skills.py
bash scripts/install.sh --dry-run --target all
```

欢迎提交 KMP、React Native New Architecture、鸿蒙（HarmonyOS）、Perfetto 自动化分析等方向的移动端技能 PR！详见 [CONTRIBUTING.md](CONTRIBUTING.md)。

---

## 作者与关联开源项目

由 **李云鹏 (`leotyndale`)** 维护 —— Google Developer Expert (Android)、移动端与跨平台架构师、《移动开发架构设计实战》作者。

| 项目 | 简介 | Stars |
| --- | --- | --- |
| [**EnFloatingView**](https://github.com/leotyndale/EnFloatingView) | 无需一切权限的 Android 应用内悬浮窗，全 ROM 兼容（含 Jetpack Compose 混编示例） | ![Stars](https://img.shields.io/github/stars/leotyndale/EnFloatingView?style=flat-square&color=f59e0b) |
| [**AppArchitecture**](https://github.com/leotyndale/AppArchitecture) | 2026 移动端架构工程实践指南与《移动开发架构设计实战》随书源码 | ![Stars](https://img.shields.io/github/stars/leotyndale/AppArchitecture?style=flat-square&color=f59e0b) |
| [**EnCrashWhiteList**](https://github.com/leotyndale/EnCrashWhiteList) | Android ROM 崩溃白名单与主线程异常治理方案 | ![Stars](https://img.shields.io/github/stars/leotyndale/EnCrashWhiteList?style=flat-square&color=f59e0b) |
| [**EnDebugBubble**](https://github.com/leotyndale/EnDebugBubble) | 应用内悬浮调试气泡入口，实时内存监控与开关配置 | ![Stars](https://img.shields.io/github/stars/leotyndale/EnDebugBubble?style=flat-square&color=f59e0b) |
| [**etoile-almanach**](https://github.com/leotyndale/etoile-almanach) | 高颜值个人米其林与 World's 50 Best 美食地图开源模板 | ![Stars](https://img.shields.io/github/stars/leotyndale/etoile-almanach?style=flat-square&color=f59e0b) |

---

如果这套技能帮你的团队避开过线上崩溃、OOM 或低效 PR 拉扯，欢迎点一个 **Star ⭐** 支持一下！

基于 [MIT License](LICENSE) 开源。
