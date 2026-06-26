---
name: PlatformService
type: service
status: approved
---

## Description
A thin abstraction over the device integrations used during a workout: haptic feedback, the
rest-complete local notification, and the screen wakelock. It exists as an interface so the
session engine can be tested without real platform channels.

- `RealPlatformService` wraps `HapticFeedback`, `flutter_local_notifications`, and `wakelock_plus`.
- `FakePlatformService` records every call for assertions in tests.
- Injected via `platformServiceProvider`; the session engine reads it through `ref`.

Notification IDs and copy match gym-app: a single rest notification ("Rest complete — time to hit
the next set 💪") that is rescheduled/cancelled rather than stacked.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| hapticTap | — | `Future<void>` | light impact (set completed) |
| hapticPR | — | `Future<void>` | heavy/double impact (personal record) |
| hapticSuccess | — | `Future<void>` | success pattern (session finished) |
| scheduleRestComplete | `Duration after` | `Future<void>` | schedules the single rest notification |
| cancelRestComplete | — | `Future<void>` | cancels the pending rest notification |
| enableSessionWakelock | — | `Future<void>` | keeps the screen awake |
| disableSessionWakelock | — | `Future<void>` | releases the wakelock |

## Error Cases
- All methods are best-effort and must never throw to the caller; the real implementation swallows
  platform errors (logging them), so the workout flow is never interrupted by a missing capability.

## Acceptance Criteria
- AC-001: FakePlatformService records hapticTap, hapticPR and hapticSuccess calls
- AC-002: scheduleRestComplete records the requested duration and cancelRestComplete clears the pending rest notification
- AC-003: enableSessionWakelock and disableSessionWakelock toggle a recorded wakelock flag
