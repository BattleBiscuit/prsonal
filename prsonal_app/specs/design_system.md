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

## Core design tenets
Graphite is a dark-only, monochrome, flat, hard-edged instrument built for weightlifters. The brand
lives in contrast, utility, and mathematical stability — not hue. Four tenets govern every screen:

1. **Flat over boxed.** Avoid card-heavy layouts. Divide data blocks with structural hairline
   dividers (`1px` `border` `#2E2E2E`) and composed spacing, not chrome. (See *Surface treatment*.)
2. **Hard-edged.** Panels and layout blocks are square 90° corners. Only genuine functional pills
   (chips, toggles, switch, badge, FAB) stay fully round. (See *Border radius*.)
3. **Data stability.** Every metric, counter, stopwatch, and tracking number uses `mono` tabular
   numerals (`fontFeatures: [FontFeature.tabularFigures()]`) so columns and deltas never shift
   layout mid-training.
4. **Color economy.** Standard interface elements are monochrome. `success` / `danger` / `warning`
   are reserved for high-impact semantic events (a PR, an abandoned session, a delete) — never
   decoration, never the brand accent.

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
| Active set row bg / rail | `accent @ 0.06` fill + a 2px `accent` left rail (Tier 3 live row) |
| Live-row field / checkbox contour | `accent @ 0.30`, 2px (thicker dim-grey edge — never a white outline) |
| Interactive press wash | `accent @ 0.06` |
| Accent badge bg | `accent @ 0.15` |
| Success / danger / warning badge bg | respective colour @ 0.20 |
| PR banner bg / border | `accent @ 0.06` / `0.20` |
| Danger button pressed bg | `danger @ 0.10` |
| FAB shadow | `black @ 0.40` |

---

## Spacing (4-pt grid)
`space1`=4 · `space2`=8 · `space3`=12 · `space4`=16 · `space5`=20 · `space6`=24 ·
`space8`=32 · `space10`=40 · `space12`=48 (logical px → dp).

## Border radius — squared panels (decided)
The app is **hard-edged**: panels have square 90° corners. The graduated rounded scale is retired —
`sm`=`md`=`lg`=`xl`=**0**. Only genuine **pills/stadiums** stay round: `full`=9999 (pill/circle).

- **Square (0):** buttons, inputs/textareas, bottom sheets & modals, dialogs, metric tiles,
  cards, progress bar, chart bars — every panel and rounded rectangle.
- **Pill (`full`):** FAB, filter chips, the range/type **toggles**, the switch, the `AppBadge`,
  and the set-kind chip. These read as deliberate round accents against the squared everything-else.
- **Pills use the `radiusFull` token — never a hand-picked radius.** Any soft `circular(16…28)`
  value is a bug: a pill is `radiusFull`, everything else is `0`. There is no in-between.
- The brand mark's curves are logo geometry, not a panel radius, and are unaffected.

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

## Iconography (decided)
Icons are monochrome line instruments, consistent with the flat, hard-edged system.

- **One style: outlined.** Every icon uses the Material **`*_outlined`** variant (e.g.
  `Icons.fitness_center_outlined`). Filled/rounded/sharp variants are not used. Glyphs that are
  inherently single-stroke and have no outlined variant — `search`, `close`, `check`, `add`,
  `drag_handle`, `percent`, `straighten`, `trending_up` — are already line-style and are kept.
- **No emoji, ever.** No emoji glyphs in UI strings, notification copy, labels, or as icons.
  Achievement/status markers use a vector icon, never an emoji — the PR marker is
  `Icons.star_outline` (not a trophy emoji), and the rest-timer notification carries no emoji.
  This also rules out `Icons.emoji_events` despite it rendering as a vector.
- **Colour by tier, not decoration.** Default affordance/metadata icons are `text3`; secondary
  `text2`; active/affirmative and live markers `accent`. Semantic icons follow *Color economy* —
  `success` (completed check), `danger` (delete/close-session), `warning` (PR star, streak).
