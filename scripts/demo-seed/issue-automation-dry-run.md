## Goal
Show what an automation would do before any action is simulated. (Plan → Autopilot exercise.)

## Scope
- Add a dry-run preview presenting the trigger, proposed action, and simulated outcome.
- Keep changes to automation logic and its UI; do not touch telemetry-history endpoints/views.

## Acceptance criteria
- Preview explains trigger and action in plain language.
- Result is explicitly marked simulated and never controls physical hardware.
- Focused tests for the preview result.
