---
name: AppPageShell
type: widget
status: approved
---

## Description
The standard page chrome wrapping every root screen, ported from gym-app's `AppPageShell`. It
renders the fixed top header (the PRsonal brand wordmark plus optional page-specific content), the
conditional "workout in progress" banner, and a scrollable body. It does **not** include the
bottom navigation — that is the shell route's responsibility (see architecture.md).

The host screen decides whether the workout banner shows: it is shown on any screen **except the
active-session screen itself**, while a session is live. The host passes `showWorkoutBanner` and
the live routine name (both derived from the active-session provider).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| child | Widget | yes | — | Body content (scrollable region) |
| header | Widget? | no | null | Page-specific header content shown after the brand + a "·" divider |
| showWorkoutBanner | bool | no | false | Show the accent "workout in progress" banner |
| workoutRoutineName | String? | no | null | Routine name shown in the banner |
| onResumeWorkout | VoidCallback? | no | null | Called when the banner is tapped |
| scrollable | bool | no | true | Wrap the child in a scroll view with bottom padding |

## Layout

```
┌───────────────────────────────────────┐
│ [◎ PRsonal] · [header slot]            │  header: 56dp, brand + optional content
├───────────────────────────────────────┤
│ ● Workout in progress · Push Day   →   │  banner: accent@0.08, only if showWorkoutBanner
├───────────────────────────────────────┤
│                                       │
│            child (scrollable)         │
│                                       │
└───────────────────────────────────────┘
```

## Visual States

| State | Appearance |
|-------|------------|
| header | brand wordmark "PR" (text-1) + "sonal" (accent), 13/700; bg `bg`, 1px bottom border |
| banner shown | accent@0.08 bg, pulsing accent dot, "Workout in progress" (accent/600), routine name (text-2), trailing "→" |
| banner hidden | not rendered |

## Accessibility
- Brand wordmark semantic label: "PRsonal"
- Banner is a single tap target with label "Resume workout, {routineName}"

## Acceptance Criteria
- AC-001: Widget renders the PRsonal brand wordmark
- AC-002: Widget renders the header content when provided
- AC-003: Widget shows the workout-in-progress banner with the routine name when showWorkoutBanner is true
- AC-004: Widget hides the workout-in-progress banner when showWorkoutBanner is false
- AC-005: Widget calls onResumeWorkout when the banner is tapped
- AC-006: Widget renders its body child