- **Sizes.** Inline row affordances 18–20; primary/nav icons 22–24; banner/eyebrow marks 16.
- **Icon-only affordances (decided).** Interactive elements are icon-only wherever a canonical
  glyph represents the action — text labels are dropped in favour of the icon. The canonical map:
  save → `check` (accent), add / create / log → `add` (accent), edit → `edit_outlined` (text2),
  navigate / view-all → `chevron_right` (text2), delete → `delete_outline` (danger), close /
  cancel-as-standalone → `close`. Action FABs are the bare icon (a circular `accent` pill), not an
  extended text FAB. Every icon-only control carries a `tooltip` (its former label) for
  accessibility and semantics. **Exception — paired decision buttons keep their text:** the two
  buttons of a confirm/cancel choice in a modal, sheet, or form footer (e.g. *Save to history* /
  *Abandon* / *Cancel* / *Save* in the finish, quit, and editor forms) stay worded, because the
  label states the consequence and two bare icons would be ambiguous.

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

## Mobile safeguards (decided)
Production hardening for high-glare gyms and Android gesture navigation. These are hard rules, not
suggestions.

- **Touch-target isolation / edge padding.** Interactive list rows keep an absolute horizontal
  buffer of at least `space4` (16) inside the phone layout, so taps never collide with edge-swipe
  gestures on curved screens. (Satisfied by the flat list-row padding.)
- **Android safe-area insets.** The bottom nav shell never crashes into the system home line — it
  reserves bottom space equivalent to `clamp(space4, safeBottom, space6)` (16–24) via Flutter
  `SafeArea` / `MediaQuery.padding`. Scrollable content adds `navHeight + safeBottom + space4`.
- **High-glare input contours.** Inputs and layout cells keep a discoverable contour even when
  un-focused: an un-focused field always renders its `border` baseline (`enabledBorder`), so forms
  don't vanish under screen glare. Focus then raises it to the 2px `accent` ring.

---

## Surface treatment — flat rows, not cards (decided)
The app is **flat**. Lists and grids do **not** wrap each item in a bordered, filled box; that
boxed-card look (ported verbatim from gym-app) is retired here as an intentional divergence — the
same way the lime accent was retired for chalk. Hierarchy comes from **type, spacing and a single
hairline**, not from chrome. Filled/bordered boxes (`surface1` + `border` + radius) survive **only**
for genuinely elevated surfaces: modals/sheets, the workout & PR banners, and skeleton loaders.

- **List row** (default for any item in a vertical list — routines, history, library, PRs): flat.
  **No fill, no border, no radius.** Padding `space4` horizontal · ~`space3`–`space4` vertical, min
  height `touchTargetMin`. Tap = ink ripple. Rows are separated by a **Divider** (below); the list
  itself is edge-to-edge (vertical-only outer padding) so the hairline spans the full width.
- **Metric tile** (KPI grids — progress stats, body metrics): flat. **No fill, no border.** A large
  value (`xl`–`2xl`/700, `text1`) over an uppercase/secondary caption (`xs`/600, `text2`), optional
  leading icon in `accent`. Tiles are separated by `space2`–`space3` **whitespace** within their
  grid — never boxed, no dividers.
- **Divider** (list-row separator): a 1px hairline in `border` (`#2E2E2E`). Centralised in
  `dividerTheme`, so a bare Flutter `Divider()` renders it (`thickness: 1`, `space: 1`).
- **Elevated card** (modals, banners, skeleton **only**): `surface1` bg, optional 1px `border`,
  radius `lg`–`xl`, padding `space4`.
- **Bottom sheet / modal**: bottom-aligned, `surface1`, top radius `xl`, scrim `black@0.70`,
  slide-up `normal`. (`AppModal`.)
