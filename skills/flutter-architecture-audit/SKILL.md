---
name: flutter-architecture-audit
description: Audit Flutter applications for widget rebuild amplification, state management hygiene (Riverpod/Bloc), isolate offloading, shader/impeller jank, and package/FFI platform boundaries. Use when designing Flutter modules, fixing UI frame drops, or reviewing Dart PRs.
---

# Flutter Architecture Audit

Engineering review framework for scalable Flutter codebases covering state architecture, frame pacing (Impeller/Skia), memory management, and platform channel hygiene.

## When to Use

- Reviewing Flutter feature PRs using Riverpod, Bloc/Cubit, or custom `ChangeNotifier` / `ValueNotifier`
- Debugging 60/120 fps frame drops (`build` / `layout` / `paint` spikes in Flutter DevTools)
- Designing multi-package Flutter monorepos (Melos) or Add-to-App hybrid native/Flutter integrations
- Auditing `MethodChannel` / `Pigeon` / FFI bridges and memory retention

## Workflow

1. **Widget Tree & Rebuild Isolation**:
   - Flag monolithic `build()` methods (> 80 lines) and helper methods returning `Widget` instead of dedicated `StatelessWidget` classes (helper methods prevent Flutter element-tree short-circuiting and `const` optimization).
   - Check `const` constructors on static subtrees, `RepaintBoundary` around high-frequency animations/custom painters, and scoped selectors (`context.select`, `ref.watch(provider.select(...))`, `BlocSelector`) to prevent full-screen rebuilds.
2. **State & Side-Effect Architecture**:
   - Verify strict separation: `Widget` (UI) -> `Notifier / Bloc` (presentation state) -> `Repository / UseCase` (domain/data). No HTTP calls, JSON decoding, or `SharedPreferences` directly inside widgets.
   - Check `initState` / `dispose` symmetry: every `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`, and `StreamSubscription` must be disposed.
   - Guard async callbacks after `await` with `if (!mounted) return;` (`context.mounted` for `BuildContext`).
3. **Rendering & Isolate Offloading**:
   - Detect expensive operations on the UI isolate: large `jsonDecode` (> 50 KB), image processing, crypto, or heavy list sorting—offload via `Isolate.run()`.
   - Flag `Opacity` wrapping large subtrees or animations (prefer `AnimatedOpacity` or color alpha), `saveLayer()` triggers, and `ListView(children: ...)` used for unbounded lists instead of `ListView.builder` / `SliverList`.
4. **Platform Interop & Add-to-App**:
   - Prefer type-safe **Pigeon** / FFI over untyped `MethodChannel` string keys.
   - In Add-to-App setups, verify `FlutterEngineGroup` reuse, lifecycle synchronization, and texture/platform-view memory disposal.

## Checklist

- [ ] Zero helper functions returning `Widget` where a `StatelessWidget` with `const` constructor belongs
- [ ] State watchers use `.select()` or granular `BlocBuilder` / `Consumer` scopes rather than watching whole state objects at page root
- [ ] All controllers and stream subscriptions are closed in `dispose()`
- [ ] `mounted` / `context.mounted` checked before using `BuildContext` or `setState` after an `await`
- [ ] Large JSON parsing or heavy CPU work runs via `Isolate.run()`
- [ ] Long lists use `ListView.builder` / `CustomScrollView` slivers with `itemExtent` or `prototypeItem` when item heights are uniform

## Output Format

1. **Audit Verdict**: `PASS` | `REFACTOR_RECOMMENDED` | `JANK_OR_LEAK_DETECTED`
2. **Findings (`P0`–`P2`)**: File, widget/provider symbol, root cause (rebuild amplification / isolate block / leak), and fixed Dart snippet
3. **DevTools Verification**: Specific Timeline/Memory/Widget Rebuild Profiler checks to run next
