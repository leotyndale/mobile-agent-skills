---
name: android-crash-triage
description: Triage Android Java, Kotlin, and native (NDK/tombstone) crashes, ROM-specific framework exceptions, and ANR traces into root-cause diagnoses and safe production fixes. Use when analyzing stack traces, Firebase Crashlytics/Sentry exports, or vendor-specific Android crashes.
---

# Android Crash Triage

Structured root-cause analysis and safe mitigation playbook for JVM exceptions, native `SIGSEGV`/`SIGABRT` crashes, and OEM/ROM fragmentation bugs.

## When to Use

- Analyzing a Java/Kotlin stack trace, obfuscated R8 trace, or NDK tombstone (`SIGSEGV`, `SIGABRT`, `SIGBUS`)
- Investigating ANR `traces.txt` (`main` thread blocked, lock contention, Binder starvation)
- Diagnosing OEM/ROM-specific crashes (MIUI/HyperOS, ColorOS, OriginOS, HarmonyOS/EMUI, OneUI) concentrated on specific API levels or chipsets
- Evaluating whether a crash needs a structural lifecycle fix vs. a targeted defensive guard

## Workflow

1. **Fingerprint & Classify the Failure**:
   - Extract exception class, normalized message, top app frame vs. framework frame, Android API level, ABI, and device OEM distribution.
   - Distinguish **App Logic Bugs** (nullability, `IllegalStateException` after `onSaveInstanceState`, `ConcurrentModificationException`, `BadParcelableException`) from **System/ROM Framework Bugs** (crashes originating inside `android.os.Handler` / `Looper.loop` / `WindowManagerGlobal` / `ActivityThread` with zero app frames on stack).
2. **Thread & Lifecycle Reconstruction**:
   - Trace the lifecycle state at crash time: `onCreate` -> `onResume` -> `onStop` -> `onDestroy` -> background process death & restoration.
   - For `IllegalStateException: Can not perform this action after onSaveInstanceState`, trace async callbacks (`Handler`, `RxJava`, `Coroutine`, network response) mutating UI/fragments without lifecycle awareness.
   - For `WindowManager$BadTokenException`, trace `Dialog` / `PopupWindow` / `Toast` shown after `Activity.isFinishing()` or `isDestroyed()`.
3. **Native & JNI Triage (if applicable)**:
   - Inspect signal (`SIGSEGV` -> null/dangling pointer or UAF; `SIGABRT` -> `abort()`, JNI `CheckJNI` failure, `pthread` mutex corruption; `FORTIFY` failures).
   - Map `pc` offset against unstripped `.so` symbols and check thread ownership / JNI `LocalRef` leaks (`> 512` refs).
4. **ANR `traces.txt` Analysis**:
   - Inspect `"main" prio=5 tid=1`: check state (`Blocked`, `Waiting`, `Native`, `Runnable`).
   - If `Blocked`, find the lock holder thread ID (`- waiting to lock ... held by thread N`) and walk the deadlock or slow-I/O chain.
5. **Safe Remediation & Guardrails**:
   - Never swallow `Throwable` globally without telemetry and strict allowlisting.
   - For true unfixable ROM crashes inside `Looper.loop()`, require exact exception class + message + OEM/API allowlist + non-fatal reporting, never hiding app bugs.

## Checklist

- [ ] Root cause pinpointed to exact thread, lifecycle state, and state-transition race
- [ ] Obfuscated frames verified or flagged as needing `mapping.txt` / unstripped `.so` symbols
- [ ] Proposed fix handles process death / configuration change / background-to-foreground transitions
- [ ] No blanket `try { ... } catch (Exception ignored) {}` hiding state corruption
- [ ] Regression unit/instrumentation test case defined to reproduce the failure condition

## Output Format

1. **Crash Classification**: `App Lifecycle Bug` | `Concurrency / Lock Race` | `Native Memory / JNI` | `OEM / Framework Bug` | `ANR`
2. **Root Cause Chain**: Step-by-step execution sequence leading to failure
3. **Fix Strategy**: Primary structural fix + defensive guard (if OEM bug)
4. **Verification**: How to reproduce and verify the fix (unit test, StrictMode, or Monkey/UI test)