- **Pill button / toggle**: radius `full`, accent-filled when active with `onAccent` text.
- **Badge**: pill, `xs`/500, colour pairs per *Semantic*. (`AppBadge`.)
- **Skeleton loader**: `surface1` block, opacity pulse 1→0.4→1 over 1.5s (lists while loading).
- **FAB**: pill, `accent` bg, `onAccent` content, `sm`/700, fixed above the nav. (`AppFab`.)

## Buttons — semantic colour (decided)
Button colour is driven by **intent, not widget type**, so navigating the app feels unified: the
signature chalk only ever marks the affirmative action. Three roles:

| Role | Used for | Treatment | Material widget | `AppButton` variant |
|------|----------|-----------|-----------------|---------------------|
| **Affirmative** | save · accept · add · create · log · confirm-positive · complete · finish | **`accent` chalk fill**, `onAccent` text, `accentDim` pressed | `FilledButton` / `ElevatedButton` | `accent` |
| **Neutral** | cancel · edit · back · view / navigate · dismiss | **grey** — `text2` label (ghost border when a bordered secondary is needed) | `TextButton` / `OutlinedButton` | `ghost` |
| **Destructive** | delete · abandon · discard · remove | **`danger`** text/border (never chalk) | danger-styled button | `danger` |

Rules:
- Every positive action is chalk; there may be more than one in a view (e.g. **Save** and **Add**).
  Lightweight inline adds inside a form (e.g. "Add set") may use **chalk *text*** rather than a
  full chalk fill so they don't compete with the view's primary affirmative — still the signature
  colour, just quieter.
- A neutral action is **never** chalk and **never** a filled grey box; grey filled boxes
  (the legacy `primary` variant) read as a false affirmative and are avoided.
- Destructive actions keep the semantic `danger` colour regardless of how prominent they are.
- These mappings are centralised in `app_theme.dart`'s button themes, so a bare `FilledButton`
  is affirmative and a bare `TextButton`/`OutlinedButton` is neutral without per-call styling.

## Depth & elevation (decided)
With surfaces flat and squared, elevation is carried by **surface step + a hairline + a scrim**, not
by rounding or large shadows. Three tiers only:

| Tier | Use | Treatment |
|------|-----|-----------|
| **Base** | the page | `bg` `#0F0F0F`, content sits directly on it |
| **Raised** | section panels that need to detach (rare), the **nav bar** | `surface1`, top/edge 1px `border` hairline — no shadow |
| **Overlay** | sheets, dialogs, the active-session add-sheet | `surface1` + full-screen scrim `black@0.70` + the one shadow `0 8 24 black@0.50` |

Accent-tinted surfaces signal a **live/important** state, not mere elevation:
- **Workout-in-progress banner** — `accent@0.08` bg, `accent@0.20` 1px hairline, a live dot + running timer; tappable back into the session.
- **PR moment** — `accent@0.06` bg, `accent@0.20` hairline, a brief number-roll on the new value.

## Visual tiering architecture — anti-confusion framework (decided)
The single most important finish: the eye must know what it can touch, what is read-only, and what
is live *right now*. In a monochrome interface, interactive elements risk blending with readouts
(the "monochrome trap"). Every view sorts its contents into exactly three tiers.

### Tier 1 — Interactive ("tap me")
Opens, navigates, toggles, or edits.
- **Surface**: raised — `surface1` (`#1A1A1A`) for tappable rows/containers, `surface2` (`#242424`)
  for active text inputs.
- **Typography**: high-contrast `text1` (`#F5F5F5`), medium/bold weight.
- **Trailing affordance (required)**: every interactive row/target carries an explicit trailing
  glyph — a `chevron` (navigates) or an action icon (toggle/edit/delete) in `text3` — to signal
  momentum. No interactive row is left bare.
- **Press feedback**: ink ripple **and** a press wash (`accent@0.06`). Min height `touchTargetMin`.

