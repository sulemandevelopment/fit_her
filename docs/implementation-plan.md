# FitHer — Approved implementation plan & feature checklist

**Source:** `FitHer_Build_List_FINAL_full.pdf` (38 pages)  
**Approved:** October 2026  
**Repos:** `fit_her_app` (Flutter) + `partner_backend` (Node/Express/MySQL)

## Scope decisions (approved)

| Decision | Choice |
|----------|--------|
| Delivery 1 foundations (X1–X8) | **Included in Delivery 1** — client confirms content/timeline separately |
| Free trial (1P8) | **PDF 1P8** — subscription free trial on plan page (day counter, reminder, one-tap continue); unify/deprecate duplicate TrialJourney vs legacy trial APIs |
| New AI integrations | **Deferred** — preserve existing Gemini diet plan, Luna batch, Spoonacular flows; no fake AI results |
| Pipeline features (PDF) | **Pending Client Approval** — do not build until confirmed in writing |

## Status legend

| Status | Meaning |
|--------|---------|
| **Complete** | Meets PDF “Done when” on test accounts |
| **Partial** | Exists but gaps vs PDF or internal audits |
| **Missing** | Not implemented |
| **Blocked** | Needs credentials, content, or external approval |
| **Deferred AI** | No new/extended AI; keep existing behavior |
| **Pending Client Approval** | PDF “Pipeline” or explicit client sign-off |

---

## 14 live features (preserve — regression required)

| ID / name | Status | Notes |
|-----------|--------|-------|
| Cycle & period prediction (date only) | Complete | 2NH14 “what to expect” is a short estimate on the cycle card |
| Mood logging | Partial | Not unified daily log (1NH1/1NH2) |
| General hormonal wellbeing logic layer | Partial | `insight_service`, cycle engine |
| AI diet plan (on request) | Complete | Do not break; 2NH3 auto-adjust = Deferred AI |
| Unlimited live sessions (9 daily slots) | Complete | |
| Generic missed session reminder | Partial | No actions until X7, 2M5 |
| Basic progress tracking | Partial | Progress v2 behind beta toggle |
| Onboarding preference quiz | Complete | |
| Thumbs up/down after sessions | Complete | |
| Community access & feed | Complete | |
| Ad-free experience (Plus) | Partial | Verify X4 tier enforcement |
| Free trial / first week | Partial | Plan-page 7-day trial (1P8). 3-day class trial still separate. |
| Savings on 3 & 6 month plans | Complete | Verify display in **1P7** |
| International USD pricing | Complete | |

---

## Delivery 1 — Check & optimize (1A1–1A7)

PDF status: **To check** (audits + fixes, not net-new features).

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 1A1 | Dashboard & event tracking | Partial | Mixpanel + partial admin metrics; no unified founder dashboard / event schema |
| 1A2 | Payment flow & journey audit | Partial | DirectPay/slip/Stripe exist; slip broken; journey not instrumented |
| 1A3 | User flow audit & fixes | Partial | Audits in `lib/docs/`; no per-screen funnel |
| 1A4 | Performance & capacity check | Partial | Sentry on; no documented benchmarks |
| 1A5 | Upsell options audit | Partial | Paywalls scattered; feature flags incomplete |
| 1A6 | Engagement options audit | Partial | Notification scheduler exists; caps/segments incomplete |
| 1A7 | User journey optimization | Missing | Depends on 1A1 metrics |

---

## Delivery 1 — Foundations (X1–X8)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| X1 | Exercise list with tags | Partial | Admin and user APIs, tag filter, injury hide, mark done, starter written moves. Animation clips and a trainer-signed catalog are still missing (X8). |
| X2 | Live class tags | Partial | Intensity exists; full tag set incomplete |
| X3 | Workout player with mark done | Missing | |
| X4 | Tier counters & checks | Partial | Plan status; monthly counters/freeze incomplete |
| X5 | Video hosting & upload tools | Missing | ~570MB bundle; admin upload tooling |
| X7 | Missed session sheet + actions | Partial | F-02 real duration/calories; Join next / Find similar; `missedRecovery` tap → Workout tab; **2M5** recovery workout still Blocked (needs **1M3**) |
| X8 | Animated exercise clips | Blocked | Content quote; needs X5 |

*(X6 not used in build list.)*

---

