---
name: mobile-ondevice-ai
description: Design and audit on-device and hybrid cloud-edge mobile AI features covering quantization, NPU/GPU/ANE delegates, memory/thermal budgets, prompt/tool safety, and fallback routing. Use when integrating local LLMs/SLMs, vision models, MediaPipe/ExecuTorch/CoreML/LiteRT, or agentic mobile features.
---

# Mobile On-Device AI

Engineering playbook for shipping reliable on-device and hybrid edge-cloud AI features on Android and iOS without OOMs, thermal throttling, or runaway latency.

## When to Use

- Integrating on-device SLMs/LLMs (Gemini Nano / AICore, Llama.cpp, MLC LLM, ExecuTorch, MediaPipe LLM Inference, Apple Foundation Models / CoreML)
- Adding on-device vision/OCR/embedding pipelines (CameraX + LiteRT/TFLite, ML Kit, Vision/CoreML)
- Designing hybrid edge-cloud routing (local inference first, cloud fallback on low-end devices or complex queries)
- Auditing AI mobile PRs for memory spikes, main-thread blocking, model asset bloat, or prompt-injection exposure

## Workflow

1. **Device Capability & Tiering Gate**:
   - Never assume flagship NPU/RAM across the install base. Gate model execution on **available RAM**, **SoC/NPU delegate availability** (NNAPI/LiteRT GPU/Hexagon/Apple Neural Engine), **thermal status** (`PowerManager.getCurrentThermalStatus()` on Android, `ProcessInfo.thermalState` on iOS), and **battery/low-power mode**.
   - Define an explicit fallback chain: `On-Device NPU -> On-Device CPU (smaller quant) -> Cloud API -> Deterministic UX fallback`.
2. **Model Packaging & Lifecycle**:
   - Never bundle multi-hundred-MB weights inside the base APK/IPA; use **Play Feature Delivery / Play Asset Delivery**, **Apple On-Demand Resources / Background Assets**, or verified resumable CDN downloads with SHA-256 checksum verification.
   - Load models lazily off the main thread, keep a single lifecycle-aware runtime instance, and unload/release native buffers (`ByteBuffer` / `OrtSession` / `MLModel`) on `onTrimMemory` / `didReceiveMemoryWarning` or background timeout.
3. **Latency, Quantization & Streaming UX**:
   - Match quantization (`INT4` / `INT8` / `FP16`) to task sensitivity; measure **TTFT (Time to First Token)**, **tokens/sec**, and **peak RSS** on mid-tier target hardware, not just simulators.
   - Stream tokens incrementally to UI and support instant user cancellation (`Job.cancel()` / `Task.cancel()`) wired to native inference stop signals.
4. **Privacy, Safety & Prompt Boundaries**:
   - Strip unnecessary PII before any cloud fallback; log telemetry with anonymized latency/tier metrics only (never log raw user prompts containing sensitive financial/health/personal data).
   - Treat OCR/WebView/push/deep-link text fed into local agents as **untrusted data**; restrict tool calls invoked by on-device models with explicit schema validation and user confirmation for destructive actions.

## Checklist

- [ ] Large model weights (> 10 MB) are dynamically fetched with SHA-256 verification, not bundled in base binary
- [ ] Inference runs strictly off the main/UI thread with cancellation support when leaving the screen
- [ ] Memory pressure (`onTrimMemory` / `didReceiveMemoryWarning`) and thermal throttling (`MODERATE`/`SEVERE`) hooks pause or downgrade local inference
- [ ] Device capability check gates low-RAM devices (< 6 GB RAM for 1B–3B SLMs) to cloud or lighter pipeline
- [ ] Sensitive user inputs are redacted before telemetry or cloud fallback
- [ ] Model outputs driving UI actions or tool calls pass strict structured-output / schema validation

## Output Format

1. **Deployment Architecture**: Recommended Edge vs. Hybrid Cloud-Edge routing diagram
2. **Resource & Hardware Budget**: Estimated RAM footprint, delivery strategy, and delegate targets
3. **Risk Audit (`P0`–`P2`)**: OOM, thermal, binary bloat, main-thread, and safety findings with fixes
