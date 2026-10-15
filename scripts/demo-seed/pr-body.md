## What this changes

Adds `AutomationFreshness.Evaluate`, which suppresses automation runs when the triggering reading is stale (five minutes or older), plus a deterministic-clock test for the exact boundary.

## Known issue (intentional, for the demo)

CI is red: `AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary` fails with `Expected: Suppressed` / `Actual: Triggered`. Find the cause with Code Review, fix it with Copilot CLI, then let Agent Merge drive the PR to ready.

```sh
dotnet test tests/HomeLab.Api.Tests --filter FullyQualifiedName~AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary
```