## Delivery 1 — Nutrition & hormones (1NH1–1NH15)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 1NH1 | Symptom logging, basic (daily) | Partial | `symptomsJson` + quick check-in UI; dedicated history TBD |
| 1NH2 | Quick daily check-in | Partial | `QuickDailyCheckinScreen`; server `quickCheckinComplete` |
| 1NH3 | Energy logging | Partial | 1–5 scale in quick check-in |
| 1NH4 | Stress logging | Partial | 1–5 + cause chips when high |
| 1NH5 | Sleep logging | Partial | Hours + rested quality in quick check-in; home tiles still separate |
| 1NH6 | Water intake logging | Partial | PDF To confirm |
| 1NH7 | Pakistani food database | Missing | Dietitian-reviewed content |
| 1NH8 | AI meal photo logging, capped (Free) | Partial + Deferred AI | Keep name/Spoonacular flow; monthly cap UI + tier gate; no fake vision |
| 1NH9 | Edit and correct logged meal | Partial | `v2_edit_meal_sheet` |
| 1NH10 | Unlimited AI meal photo (Plus) | Partial + Deferred AI | Plan-based cap only after 1NH8 |
| 1NH11 | Behavior based signal capture | Partial | Mixpanel only |
| 1NH12 | Luna daily body advisor | Partial | Preserve Gemini batch; extend via rules/templates, not live AI |
| 1NH13 | Phase based nudge notifications | Partial | |
| 1NH14 | Daily phase message (Free) | Partial | Locked Luna on unpaid home |
| 1NH15 | Smart log reminders | Partial | Local 8 PM daily check-in reminder. Off during quiet hours and after today’s log. Toggle `dailyLog`. Learned usual-time still missing. Migration `20261028160000`. |

---

## Delivery 1 — Movement (1M1–1M6)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 1M1 | Injury and limitation filter | Partial | Workout schedule hides high-impact classes when the saved injury note mentions knee, ankle, hip, or shoulder. Does not hide the whole day. |
| 1M2 | Phase adaptive workout intensity | Partial | Low energy (1–2) lists gentler classes first. Phase badges were already on the schedule. |
| 1M3 | Animated guided workouts | Missing | Needs X1, X3, X5, X8 |
| 1M4 | Voice and written form cues | Missing | With 1M3 |
| 1M5 | Post workout feedback | Missing | |
| 1M6 | Basic streaks and milestone badges | Partial | Attendance streak; badges Missing |

---

## Delivery 1 — Platform & growth (1P1–1P15)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 1P1 | AI first pass community moderation | Partial + Deferred AI | Human-only today; ship queue + 1P2 first |
| 1P2 | Approved content library & review queue | Missing | |
| 1P3 | AI sales and support assistant | Missing + Deferred AI | Stub `SupportAssistantPort` only |
| 1P4 | Report, block and anonymous posting | Partial | Verify posts module |
| 1P5 | Payment slip upload fix & clear states | Partial | **Priority** — known broken picker |
| 1P6 | Faster plan activation (instant payment) | Partial + Blocked | Merchant credentials |
| 1P7 | Clearer plan page and paywall | Partial | |
| 1P8 | Free trial and first week flow | Partial | Plan-page 7-day trial: day counter, last-day reminder, Continue opens checkout. Does not grant a paid plan or replace the 3-day class trial. Migration `20261028170000`. |
| 1P9 | Upgrade moments | Partial | |
| 1P10 | Home screen with one daily focus | Partial | |
| 1P11 | Fix wrong and broken screen details | Partial | |
| 1P12 | Personal first week | Partial | |
| 1P13 | Renewals, freeze and win back | Partial | |
| 1P14 | Trust basics (privacy, hidden admin login) | Partial | |
| 1P15 | Smaller, faster app | Partial | Tied to X5 video strategy |

---

