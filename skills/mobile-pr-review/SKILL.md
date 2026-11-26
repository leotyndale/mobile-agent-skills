---
name: mobile-pr-review
description: Conduct a high-signal mobile pull request review focusing on lifecycle safety, concurrency, backward compatibility, UI states, and test coverage across Android, iOS, and Flutter. Use when reviewing diffs or self-checking a branch before opening a PR.
---

# Mobile PR Review

High-signal code review protocol focused on bugs that actually break mobile users in production—not bikeshedding formatting.

## When to Use

- Reviewing a mobile feature, bugfix, or refactor PR (Android, iOS, Flutter, KMP)
- Self-auditing local `git diff` before pushing or requesting peer review
- Triaging high-risk changes touching navigation, persistence migrations, SDK upgrades, or shared core modules

## Workflow

1. **Understand Scope & Blast Radius**:
   - Inspect changed files, public API/contract diffs, database/preference schema changes, and manifest/plist permission additions.
   - Flag unintended permission additions, Gradle/Pod dependency bumps, or public API breaks in shared modules.
2. **Lifecycle & Concurrency Safety**:
   - Check every async operation (Coroutine, Swift Task, RxJava, Dart Future/Stream) for cancellation on lifecycle exit, main-thread safety, and race conditions on rapid user double-taps.
   - Verify process death / background restoration (`SavedStateHandle`, state restoration, cold-launch deep links).
3. **Data & Migration Backward Compatibility**:
   - If Room DB, SQLite, CoreData/SwiftData, or Proto/JSON persisted schema changed, verify an explicit **migration path** and fallback/defaults for existing users upgrading from N-2 versions.
4. **UI Edge Cases & State Completeness**:
   - Confirm all 4 UI states are handled: **Loading**, **Content**, **Empty**, and **Error (with retry)**.
   - Check RTL/i18n string resource usage (no hardcoded user-facing strings), small screens / keyboard overlap (`imePadding`), and dark mode contrast.
5. **Test & Telemetry Verification**:
   - Verify unit tests cover the non-happy paths (network failure, empty payload, cancellation, schema migration) and key error/funnel metrics are preserved.

## Checklist

- [ ] No unguarded main-thread I/O, uncancelled scopes, or double-tap race conditions on submit actions
- [ ] All persisted schema or serialization changes include backward-compatible migration / `@JsonNames` / default values
- [ ] UI handles Loading, Empty, Error + Retry, rotation/resize, and keyboard insets
- [ ] Zero hardcoded user-facing strings or debug-only flags left enabled
- [ ] New permissions (`AndroidManifest.xml` / `Info.plist`) have clear product justification and graceful denial handling
- [ ] Meaningful tests cover changed business logic and edge cases

## Output Format

Keep review comments crisp, respectful, and actionable:

1. **PR Risk Level**: `LOW` | `MEDIUM` | `HIGH` (with 1-line rationale)
2. **Blocking Issues (Must Fix)**: Concrete bug/race/migration risk + suggested patch
3. **Suggestions (Non-Blocking)**: Readability, testability, or maintainability improvements
4. **Verification Checklist**: Commands/scenarios the author should run before merge