### Tier 2 — Static ("read-only")
Readouts: set tables, history values, metric tiles, logs, the version line.
- **Surface**: **no** background box — static content is stamped directly onto the `bg` canvas
  (`#0F0F0F`). If a container boundary is structurally unavoidable, it uses a **dashed** hairline
  (`1px dashed` `border`), never a solid filled box — the dash reads "boundary, not button".
- **Typography**: drop contrast to `text2` (`#9E9E9E`) or `text3` (`#616161`), normal weight.
- **No affordance**: **never** a trailing chevron/arrow/menu icon, **no** ripple, **no** rail.
  If it doesn't react, it must not look like it would.

### Tier 3 — State-proposing ("live / active focus")
The single element commanding immediate attention right now (the current active set mid-workout,
a live readout). One per context.
- **Live "you are here" row (primary)**: the active element — the current set mid-workout, the
  active nav tab, today's plan row — is marked by a **faint `accent @ 0.06` tint with a 2px
  `accent` left rail** and light (`text1`) content. It reads as the live focus without glaring.
  Interactive controls inside it (inputs, the complete checkbox) carry a **thicker 2px `accent @
  0.30` contour** — a firm dim-grey edge for high-glare gyms, never a bright white outline.
- **Chalk outline (heavier alternative)**: where a row needs to shout louder than the rail, a
  thick **2px solid `accent`** outline frames it instead.
- A full solid-chalk polarity-inverted block (`#EDEDED` bg + `onAccent` content) was trialled and
  **retired as too glaring** in the workout view — the tint + rail carries the same "live" meaning
  with far better comfort.
- **Heartbeat**: the live dot (`.live-dot`) runs the breathing pulse to declare a live routine
  (see *Motion & life*).
- **Focus**: a 2px `accent` ring on the focused control (keyboard/switch-access parity).

## Data visualisation (decided)
Charts are monochrome instruments, given the same care as type.
- **Radar (muscle balance)** — 7 fixed axes (Chest, Shoulders, Arms, Back, Core, Legs, Glutes);
  `surface3` grid rings + spokes; data polygon = `accent` stroke over `accent@0.12` fill; axis
  labels `xs`/`text2`. Draws in (scale 0→1, `normal`).
- **Volume (per-workout)** — bars `accent@0.50`, **latest bar full `accent`** as the emphasized
  endpoint; faint `surface3` baseline; `mono` tabular axis. Bars grow on load (`normal`, staggered).
- Numbers everywhere use **`mono` tabular** so columns and deltas line up.

## Motion & life (decided)
The app should feel **alive but still** — one live moment per context, calm everywhere else.
- **Session heartbeat** (the signature): the live dot **breathes** (opacity/scale, 1.6s loop); the
  session timer ticks in `mono`; the progress bar fills `400ms` on advance.
- **On load**: lists/sections fade+rise (+8px, `normal`); chart series animate in once.
- **On press**: `fast` press wash; affirmative buttons settle to `accentDim`.
- **PR**: a one-shot number-roll + a brief accent flash on the row.
- All motion respects `prefers-reduced-motion` / the OS "reduce motion" flag — it drops to instant.

## Layout rhythm (decided)
- Screens open with the content, not chrome: a `space4` top gap, then an `eyebrow`, then the list.
- One **hero** per analytical screen (Progress leads with the biggest number — workouts or streak —
  before the supporting tiles), so there's a clear entry point for the eye.
- Vertical rhythm is on the 4-pt grid: `space4` between sections, `space2`–`space3` within a group.
- Lists are edge-to-edge; section headers and hero content keep `space4` horizontal insets.

## Notes for "identical" fidelity
- Accent `#EDEDED` is the signature; it appears on every primary action, active state, and PR.
- Inactive nav/icons are `text3` (`#616161`), not a faded white.
- "Abandoned" sessions and streak counts use `warning` (`#FF9800`); volume up/down and
  completed sets use `success`/`danger`.
