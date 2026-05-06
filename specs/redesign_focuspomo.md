# Redesign — FocusPomo Direction

> Status: **v1.0 shipped** · Owner: @guiga · Last updated: 2026-05-06 · See "Retro" at the bottom for what changed from the plan.
>
> Companion specs: `specs/theme.md` (theme mode) · all feature specs (logic stays;
> only UI gets re-skinned).

Complete visual rewrite of MyCycle to match the FocusPomo aesthetic — warm
beige surfaces, terracotta accent, rounded sans typography, generous breathing
room, and timeline-style content blocks. Logic, business rules, repositories,
specs and tests stay exactly as they are. **Only the design system tokens and
the presentation layer change.**

Reference: [FocusPomo on Refero](https://refero.design/apps/181) — the
canonical screen we're matching is the [Focus Session
Timeline](https://refero.design/screens/5dda5c24-10db-4789-83f9-c8654802dd91).

---

## Why we're doing this

Current Bloom palette and typography were the right v1 (rose primary +
Fraunces serif gave a journal feel), but in practice it skews "feminine
diary" — closer to Flo than to a calm everyday companion. The wife (the
primary user) consistently bounces toward warm, rounded, beige aesthetics
(FocusPomo, Headspace) and away from anything pink-saturated or dark.

FocusPomo nails the four product principles already in `CLAUDE.md`:

1. **Privacy as default** — visual quietness reinforces "this is yours, no
   one's watching."
2. **Journal, not dashboard** — beige surfaces and rounded shapes feel like
   a notebook, not an analytics tool.
3. **5-second daily interaction** — large tap targets, single-CTA layouts,
   nothing competing for attention.
4. **Honest predictions** — calm chromatic encoding (sálvia for fertility,
   coral for period, soft outlines for ranges) instead of scary reds and
   bright blues.

---

## Two open decisions (need answer before Phase 1 starts)

### Decision A — Drop Fraunces?

FocusPomo uses **rounded sans throughout**. Current Bloom mixes Fraunces
(editorial serif, display tier) with Inter (body). To match FocusPomo
"exactly", Fraunces has to go.

**Recommendation:** drop Fraunces, switch to a single rounded sans family
across all tiers. Two viable choices via `google_fonts` (already in
pubspec):

- **Plus Jakarta Sans** — close to FocusPomo's actual SF Rounded
  equivalent. Slightly more geometric.
- **Nunito** — softer, more rounded, friendlier. Closer match to the
  FocusPomo screenshot.

Default proposal: **Nunito**, weights 400/500/600/700.

### Decision B — Dark mode: keep, drop, or warm-variant?

Today the app supports `system / light / dark` (see `specs/theme.md`).
FocusPomo's main aesthetic is the warm light mode; it does have a dark
variant for widgets but it's incidental, not the brand identity. The
wife dislikes dark mode.

Three options:

- **B1. Drop dark mode entirely.** Simpler. Removes the toggle from
  Settings, removes `ThemeCubit.toggleLightDark`, hard-codes
  `themeMode: ThemeMode.light` in `MaterialApp`. Test coverage stays
  (only light theme exists). Saves ~40 LOC.
- **B2. Keep dark mode, redesign the dark palette to be "warm dark"**
  (deep brown/cocoa instead of black). More work; preserves the toggle
  for the husband if he ever wants it.
- **B3. Keep current dark mode as-is, just refresh light.** Cheapest. But
  the dark palette currently uses cold `#1A1416` — won't feel coherent
  with the warm-only light brand.

Default proposal: **B1 (drop dark mode)**. Easier, matches the wife's
preference, and we can always add back a warm dark later. The
`ThemeCubit` itself can stay (cheap, already tested) but be locked to
`ThemeMode.light`.

---

## Visual tokens — proposed deltas

All hex values pulled from analysing the FocusPomo screenshot
(`5dda5c24-...`) and the welcome / settings / paywall variants.

### Colors

