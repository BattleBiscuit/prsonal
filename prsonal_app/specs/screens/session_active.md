---
name: SessionActive
type: screen
status: approved
---

## Description
The live workout tracker (route `/session/active`). Shows a thin progress bar, a header with the
routine name / elapsed time / quit & finish actions, a scrollable list of exercise blocks each
containing its set rows, an "Add exercise" affordance, and a fixed bottom action panel that either
completes the current set ("Done"/"Finish") or shows the running rest timer. The bottom navigation
is hidden here. Reached only when a session is active (router guard); leaving requires finishing or
abandoning.

## Layout

```
┌───────────────────────────────────────┐
│ ▰▰▰▰▰▱▱▱▱▱  (progress bar)             │
│ Push Day A      12:31      ✕     ✓     │  header
├───────────────────────────────────────┤
│ BENCH PRESS                        ⓘ   │  exercise block (accent if current)
│  1  10×80kg                  🏆 ▲  ✓   │  completed set
│  2  [ 8 ] × [ 82.5 ] kg  BW       ☐   │  active set (editable)
│  3  8×82.5kg                       ☐   │  upcoming set
│  [ + Add exercise ]                    │
├───────────────────────────────────────┤
│ Target: 8 reps · 82.5 kg              │
│ [           ✓  Done           ]       │  action button (or "Rest 45s")
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec | Usage |
|--------|------|-------|
| SessionProgressBar | `widgets/session_progress_bar.md` | top progress |
| SessionHeader | `widgets/session_header.md` | routine name, elapsed, quit, finish |
| SetRow | `widgets/set_row.md` | one per set, in its state |
| RestActionButton | `widgets/rest_action_button.md` | bottom Done/Finish/Rest control |
| AppModal | `widgets/app_modal.md` | finish, abandon, and notes dialogs |
| ExerciseForm | `widgets/exercise_form.md` (Routines phase) | add exercise to session |

## Screen-local elements

| Element | Type | Label | Behaviour |
|---------|------|-------|-----------|
| exerciseName | Text | Exercise name (uppercase) | Accent when current; ⓘ opens notes modal |
| addExerciseButton | dashed button | "Add exercise" | Opens ExerciseForm to append an exercise |
| finishModal | AppModal | "Finish workout?" | "Save to history" finishes → `history`; "Keep going" closes |
| abandonModal | AppModal | "Abandon workout?" | "Abandon" → `session-pick`; "Continue" closes |

## Navigation
- Entered from: starting a session (session-pick) · resume banner (any screen) · crash-resume on launch
- Navigates to: `history` (finish) · `session-pick` (abandon)
- Back behaviour: Android back is intercepted; offers the abandon modal rather than leaving a live session

## State dependencies
- `sessionEngineProvider` — the live `ActiveSessionState` and all mutations

## Acceptance Criteria
- AC-001: Renders a progress bar reflecting the proportion of completed sets
- AC-002: The header shows the routine name and the elapsed time, with quit and finish actions
- AC-003: The current set is editable and the bottom action button reads "Done"
- AC-004: On the final set the bottom action button reads "Finish"
- AC-005: Completing the current set advances to the next set and starts the rest timer when the set has rest
- AC-006: While resting, the bottom action button shows the remaining rest time and tapping it skips the rest
- AC-007: Tapping the finish action opens a confirm-finish modal; confirming finishes the session and navigates to history
- AC-008: Tapping the quit action opens a confirm-abandon modal; confirming abandons the session and navigates to session-pick
- AC-009: A completed set renders its logged values and a PR indicator when it set a personal record
- AC-010: Tapping "Add exercise" opens the exercise form
