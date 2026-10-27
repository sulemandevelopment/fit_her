# FitHer — Production readiness QA report

**Date:** 28 Oct 2026  
**Scope:** `fit_her_app` (Flutter) + `partner_backend` (Node/Express/MySQL)  
**Acceptance source:** `FitHer_Build_List_FINAL_full.pdf` + [`implementation-plan.md`](implementation-plan.md)  
**Environment:** Developer machine (macOS); no staging/prod deploy performed.

---

## Executive summary

| Area | Verdict |
|------|---------|
| **Automated quality (Flutter)** | **Partial pass** — 0 analyzer errors, ~240 warnings/info; **177/177** unit/widget tests pass after fixes |
| **Automated quality (backend)** | **Partial pass** — **7/7** Node tests in `partner_backend/test/` |
| **Device / E2E** | **Not verified** — no Android/iOS simulators or physical devices connected |
| **PDF feature completeness** | **Not production-ready** — majority of Delivery 1–3 IDs remain Partial/Missing/Blocked/Deferred |
| **Security** | **High residual risk** — auth improved on appointments; no global rate limiting; config/secrets hygiene gaps documented in audits |
| **Performance baseline (1A4)** | **Not measured** — no published cold-start, APK size, or load-test numbers |
| **Overall production readiness** | **No-go for store release** without closing P0 blockers, staging E2E, signing, and credential/config hardening |

---

## 1. Flutter quality

### 1.1 Static analysis

| Metric | Result | Evidence |
|--------|--------|----------|
| `flutter analyze` | Exit **0** | Run 28 Oct 2026 |
| Analyzer **errors** | **0** | `error •` count = 0 |
| Analyzer **warnings** | **~240** | Mostly `unused_import`, `dead_code`, deprecated `withOpacity`, `avoid_print` |
| Introduced issues (recent work) | **Fixed** | `use_build_context_synchronously` in `missed_session_recovery_actions.dart` (mounted guard) |

**Representative warning clusters (not fixed in this pass — pre-existing):**

- `lib/widgets/zoom_meeting_widget.dart` — unused imports, dead code, prints  
- Widespread `withOpacity` deprecation (info) across v2 widgets  
- Legacy `print` in zoom paths and some tests  

### 1.2 Automated tests

| Suite | Result |
|-------|--------|
| `flutter test` (full) | **177 passed**, 0 failed (after fixing `slot_ui_state_test` 20‑min window + `progress_routing_test` harness) |
| Backend `node --test test/*.test.js` | **7 passed** |

**Tests fixed during audit:**

- `test/utils/slot_ui_state_test.dart` — aligned with `_kSoonWindow = 20` minutes in `slot_ui_state.dart`  
- `test/progress_routing_test.dart` — converted from `main()`+`exit()` script to proper `flutter_test` (was breaking the test loader)

**Not run:** integration tests, golden tests, device tests, payment E2E, Zoom live class E2E.

### 1.3 Widget lifecycle / memory (code review sample)

| Finding | Severity | Notes |
|---------|----------|-------|
| GetX controllers with `fenix: true` | Info | Broad use; ensure `onClose` disposes streams where registered |
| Async + `BuildContext` | Low | Ongoing pattern; recent X7 path guarded |
| `HomeController` / god controllers | Medium | Large surface; regression risk without integration tests |

**Not performed:** DevTools memory profiling, leak detector runs.

### 1.4 Navigation, forms, keyboard (spot check vs Phase 2)

| Area | Status |
|------|--------|
| Login inline validation + scroll-to-error | Implemented (Phase 2) |
| Payment slip picker race | Partial fix (1P5) — device E2E still open |
| Design system (`FhTextField`, `FhButton`) | Partial adoption — many legacy screens |
| `adjustResize` (Android) | Set in `AndroidManifest.xml` |

---

## 2. Android and iOS

### 2.1 Devices / simulators

```
flutter devices → macOS desktop, Chrome web only
```

**Untested:** Android emulator, iOS Simulator, physical devices, tablet layouts, TalkBack/VoiceOver, dynamic type extremes.

### 2.2 Manifest / permissions (Android sample)

- Permissions: CAMERA, INTERNET, RECORD_AUDIO, Zoom-related, `usesCleartextTraffic=true` (dev-friendly; review for prod)  
- Facebook SDK meta-data present in manifest  
- Deep links: production host + ngrok dev intent filters  

