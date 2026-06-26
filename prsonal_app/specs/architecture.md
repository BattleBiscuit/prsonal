---
name: Architecture
type: decision
status: approved
---

## Purpose
This document captures the fundamental technical decisions that govern the entire app.
No feature spec should contradict these choices. Update this doc (and bump status back to
`draft` for review) whenever a structural decision changes.

This app is a **native Flutter port of the `gym-app` project** (a Vue 3 + Capacitor + Dexie
PWA). The goal is an Android app that **looks and behaves identically** to gym-app, but with a
clean, minimal, native codebase. We deliberately do **not** mirror gym-app's technologies — we
use the idiomatic Flutter equivalent for each concern (see *Technology Mapping*). Data flows are
simplified wherever gym-app carried redundant or denormalised state.

---

## Technology Mapping

| Concern | gym-app (source) | prsonal_app (this port) |
|---------|------------------|-------------------------|
| UI framework | Vue 3 SFCs | Flutter / Material 3 |
| State management | Pinia stores | Riverpod providers |
| Routing | vue-router (hash) | go_router |
| Persistence | Dexie / IndexedDB | Drift / SQLite |
| Charts | Chart.js | fl_chart |
| Haptics / notifications / wakelock | Capacitor plugins | Flutter platform plugins |
| Packaging | Capacitor (webview) | native Flutter APK |

We are **not** bound to gym-app's data shapes, store structure, or composable boundaries —
only to its observable look and behaviour.

---

## State Management — Riverpod

**Package:** `flutter_riverpod`

All application state lives in Riverpod providers. No `setState` outside of purely local,
ephemeral UI state (e.g. a text field's focus, a sheet's open/closed flag). Rules:

- Async data backed by Drift → `StreamProvider` / `FutureProvider` (reactive to DB changes)
- Mutable business logic → `NotifierProvider` / `AsyncNotifierProvider`
- Derived/computed state → `Provider`
- Screens are `ConsumerWidget` or `ConsumerStatefulWidget`
- Providers live in `lib/providers/` (app-wide) or are co-located with their feature

**Reactivity principle (simplification over gym-app):** gym-app's Pinia stores held large
imperatively-maintained caches (e.g. `plannedRoutineIds`, `sortedRoutines`, per-set
denormalised fields) that drifted out of sync. Here, **lists and derived values are Drift
queries surfaced as providers**, recomputed by the database, never hand-maintained in memory.

## Navigation — go_router

**Package:** `go_router`

Declarative, URL-based routing in a single `lib/router.dart`. Named routes only.

**Shell + tabs.** The five primary destinations are hosted in a `StatefulShellRoute` so each
tab keeps its own navigation stack and scroll position, with a persistent `AppBottomNav`:

| # | Tab | Route name | Path |
|---|-----|------------|------|
| 1 | Workout | `session-pick` | `/` (home) |
| 2 | Exercises | `library` | `/library` |
| 3 | Body | `body` | `/body` |
| 4 | Progress | `progress` | `/progress` |
| 5 | Settings | `settings` | `/settings` |

**Home is the Workout tab (`session-pick`).** There is **no Dashboard screen** — gym-app does
not have one, and the previously-scaffolded Dashboard (and its `metric_card` / `activity_chart`
widgets) is retired.

Detail/editor routes pushed on top of the relevant tab stack:
`session-active`, `routines`, `routine-create`, `routine-edit`, `plan-create`, `plan-edit`,
`history`, `history-detail`, `all-prs`.

**Active-session guard (`redirect`):** matches gym-app — navigating to `session-active` with no
active session redirects to `session-pick`; navigating to `session-pick` while a session is
active redirects to `session-active`. A "workout in progress" banner (see AppPageShell) lets the
user jump back into a live session from any screen.

## Dependency Injection

Riverpod providers are the DI mechanism. The `AppDatabase`, DAOs, and services are exposed as
providers and injected via `ref.watch` / `ref.read`. No service locator.

## Folder Structure (inside `lib/`)

