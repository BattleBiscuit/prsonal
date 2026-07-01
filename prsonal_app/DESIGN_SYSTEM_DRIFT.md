# Design System Drift Report

Audit of `lib/` against `specs/design_system.md`, covering theme tokens, buttons, iconography,
surface treatment, visual tiering, typography, motion, and data visualisation. Not a spec (no
lifecycle status) — a point-in-time findings report to drive cleanup work.

Severity legend: **Critical** = visibly wrong or a named spec rule broken outright · **High** =
clear rule violation, moderate visual/behavioural impact · **Medium** = real drift, low visual
impact or narrow scope · **Low** = grid/token-hygiene nits.

---

## Critical

1. **Unfocused input border missing** — `lib/theme/app_theme.dart:178-181`. `enabledBorder` is
   `BorderSide.none`. Spec ("High-glare input contours", a *hard rule*): "an un-focused field
   always renders its `border` baseline... Focus then raises it to the 2px `accent` ring."
   Currently unfocused inputs show no contour at all, only the `surface2` fill. Fix:
   `BorderSide(color: _border, width: 1)`.

2. **Mono/tabular numerals unimplemented app-wide** — grep for `monospace`/`FontFeature`/
   `tabularFigures` across `lib/` returns zero hits. Spec tenet #3 ("Data stability"): "Every
   metric, counter, stopwatch, and tracking number uses mono tabular numerals." Affected:
   - `lib/widgets/session_header_widget.dart:64-67` — elapsed timer. Double violation: the
     widget's own approved spec (`specs/widgets/session_header.md:27`) says `elapsed (text-3,
     mono)`; code uses `text2` (wrong tier) and no mono/tabular styling at all.
   - `lib/widgets/set_row_widget.dart:111-119, 149-157, 254-262, 294-301, 341-348` — set index +
     live weight/reps fields.
   - `lib/widgets/history_set_table_widget.dart:87-90, 138-145`
   - `lib/widgets/stat_card_widget.dart:35-42`
   - `lib/widgets/body_metric_card_widget.dart:45-52`
   - `lib/widgets/pr_row_widget.dart:52-64`
   - `lib/widgets/volume_chart_widget.dart:56-63` — axis labels; spec explicitly says "mono
     tabular axis."

3. **Motion & life is almost entirely unimplemented** — `lib/theme/app_motion.dart` defines
   `AppDurations.fast/normal/slow` (120/200/400ms) matching spec exactly, but `grep -rln
   "AppDurations" lib/` finds no other reference anywhere — the token file is dead code.
   - **Live dot breathing pulse** (the spec's "signature" motion) — missing entirely. No
     `AnimationController` exists anywhere in `lib/`. `session_header_widget.dart` has no dot
     indicator at all.
   - **Progress bar fill (400ms ease)** — `lib/widgets/session_progress_bar_widget.dart:14-24` is
     a `StatelessWidget` using `FractionallySizedBox` directly; the bar snaps instantly instead of
     easing.
   - **On-load fade+rise (+8px, 200ms)** — missing entirely; zero `AnimatedOpacity`/
     `FadeTransition`/`SlideTransition`/`TweenAnimationBuilder` matches in `lib/`. All lists are
     plain `ListView`/`ListView.builder`.
   - **PR number-roll + accent flash** — `lib/widgets/pr_row_widget.dart` is a static
     `StatelessWidget`; no roll/flash of any kind.
   - **Skeleton loader** (surface1, opacity pulse 1→0.4→1 over 1.5s) — missing entirely; no
     shimmer/skeleton package in `pubspec.yaml`, no matches in `lib/`.

4. **Boxed-card pattern survives on the main landing screen** —
   `lib/screens/session_pick_screen.dart:114-119` (`_PlanBlock`) wraps each plan's routine list in
   `Container(color: surface1, border: Border.all(border), radius: zero)`. Spec: "List row: flat.
   No fill, no border, no radius... [boxed look] is retired here." This is the exact
   fill+border "elevated card" treatment the spec explicitly retired, applied to the app's primary
   Workout screen — the single clearest surviving instance of the old gym-app look.

5. **Volume chart has no "emphasized endpoint"** — `lib/widgets/volume_chart_widget.dart:37` sets
   `color: colors.accent` uniformly on every bar. Spec: "bars `accent@0.50`, **latest bar full
   accent** as the emphasized endpoint." The core visual language of this chart — highlighting the
   latest workout — is entirely absent; also no faint `surface3` baseline (`FlGridData`/
   `FlBorderData` both `show: false`, lines 45-46) and no staggered grow-on-load animation.

6. **Tier‑1 interactive rows left "bare"** (no trailing chevron/action icon) — spec: "every
   interactive row/target carries an explicit trailing glyph... No interactive row is left bare."
   - `lib/widgets/body_metric_card_widget.dart:23-64` (via `body_screen.dart:120`) — whole card is
     `InkWell`, zero trailing glyph.
   - `lib/widgets/history_card_widget.dart:25` — only trailing icon is `delete_outline`, mapped to
     a *different* action; the row's own navigate affordance is bare.
   - `lib/widgets/library_exercise_card_widget.dart:26` — same pattern.
   - `lib/widgets/plan_entry_row_widget.dart:51-63` — bare `GestureDetector`, no icon at all.
   - `lib/screens/plan_edit_screen.dart:52-66` — routine-picker `ListTile`, no trailing icon.
   - `lib/screens/session_pick_screen.dart:20-33` — "New routine"/"New plan" `ListTile`s, no icon.
   - `lib/screens/progress_screen.dart:208-222` — recent-session `ListTile`, no `trailing`.
   - `lib/screens/routine_edit_screen.dart:298-312` — `trailing: Icon(drag_handle)` communicates
     "reorder," not "tap to edit" (the actual `onTap`), so the real affordance is still unmarked.

7. **Forbidden button variant still exists** — `lib/widgets/app_button_widget.dart:13,40-44`.
   `AppButtonVariant.primary` (the default) renders a filled `surface2` grey box. Spec names this
   exact pattern and bans it: "grey filled boxes (**the legacy `primary` variant**) read as a false
   affirmative and are avoided." No current call site uses it, but it's a live footgun — any future
   `AppButton(...)` without an explicit `variant:` silently renders the banned look.

8. **PR banner uses the wrong surface treatment** —
   `lib/screens/history_detail_screen.dart:157-161` styles the PR banner as plain `surface1` +
   `Border.all(border)`. Spec ("Depth & elevation" / "PR moment"): `accent@0.06` bg, `accent@0.20`
   hairline. This is a plain elevated card where the spec calls for the accent-tinted "live/
   important" treatment.

9. **Workout-in-progress banner wrong alpha + missing border** —
   `lib/widgets/app_page_shell_widget.dart:78-83`. Spec: "`accent@0.08` bg, `accent@0.20` 1px
   hairline." Code uses `accent@0.15` for the bg (matches neither documented value) and sets no
   border at all.

10. **Brand wordmark "sonal" is the wrong colour** — spec: "brand wordmark 13/700 (`PR` in
    text-1, `sonal` in accent)." Both occurrences render `sonal` in `text2` instead:
    - `lib/widgets/app_page_shell_widget.dart:51-54`
    - `lib/widgets/brand_title.dart:31-37`

---

## High

11. **[DONE] Destructive buttons bypass the centralised theme** — spec claims button-role mappings are
    "centralised in `app_theme.dart`," but destructive is handled per call site with manual
    overrides:
    - `lib/screens/session_active_screen.dart:118-129` — "Abandon" is a bare `OutlinedButton` with
      `OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error, ...)` instead
      of `AppButton(variant: danger)` or a themed destructive style. Colour ends up correct only
      because someone remembered to override it by hand.
    - `lib/screens/plan_edit_screen.dart:216-222` — "Delete plan" is a bare `TextButton` (themed
      neutral/`text2`) with a manual `TextStyle(color: colors.danger)` fighting the default.

12. **[DONE] `AppFab` is dead code** — `lib/widgets/app_fab_widget.dart` has zero call sites. Screens use
    raw `FloatingActionButton` instead (`lib/screens/library_screen.dart:162-166`,
    `lib/screens/session_pick_screen.dart:96-100`). These happen to render correctly via
    `floatingActionButtonTheme`, but the dedicated component is unused and duplicated ad hoc.

13. **[DONE] Non-outlined icons** (spec: every icon uses the `*_outlined` Material variant, with 8 named
    exceptions — `search`/`close`/`check`/`add`/`drag_handle`/`percent`/`straighten`/
    `trending_up`):
    - `lib/widgets/plan_entry_row_widget.dart:104` — bare `Icons.play_arrow` (an outlined variant
      exists).
    - `lib/screens/progress_screen.dart:151, 195` — bare `Icons.chevron_right` for "View all" nav
      icons (an outlined variant exists). *Note: the spec's own canonical icon-only affordance map
      names `chevron_right` without the `_outlined` suffix — this is a spec-internal
      inconsistency worth reconciling, not purely an implementation bug.*

14. **[DONE — with one exception, see note] Icon colour-tier mismatches** (spec: delete → `danger`; volume up/down → `success`/`danger`;
    streaks → `warning`):
    - `lib/widgets/history_card_widget.dart:88`, `lib/widgets/library_exercise_card_widget.dart:93`,
      `lib/widgets/routine_card_widget.dart:63` — delete icons coloured `text3` instead of
      `danger`. Contrast with the correct pattern already present at
      `lib/widgets/exercise_form_widget.dart:251-254`. **Fixed** — all three now use
      `colors.danger`.
    - `lib/widgets/stat_card_widget.dart:24-26` — `toneColor` is hardcoded to `colors.accent`
      regardless of the `tone` param, per an explicit code comment ("the icon stays chalk"). This
      nullifies tone at both call sites: `lib/screens/progress_screen.dart:73-82` (volume trend,
      should be success/danger by sign) and `:100-105` (best streak, should be warning).
      **Not changed** — `specs/widgets/stat_card.md` (approved) explicitly documents this as
      intentional: "The monochrome identity means `tone` no longer maps to a hue; it is retained as
      a no-op parameter for call-site compatibility." Recolouring the icon here would contradict an
      already-approved widget spec; this is a design_system.md ↔ stat_card.md inconsistency to
      reconcile at the spec level, not an implementation bug to silently override.
    - Streak-flame icon `accent` instead of `warning` — **fixed**, but the actual location was
      `lib/screens/session_pick_screen.dart:140-151` (the `_PlanBlock` streak count + flame), not
      `plan_entry_row_widget.dart` as originally cited — that widget has no streak/flame icon at
      all. Both the flame icon and its adjoining streak-count number now use `colors.warning`.

15. **[DONE] 12 icon-only controls have no `Tooltip`** — spec: "Every icon-only control carries a
    `tooltip`." All 10 `IconButton`s correctly set one; these use `Semantics(button: true)` (or
    nothing) instead, which gives accessibility labelling but no visible hint:
    `lib/widgets/exercise_form_widget.dart:244-256`, `lib/widgets/session_header_widget.dart:37-46,
    72-81`, `lib/screens/plan_edit_screen.dart:264-271`, `lib/screens/body_screen.dart:173-185`,
    `lib/widgets/exercise_list_item_widget.dart:31-37, 60-69`,
    `lib/widgets/app_modal_widget.dart:47-54`, `lib/widgets/history_card_widget.dart:81-90`,
    `lib/widgets/library_exercise_card_widget.dart:86-95`,
    `lib/widgets/routine_card_widget.dart:56-65`. Worst case:
    **`lib/screens/session_pick_screen.dart:153-159`** (edit plan) is a plain `GestureDetector`
    with neither `Semantics` nor `Tooltip`.

16. **[DONE] Ad hoc `AlertDialog` bypasses the shared modal component** —
    `lib/screens/session_active_screen.dart:13-23, 88-107, 109-132` hand-rolls `showDialog` +
    `AlertDialog` for Finish/Abandon confirmations, instead of the `showConfirmSheet` helper
    (`app_modal_widget.dart`) every other screen uses (`library_screen.dart`,
    `plan_edit_screen.dart`, `routine_edit_screen.dart`). The default `AlertDialog` doesn't
    guarantee `surface1` / radius-0 / `black@0.70` scrim. **Fixed** — `_onFinish`/`_onQuit` now
    call `showConfirmSheet`; the local `_showAppModal`/`AlertDialog` helper is removed. Also
    aligned the dismiss-button labels to the already-approved `specs/screens/session_active.md`
    ("Keep going" for the finish modal, "Continue" for the abandon modal, replacing the generic
    "Cancel" both previously used) and gave "Save to history" the `accent` (affirmative) variant.

17. **[DONE] Radar chart deviations** — `lib/widgets/radar_chart_widget.dart`:
    - Line 43: fill `accent@0.2`; spec says `accent@0.12`. **Fixed.**
    - Lines 36-37, 50: grid/border reference `colors.border` where spec names `surface3` for
      "grid rings + spokes" (same hex today — `#2E2E2E` — but the wrong token semantically, a
      latent bug if they diverge). **Fixed** — grid/radar/tick borders now use `colors.surface3`.
    - Lines 39-40: `getTitle` sets no `TextStyle`; spec requires axis labels `xs`/`text2`.
      **Fixed** via `RadarChartData.titleTextStyle` (fl_chart puts per-title style there, not on
      `RadarChartTitle`).
    - No draw-in animation (spec: "scale 0→1, `normal`"). **Fixed** — wrapped the chart in a
      `TweenAnimationBuilder` scaling 0→1 over `AppDurations.normal`; added
      `specs/widgets/radar_chart.md` AC-003 and a widget test for it.
    - (Axis set/order — Chest, Shoulders, Arms, Back, Core, Legs, Glutes — is correct.)

