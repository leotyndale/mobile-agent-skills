---
name: mobile-release-readiness
description: Run a pre-release readiness audit for Android (Play Store / AAB) and iOS (App Store / IPA) releases covering versioning, signing, R8/dSYM mapping, privacy manifests, permissions, and staged rollout gates. Use before cutting a release branch or submitting to app stores.
---

# Mobile Release Readiness

Pre-flight release engineering checklist to prevent store rejections, un-symbolicated crashes, broken upgrades, and hotfix emergencies.

## When to Use

- Cutting a release branch (`release/*`) or bumping `versionCode` / `CFBundleVersion`
- Preparing Google Play AAB or Apple App Store Connect IPA submission
- Auditing SDK/dependency updates, `PrivacyInfo.xcprivacy`, Data Safety declarations, or ProGuard/R8 rules before shipping

## Workflow

1. **Build Configuration & Versioning**:
   - Verify `versionCode` / `CFBundleVersion` monotonically increases, `versionName` / `CFBundleShortVersionString` follows release tag, and `debuggable = false` / `Release` build configuration is enforced.
   - Confirm release signing configs do not reference plaintext passwords or debug keystores in VCS.
2. **Obfuscation, Keep Rules & Crash Symbolication**:
   - Android: verify `isMinifyEnabled = true`, `isShrinkResources = true`, Retrofit/Gson/Moshi/Protobuf/JNI `@Keep` rules for newly added models, and `mapping.txt` + native debug symbols upload to Crashlytics/Sentry/Play Console.
   - iOS: verify `DEBUG_INFORMATION_FORMAT = dwarf-with-dsym` and automated dSYM upload for all app extensions and frameworks.
3. **Store Policy & Privacy Compliance**:
   - Android: verify `targetSdk` compliance, foreground service types (`foregroundServiceType`), photo-picker vs broad storage permissions, and Play Data Safety accuracy.
   - iOS: verify `PrivacyInfo.xcprivacy` required-reason APIs (`UserDefaults`, file timestamps, disk space, system boot time) across app and third-party SDKs, plus `NS*UsageDescription` strings.
4. **Upgrade Path & Kill-Switch Readiness**:
   - Smoke-test in-place upgrade from the previous production version (`N-1` -> `N`) covering DB migrations and cached auth tokens.
   - Confirm remote feature flags / kill-switches wrap risky new subsystems and crash/ANR alert thresholds are active for staged rollout (`1% -> 5% -> 20% -> 100%`).

## Checklist

- [ ] Release build tested with R8/ProGuard enabled (not just debug build!)—zero `ClassNotFoundException` or Gson/Moshi reflection failures
- [ ] `mapping.txt` / native `.so` symbols / `.dSYM` archive pipeline verified for the release build
- [ ] Upgrade test passed from previous production version (auth session + local DB intact)
- [ ] `AndroidManifest.xml` / `Info.plist` / `PrivacyInfo.xcprivacy` contain zero unapproved permissions or missing usage descriptions
- [ ] Hardcoded staging endpoints, mock flags, and verbose debug logging disabled in Release
- [ ] Staged rollout plan (`1% -> 5% -> 20% -> 100%`) and rollback owner confirmed

## Output Format

1. **Release Go / No-Go Verdict**: `GO` | `HOLD_FOR_FIXES`
2. **Gate Table**: `Gate` (`Build/R8`, `Symbols`, `Upgrade`, `Store Policy`, `Flags/Monitoring`) | `Status` | `Evidence / Gap`
3. **Action Items Before Submission**: Exact blockers to resolve prior to uploading AAB/IPA