```
lib/
├── main.dart
├── router.dart            ← go_router configuration (shell + tabs)
├── theme/                 ← ThemeData + AppColors theme extension (see design_system.md)
├── providers/             ← app-wide providers (database, settings, active session)
├── models/                ← value types not owned by Drift (enums, SetTarget, view models)
├── database/              ← Drift AppDatabase, table definitions, DAOs
├── services/              ← business logic (PR/volume/streak/backup), platform integrations
├── screens/               ← one file per screen; ConsumerWidget
└── widgets/               ← reusable UI components
```

## Models

To stay minimal we do **not** hand-write data classes that duplicate the schema. **Drift's
generated row classes are the app's data models.** `lib/models/` holds only:

- enums (`ExerciseType`, `Muscle`, `BodyMetricType`, `SessionStatus`, `SetKind`)
- embedded value objects stored as JSON columns (`SetTarget`)
- pure view models that never persist

Each `specs/models/<name>.md` therefore specifies a **table + its row type**; the matching
test exercises the model's pure logic (enum parsing, JSON (de)serialisation, computed getters).

## Local Persistence — Drift (SQL)

**Package:** `drift` + `drift_flutter` (SQLite backend), `drift_dev` + `build_runner` (codegen)

Type-safe, compile-time-verified SQL via Dart code generation. Rules:

- One `AppDatabase` class in `lib/database/app_database.dart`
- Table definitions as Dart classes extending `Table`; one DAO per aggregate
- Queries written as typed methods on DAOs — no raw SQL strings at call sites
- Services/screens receive the database via Riverpod provider — never instantiate it directly
- Migrations are versioned and tested (we start fresh at schema v1 — gym-app's 14 Dexie
  migrations are collapsed into the final normalised shape)

### Data Model (8 tables)

IDs are TEXT UUIDs. Timestamps are stored as epoch-millis integers (Drift `DateTime`).
All weights are stored in **kilograms**; there is no per-user unit preference (gym-app converted
everything to kg in migration v7).

| Table | Purpose | Key relationships |
|-------|---------|-------------------|
| `exercises` | Exercise library (the catalogue) | ← routineExercises, ← workoutSets |
| `routines` | A named, ordered template of exercises | → routineExercises |
| `routineExercises` | An exercise slot in a routine + its planned `sets` (JSON) | → exercises |
| `plans` | A weekly training plan | → planEntries |
| `planEntries` | A routine assigned to a day-of-week within a plan | → routines |
| `workoutSessions` | A performed (or in-progress) workout | → workoutSets |
| `workoutSets` | One logged set within a session | → exercises (optional) |
| `bodyMetrics` | A logged body measurement | — |

See each `specs/models/*.md` for the field-level definition.

### Simplifications vs gym-app (decided)

1. **`config` table dropped.** Its only surviving key was `bodyweight`; that is now **derived**
   from the latest `weight` `bodyMetric` (default `80` kg when none logged). `violentMode` is
   removed (feature dropped). The "bodyweight" used to resolve bodyweight-relative sets reads
   this derived value.
2. **No stored `totalVolumeKg`.** Session volume is computed on demand by a Drift aggregate
   (`SUM(actualReps * effectiveWeight)` over completed, non-skipped, strength sets). gym-app
   stored it *and* recomputed it with a divergent formula — a documented bug source.
3. **`workoutSets.startedAt` dropped.** gym-app denormalised the session start onto every set to
   avoid a join; we join on `sessionId` instead.
4. **`workoutSets.muscleGroups` dropped.** Muscle analytics join `exercises` via `exerciseId`
   at query time. gym-app's per-set snapshot was incomplete (primary only) and used
   inconsistently.