18. **[DONE] Day-of-week selector below minimum touch target** —
    `lib/widgets/day_of_week_selector_widget.dart:29-33` — circular day chips are 40×40dp and
    tappable. Spec: "Minimum interactive height 48 dp everywhere." **Fixed** — chips now use
    `touchTargetMin` (48×48).

---

## Medium

19. **Dead widgets carrying the retired boxed-card look** — `lib/widgets/exercise_list_item_widget.dart:23-28`
    wraps its row in `Container(color: surface1, border: Border(bottom: ...))` (fill + hand-rolled
    hairline instead of the shared `Divider`). Confirmed unreferenced anywhere in `lib/` — as is
    `lib/widgets/routine_card_widget.dart`. Both are drift-in-waiting: present in the widget
    library as copy-pasteable templates of the wrong pattern, not currently rendered.

20. **Missing `Divider` separators** between list rows (spec: rows "separated by a Divider"):
    - `lib/screens/settings_screen.dart:27-38` — the two `SettingsRow`s have no divider between
      them (only one appears afterward, before the version line).
    - `lib/screens/session_pick_screen.dart:75-91, 163-183` — `PlanEntryRow` items have no
      separator at all, in either the per-plan blocks or the "Unplanned" section.

21. **Tier‑3 "today's plan row" not implemented** — the spec names this as a canonical live-focus
    example, but `lib/widgets/plan_entry_row_widget.dart` and `lib/services/plans_service.dart`
    have no "is this today" concept; no accent tint/rail is applied anywhere in
    `session_pick_screen.dart`. (Contrast: the mid-workout active-set Tier‑3 treatment in
    `lib/widgets/set_row_widget.dart:138-143` is correctly implemented — accent@0.06 tint + 2px
    accent left rail + accent@0.30 control contours — a good reference for what this row should
    look like.)