## Delivery 2 — Nutrition & hormones (2NH1–2NH14)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 2NH1 | Food preferences and allergies filter | Partial | Verified Oct 2026: backend 3 + Flutter 2 tests pass. Keyword list not dietitian-signed. |
| 2NH5 | Appetite and cravings logging | Partial | `appetiteLevel` + whitelist `cravingType` on daily check-in; quick check-in UI. Migration `20261028140000`. Deploy migration before release. |
| 2NH2 | Phase aware food scoring on meals | Partial | Keyword rules + `POST /users/food-profile/phase-score`; meal card note. Not a dietitian-reviewed food list. |
| 2NH3 | Automatic weekly diet plan adjustment | Deferred AI | |
| 2NH4 | AI grocery list with phase swaps | Deferred AI | |
| 2NH6 | Digestion logging | Partial | Optional 1–5 on quick check-in; `digestionLevel` |
| 2NH7 | Medications and supplements logging | Partial | Optional daily `supplementLog` (not a clinical meds module) |
| 2NH8 | Period flow and spotting logging | Partial | Optional `periodFlow` chips including spotting |
| 2NH9 | Skin and hair logging | Partial | Optional `skinStatus` / `hairStatus`. Migration `20261028150000` |
| 2NH10 | Weekly symptom pattern report | Partial | `GET /users/progress/weekly-pattern` + progress card. Needs 3 logged days. Beta progress hub still gates who sees it. |
| 2NH11 | Weekly progress summary | Partial | Rules lines on the weekly card (`summaryLines`): check-ins, mood, energy, stress, meals. Not a full PDF. |
| 2NH12 | Doctor ready PDF export | Partial | Sections incomplete |
| 2NH13 | Monthly nutrition and body report | Partial | `GET /users/progress/monthly-report` + progress card. Needs 8 logged days. Charts for mood, energy, stress, digestion, appetite. AI write-up still Deferred. |
| 2NH14 | Period predictor: what to expect | Partial | Estimate copy on the cycle card from phase + days until period. Not a clinical forecast. |

---

## Delivery 2 — Movement (2M1–2M12)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 2M1 | Time and energy picker | Missing | Needs 1M3 |
| 2M2 | Swap this exercise | Missing | |
| 2M3 | Auto progression | Missing | |
| 2M4 | Rest day suggestion | Missing | |
| 2M5 | Missed session recovery workout | Missing | Needs X7, 1M3 |
| 2M6 | Today’s plan card | Missing | |
| 2M7 | Enhanced streaks | Missing | |
| 2M8 | Fuel tips around workouts | Missing | |
| 2M9 | Women specific basic sets | Missing | Content + clinical review |
| 2M10 | Progress photo timeline | Partial | Admin-only storage today |
| 2M11 | Milestone sharing | Partial | Needs 1M6 badges |
| 2M12 | Cast to TV | Missing + Blocked | Confirm live class stack |

---

## Delivery 2 — Platform (2P1–2P7)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 2P1 | AI content poster | Deferred AI | |
| 2P2 | AI community manager | Deferred AI | |
| 2P3 | *(Founder dashboard — moved to 1A1)* | — | |
| 2P4 | AI cost monitor | Partial | Non-AI cost dashboard OK; needs 1A1 events |
| 2P5 | Remote controls (feature flags) | Missing | |
| 2P6 | Referral program | Missing | |
| 2P7 | Community streak visibility | Missing | |

---

## Delivery 3 — Nutrition (3NH1–3NH7)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 3NH1 | AI nutritionist | Deferred AI | |
| 3NH2 | Ramadan mode | Pending Client Approval | Pipeline |
| 3NH3 | Daily note | Missing | |
| 3NH4 | Tone and style personalization | Partial + Deferred AI | Template variants OK; AI copy Deferred |
| 3NH5 | Cycle calendar with plan ahead | Pending Client Approval | Pipeline |
| 3NH6 | Gentle red flag guidance | Pending Client Approval | Pipeline |
| 3NH7 | Lab report upload | Pending Client Approval | Pipeline |

---

## Delivery 3 — Condition modules (3H1–3H11)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 3H1 | Condition modules framework | Partial | Condition as text to AI diet only today |
| 3H2 | PCOS module | Partial | Screening + diet link; full module incomplete |
| 3H3 | Postpartum module | Partial | Signup + class locks; recovery module incomplete |
| 3H4 | Thyroid module | Partial | Screening; meds/labs incomplete |
| 3H5 | Endometriosis module | Partial | Screening only |
| 3H8 | PMS and PMDD module | Pending Client Approval | Pipeline |
| 3H9 | Perimenopause module | Pending Client Approval | Pipeline |
| 3H11 | Trying to conceive module | Pending Client Approval | Pipeline |

---

