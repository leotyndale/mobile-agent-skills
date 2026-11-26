# Mobile Agent Skills

<p align="center">
  <b>Production-grade AI Coding Agent Skills for Android, iOS, Flutter &amp; Mobile Architecture</b><br />
  <sub>Drop-in <code>SKILL.md</code> &amp; <code>.mdc</code> engineering specs for Claude Code, Cursor, OpenAI Codex, Antigravity, Gemini CLI &amp; Windsurf</sub>
</p>

<p align="center">
  <a href="https://github.com/leotyndale/mobile-agent-skills/stargazers"><img src="https://img.shields.io/github/stars/leotyndale/mobile-agent-skills?style=flat-square&color=f59e0b" alt="Stars" /></a>
  <a href="https://github.com/leotyndale/mobile-agent-skills/actions/workflows/validate.yml"><img src="https://img.shields.io/github/actions/workflow/status/leotyndale/mobile-agent-skills/validate.yml?style=flat-square&label=CI" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-22c55e?style=flat-square" alt="License" /></a>
  <a href="https://developers.google.com/profile/u/fly"><img src="https://img.shields.io/badge/Author-Android_GDE-1f2937?style=flat-square&logo=google&logoColor=white" alt="Android GDE" /></a>
  <a href="README_ZH.md"><img src="https://img.shields.io/badge/Docs-中文版-0ea5e9?style=flat-square" alt="中文文档" /></a>
</p>

> **Most AI coding agents write mobile code like a backend script** — blocking the main thread, leaking `Activity` / `ViewModel` contexts, triggering Compose/SwiftUI/Flutter rebuild storms, and ignoring OEM ROM fragmentation or on-device AI memory budgets.
>
> **Mobile Agent Skills** gives your AI coding agent **10 battle-tested, domain-expert engineering playbooks** distilled from production mobile architecture, Google GDE best practices, and real-world release gates.

---

## How It Works

```mermaid
flowchart LR
    A[Your Mobile Repo<br/>Android / iOS / Flutter / KMP] --> B[bash scripts/install.sh<br/>--target claude|cursor|codex|antigravity|gemini|all]
    B --> C{Agent Skill Runtime}
    C --> D[Architecture & UI<br/>Compose · SwiftUI · Flutter · DDD]
    C --> E[Reliability & AI<br/>Performance · Crash Triage · On-Device AI]
    C --> F[Security & Shipping<br/>MASVS Audit · PR Review · Release Gate]
    D & E & F --> G[Structured Findings + Production-Safe Patch]
```

---

## Agent Compatibility

| AI Coding Agent | Target Flag | Install Path (Project Scope) | Format |
| --- | --- | --- | --- |
| **Claude Code** | `--target claude` | `.claude/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Cursor** | `--target cursor` | `.cursor/rules/<skill>.mdc` | Cursor `.mdc` Rule |
| **OpenAI Codex** | `--target codex` | `.agents/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Antigravity** | `--target antigravity` | `.agent/skills/<skill>/SKILL.md` | `SKILL.md` |
| **Gemini CLI** | `--target gemini` | `.gemini/skills/<skill>/SKILL.md` | `SKILL.md` |
| **All at once** | `--target all` | All 5 paths above | Auto-converted |

---

## Quick Start (30 Seconds)

### Option 1: Install into your mobile project

```bash
git clone https://github.com/leotyndale/mobile-agent-skills.git /tmp/mobile-agent-skills
bash /tmp/mobile-agent-skills/scripts/install.sh --target claude --dest /path/to/your-mobile-app
```

Install for **every supported agent** at once (great for multi-tool teams):

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target all --dest /path/to/your-mobile-app
```

### Option 2: Install globally (available across all repositories)

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target claude --scope global
```

### Option 3: Install a single skill

```bash
bash /tmp/mobile-agent-skills/scripts/install.sh --target cursor --skill android-compose-architect
```

---

## The 10 Production Skills