22. **Latent false-affordance risk in `pr_row_widget.dart`** — line 23 wraps pure Tier‑2 readout
    content in an unconditional `InkWell(onTap: onTap)`. Both current call sites
    (`all_prs_screen.dart:40`, `progress_screen.dart:164`) pass no `onTap` so it's inert today, but
    the widget has no trailing affordance built in and will silently become a bare tappable row
    the moment any caller wires a callback.

23. **`colorScheme.error` used instead of the `AppColors.danger` token path** —
    `lib/screens/session_active_screen.dart:120-121` (and related text styles at `:150-153,
    332-335` with no explicit `text1`/`onAccent` colour, falling back to Material defaults).
    Numerically identical today, but bypasses the documented token, unlike every other danger
    usage in the app (`colors.danger`).

24. **No skeleton loader implementation anywhere** — no shimmer/skeleton package in
    `pubspec.yaml`, no matching widget in `lib/`; loading states fall back to plain spinners or
    nothing. Real functional gap, not just a styling nit.

25. **No workout-in-progress banner on the landing screen** —
    `lib/screens/session_pick_screen.dart` is the natural place a live-session banner
    (`accent@0.08/0.14` bg, `accent@0.20` border) would surface, but none is rendered there.

---

## Low — grid & token-hygiene nits

