# A Day in the Life of a Developer with Copilot

## Demo setup and opening state

Labwatch is a private, simulated home-lab dashboard. It shows a rack temperature sensor, CO₂ sensor, idle 3D printer, and smart plug, plus two automation previews. API actions never contact physical hardware. Run the API at `http://localhost:5071` and the Blazor app at `http://localhost:5072` using the commands in the README.

Upstream: [frye/homelab-copilot-demo](https://github.com/frye/homelab-copilot-demo) (private template). `main` is the green baseline and contains everything needed to recreate the starting state. Attendees follow [the attendee guide](attendee-guide.md): they create their own repo from the template and run `scripts/setup-demo.sh`, so each person gets their own red PR and issues.

`scripts/setup-demo.sh` creates:

| Artifact | Surface |
|---|---|
| PR **Guard automation runs against stale telemetry** from `demo/stale-telemetry-boundary` (intentionally red) | Code Review → CLI → Agent Merge |
| Issue **Add device telemetry history** | Cloud agent |
| Issue **Add automation dry-run explanations** | Research → Plan → Autopilot |

The PR adds a deterministic-clock boundary test that fails when a reading exactly five minutes old is treated as fresh. Pass `--request-review` to also request a Copilot code review up front, as a presenter backup in case review is slow live.

## 90-minute run of show

| Time | Surface | Talk track / hands-on | Checkpoint |
|---|---|---|---|
| 0–8 | Copilot app | Open this repo and dashboard. Ask Copilot to explain the API/UI split and whether the dashboard calls the API. | Attendees can orient themselves in the solution, see the running dashboard, and notice the UI is still static. |
| 8–20 | Code Review | Review the stale-telemetry PR. Read the boundary finding, inspect the test and evaluator, and discuss what evidence makes a review actionable. | One review thread points to the exact five-minute condition; CI shows one failing test. |
| 20–35 | Cloud agent | Start the telemetry-history issue in Cloud agent. Work continues while the session moves on. | Agent works only in readings API/service and device-detail UI; if slow, show the prepared checkpoint diff. |
| 35–45 | Copilot CLI | Ask Copilot CLI to trace the failing test and propose a fix. Run `dotnet test tests/HomeLab.Api.Tests --filter FullyQualifiedName~AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary`; fix the boundary to suppress `age >= five minutes`, rerun, commit/push. | Targeted test passes; PR check reruns. |
| 45–55 | Research | Research the existing telemetry and automation patterns; collect constraints and test locations before implementing. | A concise, source-grounded brief guides the next task. |
| 55–65 | Plan | Plan the automation dry-run issue. Confirm trigger/action explanation, preview-only behavior, tests, and files in scope. | A bounded plan avoids conflicts with the telemetry-history task. |
| 65–78 | Autopilot | Execute the approved plan, run targeted tests, and inspect the diff. | Automation preview has an understandable trigger/action result; if delayed, use the prepared reference diff. |
| 78–90 | Agent Merge | Enable Agent Merge on the fixed PR; allow it to address the outstanding review thread/checks. Review readiness and leave the final merge decision to the attendee. | Review thread is handled, required checks pass, and merge readiness is visible. After attendee merge, `main` publishes artifacts. |

### Suggested prompts

**Copilot app**

```text
Explain how the API and web projects fit together. Does the dashboard's Preview button call the API? Can anything here control real hardware?
```

Expected discovery: the dashboard is static and doesn't call the API yet. That makes a good follow-up task.

**Code Review**

```text
Review this PR for correctness at the exact five-minute freshness boundary. Cite the code and test that demonstrate the issue.
```

**Cloud agent**

```text
Implement device telemetry history with recent timestamped readings, following current API/UI conventions. Keep changes within readings API/service and device-detail UI; add focused tests.
```

**CLI**

```text
Explain why `AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary` fails, make the smallest fix, and run only that test.
```

**Research**

```text
Find how this repo models device readings and automation previews. Cite the files and identify relevant test patterns; do not change files.
```

**Plan**

```text
Plan an automation dry-run explanation with trigger, proposed action, and explicit preview-only semantics. List files and acceptance tests before implementation.
```

**Autopilot**

```text
Implement the approved dry-run explanation plan, add focused tests, and report the resulting diff.
```

## CI/CD

`.github/workflows/ci.yml` restores/builds/tests on PRs and pushes to `main`. `.github/workflows/deliver.yml` publishes API and web output as a downloadable `homelab-demo` artifact on `main`. No cloud credentials are needed. The intentionally red check is a single deterministic test failure in the demo PR, not a broken workflow or failure on `main`.

## Preflight and contingency

Before the session:
- Confirm attendees can see the template. A private template is only usable by people with access, so make it public or add attendees.
- Confirm Actions run in a fresh copy, and that Code Review, Cloud agent, and Agent Merge are available on the accounts in use.
- Do a full rehearsal in a fresh copy. Push the Cloud agent and Autopilot results to `reference/telemetry-history` and `reference/automation-dry-run` branches to use as fallbacks. These aren't pre-built.
- Agent Merge is not pre-enabled.

If Cloud agent is unavailable or still running at its checkpoint, show the rehearsal reference branch and leave its issue open. If Code Review is unavailable, use Copilot CLI to inspect the same diff/test; do not claim a Code Review ran. If Agent Merge is unavailable, walk through the checks and thread manually and show readiness without claiming automation. Use the rehearsal Autopilot branch if its task is still running.

## Safe reset

Never reset or rewrite the template's `main`. To start fresh, create a new repository from the template and run `scripts/setup-demo.sh` in a clone. Each run is a clean, identical starting state, and earlier copies stay untouched for reference.