## Delivery 3 — Movement (3M1–3M8)

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| 3M1 | Recorded class library | Missing | Needs X5 |
| 3M2 | Trainer style filter | Missing | Can start after X2 |
| 3M3 | Full recorded library (Unlimited) | Missing | Needs 3M1, X4 |
| 3M4 | Micro sessions | Pending Client Approval | Pipeline |
| 3M5 | Live class replays in library | Pending Client Approval | Pipeline |
| 3M6 | Four week programs | Pending Client Approval | Pipeline |
| 3M7 | Low data and download mode | Pending Client Approval | Pipeline |
| 3M8 | Favourites and continue watching | Pending Client Approval | Pipeline |

---

## Delivery 3 — Platform (3P1–3P7)

All **Pending Client Approval** (Pipeline):

| ID | Feature |
|----|---------|
| 3P1 | Privacy lock and discreet mode |
| 3P2 | Urdu and Roman Urdu |
| 3P3 | Health Connect sync |
| 3P4 | Gift a subscription / mother and daughter plan |
| 3P5 | Group plans (companies, workplaces, universities) |
| 3P6 | Points for streaks |
| 3P7 | Free website tools |

---

## Pipeline & deferred summary (do not implement until approved)

**Pending Client Approval:** 3NH2, 3NH5, 3NH6, 3NH7, 3H8, 3H9, 3H11, 3M4–3M8, 3P1–3P7.

**Deferred AI (preserve existing only):** 1NH8/10 extensions, 1NH12 live expansion, 1P1 scanner, 1P3, 2NH3, 2NH4, 2NH13 AI layer, 2P1, 2P2, 3NH1, 3NH4 AI variants.

---

## Phased execution

### Phase 1 — Audit & architecture

- Feature checklist (this document), blockers logged, no production data changes.

### Phase 2 — Stability + premium foundation (first coding milestone)

1. **1P5** payment slip fix  
2. Security P0: appointment auth, admin RBAC, secret hygiene  
3. Design system v1 + auth/plans/payment/profile  
4. Form validation framework (inline errors, scroll-to-first-error)  
5. **1P8** subscription free trial (unify backend trial model)  
6. Diet safety: Day7 review + escalation wiring  
7. **1A1** minimum event set + founder dashboard section  
8. **X7** missed session sheet + F-02 session data  
9. Progress beta: exit criteria or remote flag (2P5 stub)

### Phase 3 — Delivery 1 module completion (non-AI)

Order: 1NH1→1NH6, 1NH7 → 1NH15 → 1M1/1M2 → X1/X2/X5 → X3/X8/1M3/1M4 → 1P2/1P4 → 1P7/1P9–1P13 → X4.

### Phase 4 — Delivery 2 + approved Delivery 3 (non-AI)

2NH10–12, 14; 2M*; 3M1–3M3; 3H1 + 3H2–3H5 (doctor-reviewed rule configs).

### Phase 5 — Optimization & release

1A4 benchmarks, security review, device matrix, store readiness.

---

## Critical blockers

| Blocker | Affects |
|---------|---------|
| Payment merchant credentials | 1P6 |
| Trainer exercise list + animation quote | X1, X8, 1M3 |
| Video CDN/host + admin SOP | X5, 3M1 |
| Doctor/dietitian copy sign-off | 1P2, 2NH12, 3H* |
| Peak load number for load test | 1A4 |
| Live class vendor (Cast/TV) | 2M12 |
| AI moderation publish-first vs hold-flagged | 1P1 |

---

## Phase 2 sprint 1 scope (~2–3 weeks)

1. 1P5 payment slip  
2. P0 backend auth (appointments + admin)  
3. Form validation framework  
4. AppTheme on plans/payment/onboarding  
5. 1P8 trial backend + UI  
6. Day7 escalation visibility  
7. X7 missed session sheet  
8. Tests: slip, trial, validators, live-feature smoke  

**Out of sprint 1:** X8 animations, 3NH1, Pipeline items, new AI moderation.

---

## Success metrics

- Payment: slip success, time-to-active, zero duplicate charges on test matrix  
- Trial: funnel events through 1A1  
- Quality: `flutter analyze` clean; Sentry crash-free sessions  
- Checklist rows move to **Complete** only after PDF “Done when” on staging  

---

## Phase 2 progress log

