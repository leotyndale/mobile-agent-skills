---
name: android-compose-architect
description: Design, refactor, and review Jetpack Compose UI architecture with Unidirectional Data Flow (UDF), recomposition stability, and state-holder separation. Use when building new Compose screens, migrating XML/Fragment UIs, or fixing excessive recompositions.
---

# Android Compose Architect

Production-grade guidance for structuring scalable Jetpack Compose screens with predictable state management, minimal recompositions, and clean ViewModel boundaries.

## When to Use

- Designing a new Jetpack Compose feature screen, bottom sheet, or adaptive layout
- Reviewing Compose PRs for state hoisting, unstable parameters, or side-effect misuse
- Migrating legacy `Fragment` / XML / `RecyclerView` screens to Compose or hybrid interoperability (`ComposeView` / `AndroidView`)
- Diagnosing unnecessary recompositions flagged by Layout Inspector or Compose Compiler Metrics

## Workflow

1. **Boundary & State Modeling**:
   - Define an `@Immutable` or `@Stable` `UiState` data class (single source of truth) and a sealed `UiEvent` / `UiAction` interface for user intents.
   - Separate transient one-shot effects (`Snackbar`, navigation, haptic feedback) from persistent `UiState`; model one-shot effects via `Channel` / `SharedFlow` or state-backed consumed events.
   - Keep `ViewModel` completely free of `Context`, `View`, `NavController`, or Compose `State<T>` objects.
2. **State Hoisting & Slot APIs**:
   - Split every screen into a **stateful route composable** (`ScreenRoute(viewModel = ...)` collecting `collectAsStateWithLifecycle()`) and a **stateless pure composable** (`ScreenContent(state, onAction)`).
   - Never pass `ViewModel` down into child composables; pass immutable state slices and method references / stable lambdas (`remember(key) { ... }`).
3. **Recomposition & Stability Audit**:
   - Replace unstable `List<T>` / `Map<K, V>` in hot `LazyColumn` items with `kotlinx.collections.immutable.ImmutableList` or `@Immutable` wrapper types (or enable Strong Skipping Mode and verify compiler reports).
   - Defer state reads into layout/draw phases (`Modifier.offset { IntOffset(...) }`, `drawBehind { ... }`, `graphicsLayer { ... }`) for animations and scroll offsets instead of reading `.value` during composition.
   - Ensure every `LazyColumn` / `LazyRow` provides deterministic `key = { item.id }` and `contentType = { item.type }`.
4. **Side-Effect Discipline**:
   - Audit `LaunchedEffect`, `DisposableEffect`, `SideEffect`, and `produceState`: keys must represent the exact dependencies that invalidate the effect; avoid `LaunchedEffect(Unit)` when an ID or parameter can change.
   - Use `rememberUpdatedState` inside long-lived effects that invoke caller callbacks.
5. **Adaptive UI & Interop**:
   - Support window size classes (`WindowWidthSizeClass`), `imePadding()`, and edge-to-edge `WindowInsets` cleanly.
   - When embedding Compose inside legacy Views (e.g., floating overlays or `RecyclerView`), configure `ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed` or `DisposeOnDetachedFromWindow` appropriately.

## Checklist

- [ ] Stateless `Content` composable is previewable with `@Preview` and zero DI/ViewModel dependencies
- [ ] Flow collection uses `collectAsStateWithLifecycle()` rather than `collectAsState()`
- [ ] `LazyColumn` / `LazyGrid` items specify stable `key` and `contentType`
- [ ] Expensive derived calculations use `remember(keys)` or `derivedStateOf` (for high-frequency state like `LazyListState.firstVisibleItemIndex`)
- [ ] No business logic, repository calls, or raw `CoroutineScope.launch` inside `@Composable` bodies (only UI event dispatch via `rememberCoroutineScope()` when tied to user gestures)
- [ ] Compose Compiler metrics (`composeCompilerReports`) show zero unexpected `unstable` parameters on hot screen components
- [ ] Accessibility semantics (`contentDescription`, `Role`, minimum `48.dp` touch target) are verified

## Output Format

Provide findings and code changes in this structure:

1. **Architecture Verdict**: `PASS` | `NEEDS_REFACTOR` | `BLOCKING_ISSUES`
2. **State & UDF Diagram**: Brief summary of `State` / `Event` / `Effect` flow for the screen
3. **Issues Found** (ordered by severity `P0`–`P2`):
   - File & symbol, why it triggers recomposition/leak/coupling, and exact fix
4. **Refactored Code / Diff**: Ready-to-compile Kotlin snippet with `@Preview`