5. **`planEntries.routineName` dropped.** Derived by joining `routines` on `routineId`.
6. **`routineExercises.name` dropped.** Derived from the linked `exercise`. (gym-app kept a
   snapshot and cascaded renames; deriving makes renames automatic and removes the cascade.)
   Every routine exercise therefore **requires** an `exerciseId` (free-text exercises are
   created in the library first, exactly as gym-app's "Create 'xyz'" flow already did).
7. **Snapshots that are intentionally kept:** `workoutSessions.routineName` and
   `workoutSets.exerciseName` are frozen at session start. Sessions are immutable historical
   records; their labels must survive deletion/rename of the source routine/exercise.

### Personal Record (PR) detection — unified (decided)

gym-app detected PRs by peak `effectiveWeight` but ranked the PR *list* by Epley estimated 1RM —
the two could disagree. We **unify on Epley 1RM everywhere**:

```
estimated1RM = actualReps == 1 ? effectiveWeight
                               : effectiveWeight * (1 + actualReps / 30)
effectiveWeight = isBodyweight ? bodyweight + actualWeight : actualWeight   (cardio: null)
```

`workoutSets.estimated1RM` is **stored** at set completion. A set `isPR` when its
`estimated1RM` exceeds every prior completed, non-skipped, strength set of the same exercise
(by `exerciseId`, falling back to `exerciseName`). PR detection and the PR list both read this
single stored value — no recomputation, no divergence.

## Services / Business Logic

Pure, testable logic lives in `lib/services/` (specced under `specs/services/`):

- **Weight formatting & resolution** — `formatWeight`, `resolveEffectiveWeight`, Epley 1RM.
- **Session engine** — start/resume/advance/complete/abandon a workout, PR detection, write
  actuals back to the routine as new planned targets ("progressive-overload memory").
- **Progress analytics** — weekly volume, volume trend, muscle frequency (radar), best lifts,
  plan adherence, streaks. All implemented as Drift queries + Dart aggregation in **one pass**
  (gym-app issued up to 52 queries/plan for streaks — collapsed to a single windowed query).
- **Backup / restore** — JSON export/import of all tables (the one optional feature kept).

Services throw typed exceptions (defined alongside them). Screens surface errors via
`AsyncValue.when(error: ...)`. No bare `catch (e)`.

## Platform Integrations

Thin wrapper service (`lib/services/platform_service.dart`) with graceful no-op fallbacks:

- **Haptics** — `HapticFeedback` (light tap on set complete, heavy/double on PR, success on
  finish).
- **Local notifications** — `flutter_local_notifications`: a "rest complete" notification fires
  if the rest timer elapses while backgrounded; cancelled on skip/early finish.
- **Wakelock** — `wakelock_plus`: screen stays awake during an active session.

## Charts — fl_chart

**Package:** `fl_chart`

- **RadarChart** — muscle balance (7 fixed axes: Chest, Shoulders, Arms, Back, Core, Legs,
  Glutes). Accent fill at 12% opacity, accent stroke.
- **BarChart** — per-workout volume. Accent bars at 50% fill, rounded tops.
- A swipeable `ChartSlider` widget hosts the two charts with pagination dots.

## Removed from scope (decided)

These gym-app features are **not** ported:

- **Flex mode** — Samsung foldable tabletop split-screen layout.
- **Violent mode** — insult toasts on under-target sets (and its `config` flag).
- **GitHub update check** — APK self-update polling (irrelevant to a native build).
- **Recovery screen** — raw-IndexedDB diagnostic/export tool (Drift makes it unnecessary;
  backup/restore covers data portability).

## Remote API

**None.** The app is fully local-first (offline). No remote backend.

## Testing Strategy

| Layer | Tool | Location |
|-------|------|----------|
| Models / pure logic | `flutter_test` | `test/models/` |
| Services | `flutter_test` + `mocktail` | `test/services/` |
| Screens (widget) | `flutter_test` + `mocktail` | `test/screens/` |
| Reusable widgets | `flutter_test` | `test/widgets/` |
| End-to-end flows | `integration_test` | `integration_test/` |

DB-touching tests use Drift's in-memory `NativeDatabase.memory()` — no mocking of SQL.

---

## Packages to add

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.3
  drift: ^2.22.1
  drift_flutter: ^0.2.4
  fl_chart: ^0.69.2
  flutter_local_notifications: ^18.0.1
  wakelock_plus: ^1.2.8
  uuid: ^4.5.1
  intl: ^0.19.0

dev_dependencies:
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
  build_runner: ^2.4.13
  drift_dev: ^2.22.1
```