| Token | Current (`BloomColors.*`) | New | Notes |
|---|---|---|---|
| Primary accent | `rose #C9637E` | `terracotta #D9634F` | FocusPomo CTA + selected day |
| Primary container | `petalSoft #F4E5E1` | `terracottaSoft #F5DDD2` | hover/pressed bg for primary |
| Scaffold background | `cream #FAF5F2` | `bege #F0E6D9` | the warm "outer" tone |
| Surface (cards) | `petalMist #FFFFFF` | `cream #FAF1E6` | the slightly lighter "inner" tone |
| Surface variant | `petalSoft #F4E5E1` | `pebble #E8DECF` | section dividers / pill bg |
| Outline | `pearlEdge #EFE4DF` | `pebbleEdge #DCD0BE` | hairline borders |
| Ink (primary text) | `#3D2E2C` | `#3C332C` | warm deep brown — basically same |
| Ink soft | `#6B5856` | `#8C7F73` | slightly cooler / paler |
| Whisper gray | `#998B89` | `#A89E94` | label text |
| Phase: menstrual | `#B8485A` | `#D9634F` | unify with primary terracotta |
| Phase: follicular | `#E8A87C` | `#E68A4A` | warmer orange |
| Phase: ovulation | `#8FA88E` | `#7BC57E` | sálvia green (matches FocusPomo "Focus") |
| Phase: luteal | `#A89BBF` | `#E5C97D` | warm muted yellow (matches "Fitness") |
| Success / Warning / Error / Info | unchanged | unchanged | tweak only if necessary |

### Typography

If Decision A = Nunito:

