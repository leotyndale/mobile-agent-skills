---
name: mobile-ddd-modularization
description: Architect and refactor large mobile codebases using Domain-Driven Design (DDD), bounded contexts, dependency inversion, and Gradle/SPM/Melos module boundaries. Use when untangling monolithic mobile apps, designing multi-module workspaces, or enforcing module dependency rules.
---

# Mobile DDD Modularization

Practical guide to decomposing monolithic Android, iOS, KMP, and Flutter apps into build-fast, independently testable bounded-context modules.

## When to Use

- Breaking up a bloated `app/` or `common/` God-module that slows incremental builds and causes merge conflicts
- Designing module boundaries (`:api` vs `:impl`, `:domain` vs `:data` vs `:feature`) for a multi-team mobile app
- Resolving circular dependencies between features (e.g., `feature-checkout` importing `feature-cart` internals)
- Setting up Kotlin Multiplatform (KMP) or shared domain boundaries across Android and iOS

## Workflow

1. **Map Bounded Contexts & Dependency Graph**:
   - Inventory existing modules/packages and identify cyclic edges, feature-to-feature concrete imports, and leaked database/DTO models in UI layers.
   - Classify modules into strict tiers:
     - `:core:model` / `:core:common` (pure language/coroutines, zero UI/platform dependencies)
     - `:core:network`, `:core:database`, `:core:designsystem`
     - `:feature:<name>:api` (public contracts: navigation routes, exposed use-cases/interfaces, domain events)
     - `:feature:<name>:impl` (internal UI, ViewModels, repositories; depends only on `:api` contracts of other features, never `:impl`)
2. **Domain-Driven Design Boundaries**:
   - Separate **Entities / Value Objects** (invariants enforced in pure domain layer) from **Network DTOs** (`@Serializable` / `Codable`) and **DB Entities** (`@Entity`).
   - Place explicit **Anti-Corruption Layer (ACL) mappers** at data boundaries so backend schema churn does not ripple into UI or domain logic.
3. **API/Impl Split & DI Wiring**:
   - Enforce that feature A depends ONLY on `:feature:B:api` (compile-time isolation), while `:app` (the composition root) binds `:feature:B:impl` via Hilt/Anvil, Koin, Swinject, or Swift `Factory`.
   - For Android Gradle builds, apply `implementation(...)` instead of `api(...)` by default to prevent transitive ABI leakage and preserve incremental compilation.
4. **Cross-Feature Communication**:
   - Replace direct screen/service references with **Router/DeepLink URI contracts** or typed **Domain Event Buses** defined in `:core` / `:api`.
5. **Architectural Fitness Functions**:
   - Add automated checks (`Konsist` / `ArchUnit` for JVM/Kotlin, Gradle Dependency Analysis plugin, or SwiftLint/SPM target isolation) so prohibited imports fail CI immediately.

## Checklist

- [ ] Zero feature `:impl` -> feature `:impl` dependencies (strictly `:impl` -> other `:api` only)
- [ ] Domain layer has zero Android SDK (`android.*`), `UIKit`, `SwiftUI`, or `Flutter` imports
- [ ] Network DTOs and Room/CoreData/SwiftData entities are mapped via explicit ACL mappers before entering domain/UI
- [ ] Gradle uses `implementation` instead of `api` unless the module explicitly re-exports public contract types
- [ ] Build graph verified acyclic (`./gradlew :app:dependencies` / `swift package show-dependencies`)
- [ ] Module ownership (`CODEOWNERS`) and CI fitness rule prevent boundary regression

## Output Format

1. **Module Topology Diagram**: ASCII or Mermaid dependency graph (`app` -> `feature:api` / `core`)
2. **Boundary Violations Found**: Concrete cross-module coupling or leaked models with file paths
3. **Refactoring Plan**: Step-by-step extraction sequence (`Extract :api` -> `Invert DI` -> `Move impl` -> `Enforce CI rule`)
