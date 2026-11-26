---
name: android-performance-audit
description: Audit Android codebases for cold startup latency, UI thread jank, memory leaks, Binder/IPC overhead, and APK/AAB size bloat. Use when investigating ANRs, slow app launch, frame drops, OOMs, or preparing performance optimization PRs.
---

# Android Performance Audit

Systematic diagnostic workflow for eliminating Android cold-start bottlenecks, main-thread stalls, memory pressure, and binary bloat.

## When to Use

- App cold start TTID (Time to Initial Display) exceeds target budget (> 600–800 ms) or TTFD is degraded
- Jank / dropped frames (`> 16.6 ms` at 60 Hz or `> 8.3 ms` at 120 Hz) during scrolling or transitions
- Rising ANR rate (`Input dispatching timed out`, `BroadcastQueue`, `ContentProvider` startup) or OOM crashes
- APK / AAB download size regression or excessive dex/native `.so` footprint

## Workflow

1. **Cold Startup & AppInit Triage**:
   - Inspect `Application.onCreate()`, `ContentProvider` auto-initializers (`androidx.startup`), and Splash/Main `Activity.onCreate()`.
   - Flag synchronous disk I/O (`SharedPreferences.get*` blocking on first load, SQLite migrations, `File` reads), reflection/DI graph eager initialization, or third-party SDK `init()` calls on the main thread before first frame.
   - Recommend deferring non-critical SDKs past `reportFullyDrawn()` or moving them to lazy/background initialization.
2. **Main Thread & Render Pipeline Inspection**:
   - Search for synchronous network calls, JSON/Protobuf parsing, bitmap decoding (`BitmapFactory.decode*` without `inSampleSize` or Coil/Glide), or `Room` queries on `Dispatchers.Main`.
   - Check `RecyclerView` / `LazyColumn` for `onBindViewHolder` allocations, nested `ConstraintLayout` / `MeasureSpec` passes, `alpha` offscreen layers, and missing `BaselineProfile` rules.
3. **Memory & Leak Prevention**:
   - Audit static fields, singleton managers, `Handler` / `Runnable`, `BroadcastReceiver`, `Activity` callbacks, and `View` listeners for strong references to `Activity` or `View` (`WeakReference` or lifecycle-bound unregistering required).
   - Check `CoroutineScope` usage: verify cancellation in `onCleared()` / `LifecycleOwner`, avoid `GlobalScope`, and inspect `Bitmap` / `LruCache` sizing.
4. **Battery, Network & IPC Hygiene**:
   - Inspect `WorkManager` constraints, polling loops, wake locks, excessive `LocationManager` frequency, and large `Binder` transactions (`TransactionTooLargeException` threshold ~1 MB shared buffer).
5. **Binary Size & R8 Optimization**:
   - Verify `isMinifyEnabled = true`, `isShrinkResources = true`, `proguard-android-optimize.txt`, ABI splits (`abiFilters`), and WebP/AVIF asset compression.

## Checklist

- [ ] Zero synchronous file/network/DB I/O in `Application.onCreate()` and `Activity.onCreate()`
- [ ] `SharedPreferences` migrated to `DataStore` or preloaded asynchronously without blocking main thread
- [ ] Baseline Profiles (`androidx.profileinstaller`) configured for critical user journeys (launch + main feed scroll)
- [ ] No `Activity` or `View` references held in singletons, `static` fields, or uncancelled callbacks
- [ ] `StrictMode` (thread & VM policy) clean in debug builds for disk/network on main thread and leaked `Closeable`s
- [ ] Images decoded with target dimensions and recycled/cached via image loader
- [ ] Release build enables R8 full mode and resource shrinking

## Output Format

1. **Performance Risk Summary**: Top bottlenecks ranked by user-visible impact (`Startup` / `Frame Pacing` / `Memory` / `Size`)
2. **Findings Table**: `Severity` | `Location` | `Bottleneck Mechanism` | `Estimated Impact` | `Fix`
3. **Concrete Remediation Plan**: Ordered patch steps and Perfetto / Macrobenchmark verification commands
