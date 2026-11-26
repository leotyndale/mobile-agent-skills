---
name: mobile-security-review
description: Perform a mobile security review across Android, iOS, and Flutter covering secrets, TLS/pinning, local storage, WebView, deep links, IPC, and auth/payment flows. Use when reviewing sensitive PRs, preparing security audits, or hardening mobile clients.
---

# Mobile Security Review

Targeted client-side security review checklist for Android, iOS, and cross-platform apps handling authentication, payments, PII, or privileged APIs.

## When to Use

- Reviewing PRs touching login/OAuth/session tokens, payments, biometric auth, KYC, or cryptography
- Auditing `WebView`, `DeepLink` / App Links / Universal Links, `AndroidManifest.xml`, or `Info.plist`
- Preparing for penetration testing, Play Store / App Store privacy & security review, or MASVS compliance

## Workflow

1. **Secrets & Credential Storage**:
   - Scan code, `gradle.properties`, `strings.xml`, `.plist`, and `.env` assets for hardcoded API secrets, signing keys, private certificates, or debug backdoors.
   - Verify tokens and sensitive keys reside in **Android Keystore + EncryptedSharedPreferences / Tink** or **iOS Keychain** (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` or stricter), never plaintext `SharedPreferences`, `UserDefaults`, SQLite, or logs.
2. **Network & Transport Security**:
   - Check `network_security_config.xml` (`cleartextTrafficPermitted="false"` in release) and iOS ATS (`NSAllowsArbitraryLoads` must not be `true` globally).
   - Verify custom `TrustManager` / `HostnameVerifier` / `URLSessionDelegate` implementations never blindly accept all certificates (`return true` or empty `checkServerTrusted`)—ensure debug overrides are strictly gated by `BuildConfig.DEBUG` / `#if DEBUG` and stripped from release builds.
3. **Component Exposure & Deep Links (IPC)**:
   - Android: audit every `exported="true"` Activity, Service, BroadcastReceiver, and ContentProvider for intent validation, path traversal (`ContentProvider.openFile`), and permission guards.
   - Validate Deep Link / Universal Link hosts, schemes, and query parameters before navigating or passing URLs into authenticated WebViews or payment actions.
4. **WebView & JS Bridge Hardening**:
   - Flag `setJavaScriptEnabled(true)` combined with `addJavascriptInterface` on untrusted origins, `setAllowFileAccess(true)` / `setAllowUniversalAccessFromFileURLs(true)`, and missing origin allowlists before injecting auth tokens or cookies.
5. **Sensitive Data Leakage & Tamper Hygiene**:
   - Verify `Log.*`, crash reporters, and analytics strip tokens, passwords, PAN/CVV, and PII in release builds.
   - Check `FLAG_SECURE` / screen-capture protection on sensitive screens and `android:allowBackup="false"` (or explicit backup exclusion rules) for credential stores.

## Checklist

- [ ] Zero hardcoded secrets, private keys, or test credentials in source or build configs
- [ ] Auth tokens & keys stored exclusively in Keystore-backed encrypted storage or iOS Keychain
- [ ] Release builds enforce HTTPS/TLS with zero permissive `TrustManager` or `NSAllowsArbitraryLoads`
- [ ] All exported Android components and Deep Link handlers enforce allowlisted hosts/actions and input validation
- [ ] WebViews restrict file access, validate URL schemes (`https://` only), and gate JS bridges by exact origin allowlist
- [ ] No sensitive tokens or PII written to `Logcat`, `OSLog`, crash breadcrumbs, or unencrypted caches

## Output Format

Group findings by severity (`P0 Critical` -> `P3 Low`):

1. **Security Verdict**: `PASS` | `CONDITIONAL_PASS` | `BLOCK_RELEASE`
2. **Findings**: `[Severity] Category — File:Line — Exploit Scenario — Concrete Remediation Patch`
3. **Verification Commands**: Static checks or runtime tests to confirm remediation