26. **Spacing values off the 4-pt grid** (not a multiple of 4): `set_row_widget.dart` (`horizontal:
    10` BW-toggle padding; `22×22` inner checkbox box), `settings_row_widget.dart` (`vertical: 14`;
    `height: 2`), `stat_card_widget.dart` (`height: 2`), `history_detail_screen.dart` (`vertical:
    2`; `width: 28` vs. `32` used for the same purpose in `set_row_widget.dart`),
    `progress_screen.dart:253` (`_RangeButton`, `vertical: 6`), `app_input_widget.dart:45` /
    `app_textarea_widget.dart:41` (`height: 6`), `chart_slider_widget.dart:62` (`horizontal: 3`),
    `library_exercise_form_widget.dart:130-131, 220, 255` (`6, 6, 10, 5`),
    `plan_entry_row_widget.dart:92-95` (`vertical: 14`).

27. **Hardcoded `48.0` instead of `touchTargetMin`** — `lib/widgets/app_button_widget.dart:30`
    (file doesn't even import `app_spacing.dart`), `lib/widgets/rest_action_button_widget.dart:27`,
    `lib/widgets/set_row_widget.dart:189-190` (`SizedBox(48, 48)`).

28. **Systemic token-bypass**: almost every screen uses raw numeric literals (`EdgeInsets.all(16)`,
    `SizedBox(height: 8)`, …) instead of the named `space1`..`space12` constants from
    `lib/theme/app_spacing.dart`. Values are mostly valid 4-multiples so not grid violations, but
    only `progress_screen.dart` imports `app_spacing.dart` at all (and only for `radiusFull`).

29. **Invented magic number** — `lib/screens/session_active_screen.dart:317`, `height: 52` on the
    primary action button; nearest token is `touchTargetMin` (48).

30. **Undocumented alpha derivation** — `lib/widgets/library_exercise_form_widget.dart:258` uses
    `accentDim@0.2`, not present in the spec's alpha-derivation table.

31. **Badge alpha off-spec** — `lib/widgets/history_card_widget.dart:53` — danger badge bg at
    `alpha: 0.15`; spec's semantic badge table says `@0.20`.

32. **Divider token traceability** — `lib/theme/app_theme.dart:134-138` `dividerTheme` references
    `_surface3` rather than a semantically named `border` constant. Numerically identical
    (`#2E2E2E` either way) so the rendered hairline is correct, but the naming obscures intent.

33. **Icon size band** — `lib/screens/routine_edit_screen.dart:309`, `Icon(Icons.drag_handle)` has
    no explicit `size:`, defaulting to `ListTile`'s 24dp trailing size, slightly above the spec's
    18-20dp inline-row band.

---

## Summary by category

| Category | Count |
|---|---|
| Colour token bypass / mismatch | 6 |
| Border radius drift (non-pill circular) | 0 confirmed — squared panels are consistently correct |
| Boxed-card / surface-treatment drift | 3 (1 live on the main screen, 2 dead-code templates) |
| Missing list-row dividers | 2 screens |
| Visual-tiering (Tier 1/2/3) gaps | 9 bare interactive rows, 1 unimplemented Tier‑3 case, 1 latent false-affordance widget |
| Button semantic-colour issues | 4 (1 banned variant live in the enum, 2 manual theme-bypass overrides, 1 dead `AppFab` + 2 duplicated raw FABs) |
| Non-outlined icons | 3 |
| Icon colour-tier mismatches | 6 |
| Icon-only controls missing `Tooltip` | 12 |
| Typography — mono/tabular numerals missing | 7 widgets / ~15 call sites (app-wide gap) |
| Motion — features entirely unimplemented | 5 of 6 (heartbeat, progress-bar fill, load fade+rise, PR roll/flash, skeleton loader); `AppDurations` tokens are dead code |
| Data-viz deviations (radar + volume charts) | 8 |
| Spacing/grid nits (off 4-pt grid, magic numbers, token-bypass) | ~15 individual instances + 1 systemic pattern |
| Emoji / banned icon usage | 0 — clean |

**Biggest levers, in priority order:**
1. Fix the unfocused-input border (1-line theme fix, breaks a named hard rule).
2. Decide on and implement mono/tabular numerals — currently a top-level tenet with zero
   implementation anywhere, including in the one widget spec that names it explicitly.
3. Either implement the "Motion & life" section or formally descope it — right now the duration
   tokens exist but nothing uses them, so the "alive but still" identity described in the spec
   isn't present in the running app at all.
4. De-box `session_pick_screen.dart`'s `_PlanBlock` (the one live boxed-card instance on the main
   screen) and delete or fix the two dead boxed-card widgets so they can't be copy-pasted forward.
5. Sweep the 9 bare Tier‑1 rows for trailing affordances and remove the forbidden
   `AppButtonVariant.primary` before it gets used by accident.