| Date | Group | Done | Notes |
|------|-------|------|-------|
| Oct 2026 | Design system foundation | Yes | Tokens (`app_shadows`, `app_motion`, brand colors), `lib/widgets/design_system/*`, `core/forms/*`, theme input/button defaults |
| Oct 2026 | Auth — login | Yes | Inline validation, scroll-to-error, `FhTextField`; no field toasts |
| Oct 2026 | Payments — slip upload (1P5) | Partial | Inline slip error, picker race fix, loading state, `FhDialog` success; E2E device test pending |
| Oct 2026 | Backend — appointments P0 | Partial | Auth on create/read/delete/list; ownership checks on create/getById/dietitian list |
| Oct 2026 | **1NH1–1NH2 + 1NH3–5** daily log | Partial | Migration `20261028130000`, stress/symptoms API, `QuickDailyCheckinScreen`, home banner; 48h edit = today-only server rule |
| Oct 2026 | **X7** missed session sheet | Partial | `slot_session_stats`, `MissedSessionRecoveryActions`, dashboard calorie estimate; tests: backend 2 pass, Flutter 4 pass |
| Oct 2026 | **2NH1** food prefs & allergies | Partial | Verified: foodProfileFilter tests 3+2 pass |
| Oct 2026 | **2NH5** appetite & cravings | Partial | Migration + server whitelist; quick check-in fields; `appetiteCraving.test.js` |
| Oct 2026 | **2NH6–2NH9** body log | Partial | Digestion, supplements, period flow, skin, hair on quick check-in. Migration `20261028150000` |
| Oct 2026 | **2NH2** phase food score | Partial | Keyword rules; API + meal card. Tests 2+2 pass |
| Oct 2026 | **2NH10** weekly symptom pattern | Partial | Rules summary of last 7 check-ins; `weeklySymptomPattern.test.js` |
| Oct 2026 | **2NH11** weekly progress summary | Partial | `summaryLines` on the same weekly card; meal count included |
| Oct 2026 | **2NH14** period what to expect | Partial | Cycle card estimate copy; tests on client and server |
| Oct 2026 | **2NH13** monthly body report | Partial | Rules and charts from 30 days of check-ins and meal logs. No AI summary. |
| Oct 2026 | **1NH15** daily log reminder | Partial | 8 PM local reminder; quiet hours and already-logged skip. Not a learned time. |
| Oct 2026 | Onboarding / plans shell | No | Next screen group |
| Oct 2026 | **1P8** plan-page trial | Partial | 7-day record, day counter, reminder cron, Continue opens checkout |
| Oct 2026 | Day7 escalation UI | Partial | Flagged check-in stays on a dietitian note instead of a toast |
| Oct 2026 | Signup and payment forms | Partial | Inline errors on signup and the Direct Pay phone field |
| Oct 2026 | **1M1 / 1M2** class filter | Partial | Injury hide + low-energy order on the workout schedule |
| Oct 2026 | **X1** exercise library | Partial | Tagged exercises, injury filter, mark done. No animation files. |

**Tests:** `test/core/fh_validators_test.dart` — 5 passed; `partner_backend/test/dailyCheckinSymptoms.test.js` — 2 passed. Analyzer clean on touched files (warnings/info only).

**Deploy note:** Run migrations `20261028130000`, `20261028140000`, `20261028150000`, `20261028160000`, and `20261028170000` on staging/production before release.

---

## Production readiness QA (Oct 2026)

Full report: [`docs/production-readiness-qa-report.md`](production-readiness-qa-report.md)

| Check | Result |
|-------|--------|
| `flutter analyze` errors | **0** (~240 warnings/info pre-existing) |
| `flutter test` | **177/177 pass** (after slot + progress routing test fixes) |
| Backend `node --test test/*.test.js` | **7/7 pass** |
| Android/iOS device E2E | **Not run** (no simulators connected) |
| PDF checklist complete | **No** — see plan tables |
| **Release recommendation** | **No-go** until P0 blockers + staging E2E |

---

## Related docs

- `docs/production-readiness-qa-report.md`
- `docs/architecture-audit.md`
- `lib/docs/diet_system_full_audit.md`  
- `lib/docs/free_trial_system_audit.md`  
- `docs/three-day-trial-assessment.md`  
- Primary requirements: `FitHer_Build_List_FINAL_full.pdf`
