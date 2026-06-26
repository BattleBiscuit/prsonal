---
name: Design System
type: decision
status: approved
---

## Purpose
The single source of truth for the app's visual language. Every colour, size, and radius below is
exact. Feature specs reference these tokens **by name** (e.g. `accent`), never hard-coded values —
so a palette change happens here and propagates everywhere.

The app is **dark-only**. The whole app is a fixed, non-scrolling shell with inner scroll regions
— implemented in Flutter as a `Scaffold` whose body scrolls, not the page.

## Theme direction — Graphite (monochrome)
The identity is **monochrome**: the brand carries on contrast and value, not hue. The `accent`
(primary CTAs, active nav, PR, focus, logo) is **chalk white**, not a colour. The structure was
ported from gym-app; the original lime accent (`#E8FF47`) is retired in favour of chalk (`#EDEDED`).

**Semantic colours stay coloured** — `success` / `danger` / `warning` convey function (a delete is
red, a gain is green) and are deliberately exempt from the monochrome rule. They are never used as
the brand accent.

---

## Implementation

- `lib/theme/app_theme.dart` exposes `appTheme` (`ThemeData`, Material 3, dark).
- `lib/theme/app_colors.dart` exposes `AppColors` — a `ThemeExtension` carrying the tokens that
  don't fit cleanly into `ColorScheme` (the surface ladder, the three text tiers, accent-dim,
  semantic colours). Access via `Theme.of(context).extension<AppColors>()!`.
- Spacing/radius/durations are `const` values in `lib/theme/app_spacing.dart`.

`ColorScheme.dark` mapping:

| ColorScheme slot | Token | Hex |
|------------------|-------|-----|
| `primary` | accent | `#EDEDED` |
| `onPrimary` | (hardcoded dark) | `#0F0F0F` |
| `surface` | bg | `#0F0F0F` |
| `onSurface` | text-1 | `#F5F5F5` |
| `surfaceContainer` | surface-1 | `#1A1A1A` |
| `surfaceContainerHigh` | surface-2 | `#242424` |
| `surfaceContainerHighest` | surface-3 | `#2E2E2E` |
| `onSurfaceVariant` | text-2 | `#9E9E9E` |
| `outline` | border | `#2E2E2E` |
| `error` | danger | `#F44336` |

---

## Colours

### Surfaces (backgrounds)
| Token | Hex | Role |
|-------|-----|------|
| `bg` | `#0F0F0F` | App / scaffold background |
| `surface1` | `#1A1A1A` | Cards, bottom nav, modals |
| `surface2` | `#242424` | Inputs, primary buttons, table headers |
| `surface3` | `#2E2E2E` | Pressed/active states, default badges, toggle track |

### Accent
| Token | Hex | Role |
|-------|-----|------|
| `accent` | `#EDEDED` | Primary CTA, FAB, active nav/tab, focus ring, PR, logo |
| `accentDim` | `#C7C7CC` | Accent pressed state |
| `onAccent` | `#0F0F0F` | Text/icon on accent surfaces (hardcoded) |

### Semantic
| Token | Hex |
|-------|-----|
| `success` | `#4CAF50` |
| `danger` | `#F44336` |
| `warning` | `#FF9800` |

### Text
| Token | Hex | Role |
|-------|-----|------|
| `text1` | `#F5F5F5` | Primary text |
| `text2` | `#9E9E9E` | Secondary / labels |
| `text3` | `#616161` | Tertiary, placeholders, inactive nav icons |

### Borders
| Token | Hex |
|-------|-----|
| `border` | `#2E2E2E` |
| `borderFocus` | `#EDEDED` |

### Common alpha derivations (use `Color.withValues(alpha:)`)
| Use | Value |
|-----|-------|
| Modal scrim | `black @ 0.70` |
| Workout banner bg / active | `accent @ 0.08` / `0.14` |
| Workout banner border | `accent @ 0.20` |
| Active set row bg | `accent @ 0.04` |
| Accent badge bg | `accent @ 0.15` |
| Success / danger / warning badge bg | respective colour @ 0.20 |
| PR banner bg / border | `accent @ 0.06` / `0.20` |
| Danger button pressed bg | `danger @ 0.10` |
| FAB shadow | `black @ 0.40` |