| # | Skill | Domain | What It Enforces |
| --- | --- | --- | --- |
| 1 | [`android-compose-architect`](skills/android-compose-architect/SKILL.md) | Jetpack Compose | Strict UDF, `@Immutable` state, `collectAsStateWithLifecycle()`, layout/draw deferred reads, `LazyColumn` keys & `contentType` |
| 2 | [`android-performance-audit`](skills/android-performance-audit/SKILL.md) | Android Perf | Cold-start budget, `Application.onCreate` I/O elimination, Baseline Profiles, Leak patterns, `TransactionTooLargeException`, R8 full mode |
| 3 | [`android-crash-triage`](skills/android-crash-triage/SKILL.md) | Crash & ANR | R8/NDK tombstone triage, `onSaveInstanceState` / `BadTokenException` races, ANR lock chains, OEM/ROM crash vs app bug classification |
| 4 | [`ios-swiftui-architect`](skills/ios-swiftui-architect/SKILL.md) | SwiftUI & Swift 6 | `@Observable` ownership rules, `@MainActor` / `Sendable`, `.task(id:)` cancellation, `UIViewRepresentable` idempotency |
| 5 | [`flutter-architecture-audit`](skills/flutter-architecture-audit/SKILL.md) | Flutter / Dart | Widget rebuild isolation (`const`, `.select()`), `Isolate.run()` offloading, controller disposal, Pigeon/FFI & `FlutterEngineGroup` |
| 6 | [`mobile-ddd-modularization`](skills/mobile-ddd-modularization/SKILL.md) | Modularization | `:api` / `:impl` split, bounded contexts, ACL mappers (DTO vs Domain vs DB), acyclic Gradle/SPM/Melos graphs, Konsist/ArchUnit rules |
| 7 | [`mobile-ondevice-ai`](skills/mobile-ondevice-ai/SKILL.md) | On-Device & Edge AI | RAM/NPU/thermal tiering, dynamic model delivery (Play Asset / Apple ODR) with SHA-256, `INT4`/`INT8` budgets, prompt/tool-call safety |
| 8 | [`mobile-security-review`](skills/mobile-security-review/SKILL.md) | Client Security | Keystore/Keychain storage, TLS/ATS/TrustManager checks, exported IPC & Deep Link validation, WebView JS-bridge hardening |
| 9 | [`mobile-pr-review`](skills/mobile-pr-review/SKILL.md) | Code Review | Lifecycle races, DB/Proto N-2 migrations, 4-state UI completeness (Loading/Content/Empty/Retry), permission diff audit |
| 10 | [`mobile-release-readiness`](skills/mobile-release-readiness/SKILL.md) | Release Gate | R8 `@Keep` verification, `mapping.txt` & `.dSYM` symbols, `PrivacyInfo.xcprivacy`, Play Data Safety, `1% -> 100%` rollout gates |

---

## Example Prompts to Trigger Skills

Once installed, prompt your agent naturally:

- *"Use `android-compose-architect` to audit `CheckoutScreen.kt` for unstable lambdas, ViewModel leakage, and LazyColumn recompositions."*
- *"Run `mobile-ondevice-ai` on our Gemma/Llama local inference wrapper before we ship it to 4 GB RAM Android devices."*
- *"Apply `mobile-security-review` and `mobile-pr-review` to my current `git diff` touching OAuth deep links and WebView."*
- *"Use `mobile-ddd-modularization` to propose an `:api` / `:impl` split for `feature-payments`."*

---

## Validation & Contributing

Every skill in this repository is checked by `scripts/validate_skills.py` and GitHub Actions CI:

```bash
python3 scripts/validate_skills.py
bash scripts/install.sh --dry-run --target all
```

Contributions of real-world mobile skills (KMP, React Native New Architecture, HarmonyOS, Perfetto automation, etc.) are warmly welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Author & Related Open-Source Projects

Curated by **Yunpeng Li (`leotyndale`)** — Google Developer Expert (Android), Mobile & Cross-Platform Architect, Author of *《移动开发架构设计实战》*.

| Project | Description | Stars |
| --- | --- | --- |
| [**EnFloatingView**](https://github.com/leotyndale/EnFloatingView) | Permission-free in-app floating window for Android across all OEM ROMs (+ Jetpack Compose interop) | ![Stars](https://img.shields.io/github/stars/leotyndale/EnFloatingView?style=flat-square&color=f59e0b) |
| [**AppArchitecture**](https://github.com/leotyndale/AppArchitecture) | 2026 Mobile Architecture Engineering Playbook & companion code | ![Stars](https://img.shields.io/github/stars/leotyndale/AppArchitecture?style=flat-square&color=f59e0b) |
| [**EnCrashWhiteList**](https://github.com/leotyndale/EnCrashWhiteList) | Android ROM crash allowlist & `Looper.loop` defensive governance | ![Stars](https://img.shields.io/github/stars/leotyndale/EnCrashWhiteList?style=flat-square&color=f59e0b) |
| [**EnDebugBubble**](https://github.com/leotyndale/EnDebugBubble) | In-app floating debug panel with live memory & feature toggles | ![Stars](https://img.shields.io/github/stars/leotyndale/EnDebugBubble?style=flat-square&color=f59e0b) |
| [**etoile-almanach**](https://github.com/leotyndale/etoile-almanach) | Editorial-grade Michelin & World's 50 Best personal almanac template | ![Stars](https://img.shields.io/github/stars/leotyndale/etoile-almanach?style=flat-square&color=f59e0b) |

---

If these skills saved your team from a production crash, ANR, or painful PR cycle, please consider giving the repo a **Star** ⭐ — it helps other mobile engineers discover it!

Licensed under the [MIT License](LICENSE).