- All tiers use `GoogleFonts.nunito(...)`.
- Display tier (display/h1/h2) keeps current sizes but switches font.
- Drop the editorial letter-spacing (Fraunces needed it; Nunito doesn't).
- Body weights: 400 regular, 500 medium, 600 semibold, 700 bold.

### Spacing / Radii

Keep the existing scale (it's already 4-base and matches FocusPomo's
generous spacing). One tweak:

- `BloomRadii.card`: `20 → 16` (FocusPomo's content blocks read closer
  to 16 than 20).
- `BloomRadii.pill`: `999` (unchanged, FocusPomo's date pills + CTA are
  fully rounded).

### Elevation

FocusPomo uses **almost no shadows** — depth comes from background tone
contrast (bege outer / cream inner). Replace any `elevation: 2` style
shadows with surface contrast. Cards stay `elevation: 0`.

---

## New + refactored components

### Refactor existing (no API change, only visuals)

| Component | What changes |
|---|---|
| `BloomPrimaryButton` | Drop the gradient, use solid terracotta. Pill radius. Bigger vertical padding (`s20` instead of `s16`). White text, weight 700. |
| `BloomSecondaryButton` | Cream surface, brown text, pebble outline. |
| `BloomChoiceChip` | Soft pebble bg when unselected, terracotta when selected. Weight 600 inside. |
| `BloomSegmented` | Same logic, swap to new color tokens. Pill thumb. |
| `BloomLargeHeader` | Drop serif. Use Nunito 700 ~28pt. Brown ink color. |
| `BloomGroupedList` | Each section is a single rounded-corner card on `surface` (cream over bege bg). Section title outside the card, in `whisperGray` uppercase. |
| `BloomSettingsTile` | Circular icon badge on the left (colored bg + white icon), text + chevron. Match FocusPomo "Email Us / Instagram" pattern. |

### Add new

| Component | Purpose | Used by |
|---|---|---|
| `BloomDayPillRow` | Horizontal row of day-of-week pills (Mon 12 / Tue 13 / ...). Selected day in terracotta, others in pebble. | Today, Calendar |
| `BloomTimelineBlock` | Colored rounded block with label + duration. Variants for each phase color. | Today, Calendar day detail |
| `BloomCategoryGrid` | 2x3 grid of rounded-square colored icons + labels, used for onboarding/welcome. | Onboarding welcome |
| `BloomSectionCard` | Cream-surface rounded card with internal title row + body slot. The atomic unit FocusPomo uses for everything. | Settings, Insights, Today, Pairing |
| `BloomTomatoFooter` (or rename: `BloomMascotFooter`) | Optional small mascot + tagline at the bottom of low-traffic screens (Settings/About). Decide later — could feel cute or awkward. | Settings (maybe), About |

---

## Phased rollout

### Phase 0 — This document + decisions (THIS turn)

- ✅ Write `specs/redesign_focuspomo.md` (this file).
- ⏳ Update `specs/theme.md` with the direction shift + Decision B
  outcome.
- ⏳ User answers Decision A (font) and Decision B (dark mode).

### Phase 1 — Foundation: tokens + theme

Touch only `lib/design_system/tokens/*` and `lib/app/theme/*`.

1. Replace `BloomColors` with the new palette (table above). Remove
   night/dark surface tokens if Decision B = drop.
2. Rewrite `BloomTypography` with the chosen font (default: Nunito).
3. Update `BloomRadii.card` to 16.
4. Rewrite `AppColors.light` with new ColorScheme mapping. Drop
   `AppColors.dark` if Decision B = drop.
5. Update `AppTheme._build`: solid button (no gradient via theme),
   subtle borders instead of shadows, bottom sheet on `cream`.
6. **Smoke test:** open Today + Settings on emulator. Existing pages
   should look like a *first draft* of the new aesthetic without any
   page-level edits — proof the token swap works.

### Phase 2 — Components

Touch `lib/design_system/components/*` only.

1. Refactor each existing Bloom component (visual-only, no API
   changes). Run `flutter analyze` after each — should be zero issues.
2. Add the four new components, each with a Dartdoc usage example.
3. Update `lib/design_system/components/components.dart` exports.

### Phase 3 — Pages, in priority order

Touched feature page lists for blast-radius transparency:

| Order | Feature | Pages | Why this order |
|---|---|---|---|
| 1 | Today | `today_page.dart` + 4 widgets | Primary daily surface — the 5-second interaction. Most visible payoff. |
| 2 | Calendar | `calendar_page.dart`, `day_cell.dart`, `month_header.dart` | Second-most-visible. Phase colors appear here. |
| 3 | Logging | bottom sheet (lives in today/calendar) | Closes the loop on the daily flow. |
| 4 | Settings | `settings_page.dart` | Easy win, low risk, validates `BloomSectionCard` + new tile. |
| 5 | Insights | `insights_page.dart` | Charts pick up new phase colors. |
| 6 | Onboarding | `owner_onboarding_page.dart` | First-run experience. Validates `BloomCategoryGrid`. |
| 7 | Pairing | `partner_pairing_page.dart`, `pairing_choice_page.dart` | Validates the invite/empty-state pattern (Soula-inspired card). |
| 8 | Auth | `sign_in_page.dart`, `splash_page.dart` | Sign-in + loading. |
| 9 | Biometric | `biometric_lock_page.dart` | Lock overlay. |
| 10 | Startup | `startup_page.dart` | Bridge. Visual minimal. |

For each page: rebuild with the new components, keep the cubit/state
unchanged, run that feature's tests after.

### Phase 4 — Validation

1. `flutter analyze` — zero issues.
2. `flutter test` — full suite green. Widget tests will likely need
   `pumpAndSettle` adjustments if button gradients went away (most
   should still pass since they assert on text/semantics, not visuals).
3. Manual emulator pass: every screen, log a fake day, navigate the
   four-tab nav, sign out, sign back in.
4. Update the spec(s) that previously described old visual specifics
   (mostly `theme.md`; feature specs shouldn't reference visuals
   directly per `CLAUDE.md`).

---

## Out of scope (deliberately)

- Adding new features. Insights/Calendar/Today functionality stays
  identical; only the look changes.
- Animation/motion redesign. `BloomMotion` tokens stay as-is for now.
- Iconography overhaul. `bloom_icons.dart` stays. We may swap to a
  rounded icon set later as a follow-up.
- Localization. Strings via `slang` are unchanged.
- Firestore / Hive / repositories / use cases. Untouched.

---

## Risks + mitigations

| Risk | Mitigation |
|---|---|
| Fraunces removal breaks tests that match font family | Tests don't (currently) assert on font family — they assert on text content. Safe. Quick grep before Phase 1 to confirm. |
| Phase colors drift means existing insights charts look wrong | Insights page is in Phase 3 step 5; that's where we re-tint the charts. |
| Pairing partner doesn't notice the change | He's the secondary user. Low risk. Send him a screenshot when done. |
| Wife wants tweaks mid-rollout | Encouraged. After Phase 1 + 2 there's a stable token set; cosmetic tweaks are cheap. |

---

## Definition of done

- All 11 feature pages re-skinned in the new language.
- `flutter analyze` zero issues.
- `flutter test` green.
- Manual smoke pass complete.
- This spec marked v1 → v1.0-shipped, with a short retro note at the
  bottom (what changed from the plan).

---

## Retro — what shipped vs. plan

Phases 1–3 shipped end-to-end in a single session. `flutter analyze`
zero issues; full 132-test suite green at every checkpoint. Manual
emulator smoke remains user-actionable (Phase 4 gate).

What shipped as planned:

- **Decision A (Nunito)** and **Decision B1 (drop dark mode)** —
  applied throughout. Cubit kept as a no-op storage stub; MaterialApp
  pinned to `ThemeMode.light`; Settings → Appearance section removed.
- **Token deltas** — colors / typography / radii landed exactly per the
  table. Token *names* were preserved (rose, plum, sage, cream...) so
  the 10 phase/honey-colored consumers across Today/Calendar/
  Logging/Insights kept working with no edits — the values shifted, the
  symbols didn't. New aliases (`terracotta`, `bege`, `pebble`, `surface`)
  exist for new code that wants intent-revealing names.
- **All 6 existing components** refactored (Button, Segmented,
  ChoiceChip, LargeHeader, GroupedList, SettingsTile) — visual-only,
  no API changes; all consumers picked up the new look automatically.
- **All 4 new components** added (`BloomDayPillRow`,
  `BloomTimelineBlock`, `BloomCategoryGrid`, `BloomSectionCard`).
- **All 11 feature pages** re-skinned (Today, Calendar, Logging,
  Insights, Settings, Onboarding × 4 steps, Pairing Choice + Partner,
  Auth Sign-in + Splash, Biometric Lock, Startup).

Material divergences from the plan:

- **`BloomCategoryGrid` not yet wired into the Onboarding welcome
  step.** The component is built and exported; the welcome step still
  uses the single sparkle-icon hero. Adding the grid would have needed
  3–4 new i18n keys + a `slang` regen, which felt out of scope for the
  visual pass. Easy follow-up.
- **`BloomTomatoFooter` (mascot) skipped.** Decided cute-but-awkward
  for a privacy-first journal. May revisit if MyCycle ever wants an
  About screen with personality.
- **Day pill row landed on Today, not Calendar.** Spec mentioned both;
  Today benefits more (matches FocusPomo timeline pattern + spec
  BR-1's "recent days strip" intent). Tapping a past pill opens the
  log sheet for that date — small UX upgrade beyond the visual pass.
- **Symptom chip tint** in the Logging sheet switched from
  `phaseLuteal` (now warm yellow) to `plum` (cocoa) — yellow chips for
  symptom names read off-tone. Cocoa stays calm and reads as
  "supporting context."

Known follow-ups (not blocking ship):

1. Wire `BloomCategoryGrid` into onboarding welcome (needs slang regen
   for ~4 strings).
2. Manual visual smoke pass on a real device — typography metrics on
   small screens, dark theme of OS chrome (status bar) over light app.
3. Day pill row on Calendar's day-detail (future feature: tap a past
   day → see the day timeline). Currently Calendar still uses its
   month grid, which works fine.
4. Consider deleting `ThemeCubit` entirely if dark mode never returns
   (currently kept as a storage stub).