**iOS:** Not audited in this pass (no Xcode simulator run).

### 2.3 Notifications

- FCM + local notifications wired (`notification_services.dart`)  
- User preference toggles partially server-gated (~6 types); client does not suppress most pushes locally (`notification_system_full_audit.md`)  
- `missedRecovery` tap → Workout tab (X7) implemented  

---

## 3. Backend security

### 3.1 Authentication / authorization

| Item | Status |
|------|--------|
| User routes `validateToken` | Widespread on `/users/*` |
| Appointments create/read/delete | **Auth + ownership** on key routes (Phase 2 P0) |
| Admin routes `validateAdmin` | Used on dietitian appointment lists |
| Pre-consultation PATCH | Whitelist of user-editable fields |
| Food profile API (2NH1) | `validateToken` on GET/POST check |

**Residual (from architecture audit — re-validate on staging):**

- DB credentials in `partner_backend/config/config.json` (env migration incomplete)  
- Dual JWT env vars (`JWT_SECRET` vs `JWT_ACCESS_SECRET`) in different middlewares  
- No **global** `express-rate-limit` on auth/forgot-password (documented in audit only)  
- Trainer/dietitian broad access to full pre-consultation medical intake (by design? confirm)  

### 3.2 Input validation & uploads

- Meal logs: typed enums, 7-day edit window, reason codes  
- Food profile check: server-side `foodProfileFilter`  
- Multipart uploads: MIME mapping in `api_provider.dart` for images  
- AI diet validator: allergy keyword parity with 2NH1 helper  

### 3.3 Subscription enforcement (X4)

**Partial** — plan status on user/home; monthly counters and comprehensive server gates **incomplete** per implementation plan.

### 3.4 Secrets & health data

- `.env` present locally for app + backend (must stay out of git; verify `.gitignore` on each deploy pipeline)  
- Health fields in `PreConsultationProfiles`; user-facing responses strip `dietitianComments`  
- Logging: verbose `debugPrint` of API bodies in `ApiProvider` (remove/redact for prod builds)  

### 3.5 Migrations

- New migrations include daily check-in stress/symptoms (`20261028130000`) — **must be applied on staging/prod before release**  
- Sequelize migrations folder present; no automated migration dry-run executed in this audit  

---

## 4. Performance

| Measurement | Result |
|-------------|--------|
| Cold start time | **Not measured** |
| Release APK/IPA size | **Not built** (no signing config exercised) |
| Memory under navigation | **Not profiled** |
| API p95 / DB query audit | **Not load-tested** |
| Workspace size (`fit_her_app/`) | ~437 MB (includes assets; not store binary) |

**Client mitigations present:**

- HTTP **30s timeout** + normalized failure `Response` in `ApiProvider`  
- Workout plan fetch TTL in `WorkOutController`  
- Image MIME fixes for uploads  

**Baseline (1A4):** Still **Missing** — no comparison to prior benchmark.

---

## 5. Reliability

| Scenario | Evidence |
|----------|----------|
| Offline / timeout | ApiProvider returns 408/503-shaped responses; not all screens handle uniformly |
| Token expiry | JWT refresh flow not fully traced in this pass |
| Duplicate submit | Partial — meal log upsert by key; payment flows not E2E tested |
| Upload failure | Slip upload improved; retry UX varies by screen |

**Notification worker:** Audit notes risk if `notificationWorker.js` not running in prod — **ops verification required**.

---

## 6. Functional testing vs PDF (`implementation-plan.md`)

### 6.1 Recently completed / partial (regression spot-check via unit tests only)

| ID | Status | QA note |
|----|--------|---------|
| 1NH1–1NH5 | Partial | API + quick check-in; migration deploy dependency |
| X7 | Partial | Slot stats + recovery actions; no device E2E |
| 2NH1 | Partial | Food filter + settings; keyword rules not dietitian-signed-off list |
| 1P5 | Partial | Slip UI fixes; device test pending |
| Appointments P0 | Partial | Routes now token-gated |

### 6.2 Deferred AI (must not fake success)

2NH3, 2NH4, 2NH13 AI layer, 1NH8/10 vision extensions, 1P1/1P3, 2P1/2P2, 3NH1, etc. — **unchanged**; no new AI added in audit window.

### 6.3 Pipeline (pending client approval)

3NH2, 3NH5–7, 3H8/9/11, 3M4–8, 3P1–7 — **not implemented** (correct).