---

## Spacing (4-pt grid)
`space1`=4 · `space2`=8 · `space3`=12 · `space4`=16 · `space5`=20 · `space6`=24 ·
`space8`=32 · `space10`=40 · `space12`=48 (logical px → dp).

## Border radius
`sm`=4 · `md`=8 · `lg`=16 · `xl`=24 · `full`=9999 (pill/circle).

## Layout constants
| Token | Value |
|-------|-------|
| `navHeight` | 56 |
| `headerHeight` | 56 |
| `touchTargetMin` | 48 |
| Scrollable content bottom padding | `navHeight + safeBottom + 16` |

Safe areas map to Flutter `SafeArea` / `MediaQuery.padding`.

## Typography
System font (`Roboto` on Android via the default Material `Typography`). Mono = `monospace`
(used only for elapsed time / tabular numerals).

| Token | Size | Typical weight |
|-------|------|----------------|
| `xs` | 12 | 400/500 |
| `sm` | 14 | 400/500/600 |
| `base` | 16 | 400/600 (body default, line-height 1.5) |
| `lg` | 18 | 600 |
| `xl` | 20 | 700 |
| `2xl` | 24 | 700 |
| `3xl` | 30 | 700 |

Weights: `normal`=400 · `medium`=500 · `semibold`=600 · `bold`=700.

Special inline sizes preserved from gym-app: nav tab label 10/500; brand wordmark 13/700
(`PR` in text-1, `sonal` in accent); section eyebrows uppercase `xs`/600 in text-3 with
letter-spacing ~0.08em.

`TextTheme` mapping (approx): `displaySmall`→3xl, `headlineSmall`→2xl, `titleLarge`→xl,
`titleMedium`→lg, `bodyLarge`→base, `bodyMedium`/`bodySmall`→sm, `labelSmall`→xs.

## Motion
| Token | Value |
|-------|-------|
| `fast` | 120ms ease |
| `normal` | 200ms ease |
| Progress-bar fill | 400ms ease |
| Modal/sheet slide-up | 200ms ease (slide from +40px + fade) |

## Shadows
FAB: `0 4 16 black@0.40`. Drag ghost (if reorder kept): `0 8 24 black@0.50`.

## Global interaction rules
- Tap highlight: use Material ink ripples (gym-app disabled the web tap highlight; Flutter's
  ripple is the native equivalent and is acceptable).
- Minimum interactive height 48 dp everywhere.
- Focused inputs: 1px → use a 2px `accent` border (`borderFocus`).
- Disabled controls: opacity 0.4.

---

## Reusable visual patterns (specced as widgets in `specs/widgets/`)
- **Card**: `surface1` bg, 1px `border`, radius `lg`, padding `space4`.
- **Bottom sheet / modal**: bottom-aligned, `surface1`, top radius `xl`, scrim `black@0.70`,
  slide-up `normal`. (`AppModal`.)
- **Pill button / toggle**: radius `full`, accent-filled when active with `onAccent` text.
- **Badge**: pill, `xs`/500, colour pairs per *Semantic*. (`AppBadge`.)
- **Skeleton loader**: `surface1` block, opacity pulse 1→0.4→1 over 1.5s (lists while loading).
- **FAB**: pill, `accent` bg, `onAccent` content, `sm`/700, fixed above the nav. (`AppFab`.)

## Notes for "identical" fidelity
- Accent `#EDEDED` is the signature; it appears on every primary action, active state, and PR.
- Inactive nav/icons are `text3` (`#616161`), not a faded white.
- "Abandoned" sessions and streak counts use `warning` (`#FF9800`); volume up/down and
  completed sets use `success`/`danger`.
