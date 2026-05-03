# Logging — Specification

> Status: draft v1 · Owner: @guiga · Last updated: 2026-05-03

Logging is the daily-use loop. The owner records flow, symptoms, mood, and an optional note; the partner adds an optional supportive note. This spec consolidates the logging UX rules — entity contracts and repository methods live in [`cycle.md`](cycle.md), and the Today sheet wiring lives in [`today.md`](today.md).

---

## Entry points

1. **Today screen → "Log today" CTA** (owner only) — opens log sheet for today.
2. **Today screen → recent days strip** (both roles) — opens day detail for the tapped date.
3. **Calendar → tap day** (both roles) — opens day detail.
4. **Calendar → long-press day** (owner only) — opens cycle-edit menu (separate from logging).

All entry points open the same bottom sheet, scoped to the appropriate date.

---

## Owner log sheet (today or any past date)

Single sheet, four sections, one Save button.

| Section | Control | Output |
|---|---|---|
| Flow | 4 chips: spotting / light / medium / heavy | `flow: FlowLevel?` (single select, deselectable) |
| Symptoms | 8 chips: cramps / headache / bloating / fatigue / tenderBreasts / acne / backPain / nausea | `symptoms: Set<SymptomType>` (multi-select) |
| Mood | 5 chips: happy / calm / irritable / sad / anxious | `mood: MoodType?` (single select, deselectable) |
| Note | Multi-line text field, max 500 chars | `ownerNote: String?` |

Below the sheet: optional **cycle controls**:
- "This day starts a new cycle" — adds `LogPeriodStarted` action alongside the upsert.
- "Period ended on this day" — sets `currentCycle.periodEndDate`.

These are not the primary path — most users start cycles implicitly by logging flow on a date with no current cycle (BR-1 in `cycle.md`).

---

## Partner sheet (any date)

Read-only view of the owner-logged data, plus one editable field:

- Flow / symptoms / mood — rendered as filled chips, no interaction
- Owner's note — read-only block
- Partner's note — text field, editable, max 500 chars, debounce 800ms auto-save

---

## Business rules

| # | Rule |
|---|---|
| BR-1 | A log sheet always operates on a specific date. The cubit receives the date at construction. |
| BR-2 | Logging on a date with no current cycle (and no flow logged within the last 21 days) creates a new cycle implicitly when flow is set (per `cycle.md` BR-1). |
| BR-3 | Logging on a future date is rejected — the Save button is disabled and the sheet shows "You can't log the future yet." |
| BR-4 | If all four sections are empty/null, Save deletes the existing DayLog (per `cycle.md` invariant). |
| BR-5 | Partner-note auto-save uses debounce 800ms; visible "Saving…" → "Saved ✓" affordance. |
| BR-6 | Owner Save is explicit (button) — the sheet closes optimistically; failure surfaces a retry toast. |
| BR-7 | If the user opens a sheet for a date >24 months in the past, the cycle controls are hidden (only DayLog editing remains). Editing very old data is intentional friction. |

---

## Validation

- `ownerNote` and `partnerNote`: max 500 chars, trim on save.
- `symptoms`: enforced as `Set` (no duplicates).
- `flow`: cannot coexist with explicit `LogPeriodEnded` for the same day (validation error in cubit).

---

## Optimistic UI rules

- Owner Save: close the sheet immediately, write to Hive optimistically; Firestore set in background (SDK queues if offline). On confirmed remote save, toast "Saved." On hard failure (not offline): revert the Hive value and toast "Couldn't save — retry?" with a retry action that reopens the sheet pre-filled.
- Partner auto-save: never blocks UI. Failure shows a small "couldn't save" indicator next to the field; field stays editable.

---

## Edge cases

1. **Same day edited twice quickly** — second save overwrites first. Last-write-wins.
2. **Owner opens a date that's currently in another open log sheet on another device** — both edit, last write wins. Acceptable.
3. **Network drop mid-save** — Firestore SDK queues the write and syncs on reconnect; the Hive value remains until reverted on hard failure.
4. **Locale change mid-edit** — chip labels re-render, selections preserved.
5. **Date is the start of a closed cycle** — sheet shows existing data; cycle controls allow `Edit cycle dates` shortcut.

---

## Test plan

- Each business rule (BR-1 through BR-7) has at least one named test.
- Optimistic UI: success and failure paths.
- Validation: 500-char trim, future-date rejection.
- Partner debounce: writes coalesce within 800ms.