### 6.4 Live 14 features

Automated coverage varies; **manual regression on staging not executed** in this audit.

---

## 7. Release preparation

| Item | Status |
|------|--------|
| `BASE_URL` via `.env` / dotenv | Yes — default fallback IP in code if unset |
| Staging vs prod separation | **Weak** — cleartext HTTP fallback; multiple commented base URLs in `constants.dart` |
| Android release build | **Not attempted** |
| iOS release build | **Not attempted** |
| Privacy policy / store disclosures | **Not reviewed** in this pass |
| Publish to prod | **Not performed** (per instructions) |

---

## 8. Passed tests (summary)

- **Flutter:** 177 tests — validators, slot UI state, cycle engine, recommendation service, meal log models, food profile filter, paid home widgets, etc.  
- **Backend:** 7 tests — daily check-in symptoms, food profile filter, slot session stats  

---

## 9. Failed tests (before fixes)

| Test | Root cause | Resolution |
|------|------------|------------|
| `slot_ui_state_test` 16m boundary | Product uses **20**‑minute soon window | Test updated |
| `progress_routing_test` loader | Script used `exit(0)` outside test framework | Rewritten as `flutter_test` |

**After fixes:** full suite green.

---

## 10. Untested scenarios (explicit)

- Android/iOS UI on multiple form factors  
- Live Zoom join/leave, class presence  
- Stripe / DirectPay / slip approval full funnel  
- Push notifications in background/killed state  
- Trial 1P8 subscription flow  
- Progress v2 PDF export end-to-end  
- Community report/block/moderation (1P2/1P4)  
- Load test / concurrent class joins  
- Migration apply + rollback on staging DB  

---

## 11. Security findings (prioritized)

| Priority | Finding |
|----------|---------|
| P0 | Confirm `config.json` credentials not used in prod; rotate if ever committed |
| P0 | Verify all appointment/admin list endpoints require correct role on staging |
| P1 | Add rate limiting on auth/password reset endpoints |
| P1 | Redact API debug logging in release builds |
| P1 | Review `usesCleartextTraffic` for production Android |
| P2 | Consolidate JWT secret env naming |
| P2 | Confirm notification worker process in production |

---

## 12. Remaining bugs (from audits + plan)

- 1P5 slip upload — device E2E pending  
- 1P8 trial — Missing vs PDF  
- Day 7 review / escalation UI unreachable (P0 diet safety)  
- DietPlansOfUser loading/error gaps  
- ClientDetailsScreen hardcoded medical copy (trust)  
- X4 incomplete tier enforcement  

---

## 13. Deferred / blocked features (release scope)

See [`implementation-plan.md`](implementation-plan.md) — **Blocked:** X1, X5, X8, 1NH7, 2M12, 1P6 credentials, 3M1 (X5). **Deferred AI** and **Pipeline** sections unchanged.

---

## 14. Release blockers (recommended)

1. Staging E2E: auth, payment, trial, live class, daily check-in, food profile  
2. Apply pending DB migrations on staging/prod  
3. Close P0 security/config items (secrets, rate limits, logging)  
4. 1P8 + X4 server subscription gates per PDF  
5. 1A4 performance benchmarks documented  
6. Store signing, privacy labels, prod `BASE_URL` / TLS-only  
7. Manual regression of **14 live features** on paid test accounts  

---

## 15. Production-readiness assessment

The codebase shows **solid unit-test coverage for pure logic** (cycle, slots, food filter, validators) and **recent hardening** on appointments, API timeouts, and nutrition/movement partial features. It is **not** production-ready as a complete FitHer Delivery 1–3 product: the PDF checklist has extensive Partial/Missing items, device testing was not performed, performance baselines are absent, and known P0 product/security gaps remain.

**Recommendation:** Treat this build as **internal/staging QA candidate** only. Schedule a focused staging sprint for E2E + ops checks before any store submission.

---

## 16. Changes made during this audit (safe fixes)

- `test/utils/slot_ui_state_test.dart` — 20‑minute window alignment  
- `test/progress_routing_test.dart` — proper test harness  
- `lib/widgets/workout/missed_session_recovery_actions.dart` — `mounted` guard  

---

*Next update: re-run this report after staging E2E and migration deploy, attaching device logs and `flutter analyze` warning delta target (e.g. zero warnings on touched modules).*
