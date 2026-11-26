---
name: ios-swiftui-architect
description: Design and audit SwiftUI and Swift 6 concurrency architectures using @Observable, structured concurrency, proper state ownership, and UIKit interoperability. Use when building iOS screens, fixing SwiftUI view invalidations, or resolving @MainActor data races.
---

# iOS SwiftUI Architect

Production patterns for modern iOS apps using SwiftUI, `@Observable` (Observation framework), Swift Concurrency (`@MainActor`, `Sendable`, `async/await`), and UIKit interop.

## When to Use

- Architecting new SwiftUI features, navigation stacks (`NavigationStack` / `NavigationSplitView`), or modular iOS targets
- Reviewing SwiftUI code for unnecessary view body re-evaluations, retain cycles, or misused property wrappers
- Migrating `ObservableObject` / `@Published` codebases to `@Observable` and Swift 6 strict concurrency
- Integrating `UIViewRepresentable` / `UIViewControllerRepresentable` with SwiftUI state

## Workflow

1. **State Ownership & Property Wrappers**:
   - Verify ownership rules: use `@State` (with `@Observable` models or local value state) when the view **owns** the lifecycle; use plain `let` or `@Bindable` when injected from a parent; use `@Binding` only for two-way primitive/value mutation.
   - Flag `@ObservedObject` creating new inline instances (memory reset on parent redraw) or unnecessary `@EnvironmentObject` coupling where scoped dependency injection suffices.
2. **View Granularity & Rendering Performance**:
   - Keep `body` pure and lightweight—zero networking, sorting large collections, `DateFormatter` instantiation, or side effects inside `body`.
   - Extract subviews so Observation tracks property reads per subview rather than invalidating an entire root screen.
   - Ensure `ForEach` uses stable, unique `Identifiable` IDs—never indices for mutable lists.
3. **Swift Concurrency & Thread Safety**:
   - Mark UI state holders `@MainActor`.
   - Prefer `.task(id:)` over `.onAppear { Task { ... } }` so SwiftUI cancels in-flight async work automatically when the view disappears or `id` changes.
   - Check `Task { ... }` closures and Combine sinks for `[weak self]` where object lifetime extends beyond the view, and verify `Sendable` conformance across actor boundaries.
4. **Navigation & Deep Linking**:
   - Model navigation via typed `Hashable` route enums (`NavigationPath` or typed `[Route]`) decoupled from view implementations, enabling programmatic deep-link restoration.
5. **UIKit Interoperability**:
   - In `UIViewRepresentable`, implement `Coordinator` for delegates/targets and ensure `updateUIView` is idempotent (diff against current state to avoid infinite layout loops).

## Checklist

- [ ] View models / stores owning UI state are `@MainActor` and `@Observable` (or properly isolated `ObservableObject`)
- [ ] Async work triggered by view appearance uses `.task` / `.task(id:)` with cancellation handling (`CancellationError` not treated as user error)
- [ ] `DateFormatter` / `NumberFormatter` / `JSONDecoder` are reused or static, never allocated inside `body`
- [ ] `ForEach` relies on stable domain IDs, not `\.self` on non-unique values or array indices
- [ ] `UIViewRepresentable.updateUIView` guards against redundant mutations and avoids triggering state changes synchronously during layout
- [ ] Dynamic Type, VoiceOver labels, and dark mode semantic colors (`Color(.systemBackground)` / asset catalog) are respected

## Output Format

1. **Architecture & Concurrency Status**: `CLEAN` | `WARNINGS` | `RACE_OR_PERF_RISK`
2. **State Flow Overview**: Ownership graph (`Root` -> `Feature Store` -> `Subviews`)
3. **Detailed Findings (`P0`–`P2`)**: Issue, SwiftUI invalidation or actor-isolation impact, and corrected Swift snippet
