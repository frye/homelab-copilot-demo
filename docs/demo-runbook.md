# A Day in the Life of a Developer with Copilot

## Demo setup and opening state

Labwatch is a private, simulated home-lab dashboard. It shows a rack temperature sensor, CO₂ sensor, idle 3D printer, and smart plug, plus two automation previews. API actions never contact physical hardware. Run the API at `http://localhost:5071` and the Blazor app at `http://localhost:5072` using the commands in the README.

Upstream: [frye/homelab-copilot-demo](https://github.com/frye/homelab-copilot-demo) (private template). `main` is the green baseline and contains everything needed to recreate the starting state. Attendees follow [the attendee guide](attendee-guide.md): they create their own repo from the template and run `scripts/setup-demo.sh`, so each person gets their own red PR and issues.

`scripts/setup-demo.sh` creates:

| Artifact | Surface |
|---|---|
| PR **Guard automation runs against stale telemetry** from `demo/stale-telemetry-boundary` (intentionally red) | Code Review → CLI → Agent Merge |
| Issue **Add device telemetry history** | Cloud agent |
| Issue **Add automation dry-run explanations** | Plan (auto-started from the issue) → Autopilot |

The PR adds a deterministic-clock boundary test that fails when a reading exactly five minutes old is treated as fresh. Pass `--request-review` to also request a Copilot code review up front, as a presenter backup in case review is slow live.

## 90-minute run of show

Work through the rows in order. Each row lists the features to call out, the presenter steps with copy-ready prompts and commands in the order you use them, and the checkpoint to confirm before moving on.

<table>
<thead>
<tr>
<th width="12%">Time &amp; surface</th>
<th width="68%">Presenter guide: features, steps and prompts</th>
<th width="20%">Checkpoint</th>
</tr>
</thead>
<tbody>

<tr>
<td><strong>0–8</strong><br>Copilot app<br><em>Orientation</em></td>
<td>

**Features to highlight**

- Adding a repo as a project; each session gets its own isolated worktree and branch.
- Repository custom instructions (`.github/copilot-instructions.md`) shape every answer: simulated hardware only, previews only, run tests.
- Asking questions about the codebase and getting answers that cite files.
- Previewing the running dashboard next to the chat.

**Presenter steps**

1. Open the attendee's repo as a project and start a session.
2. Show the running dashboard at `http://localhost:5072`.
3. Ask:

```text
Explain how the API and web projects fit together.
Does the dashboard's Preview button call the API?
Can anything here control real hardware?
```

4. Point out the discovery: the dashboard is static and doesn't call the API yet. That makes a good follow-up task.

</td>
<td>Attendees can name the API and web projects, find the seed data (<code>HomeLabStore.cs</code>), and see that the UI is still static.</td>
</tr>

<tr>
<td><strong>8–20</strong><br>Code Review<br><em>Find the bug</em></td>
<td>

**Features to highlight**

- Requesting Copilot as a PR reviewer from **Reviewers**.
- Inline review comments tied to specific lines, with suggested changes.
- Pairing review findings with CI evidence, such as the failing check log.
- What makes a review actionable: an exact condition, the code, and a test that proves it.

**Presenter steps**

1. Open the PR **Guard automation runs against stale telemetry** and request **Copilot** under **Reviewers** (skip if `--request-review` already did).
2. While it runs, open the failing `build-and-test` log and show the single failing test.
3. To steer the discussion, ask Copilot on the PR:

```text
Review this PR for correctness at the exact five-minute
freshness boundary. Cite the code and test that demonstrate
the issue.
```

4. Walk through the comment on `age > TimeSpan.FromMinutes(5)` in `AutomationFreshness.cs`. **Leave the thread unresolved** for Agent Merge.

</td>
<td>One review thread points to the exact five-minute condition; CI shows one failing test.</td>
</tr>

<tr>
<td><strong>20–35</strong><br>Cloud agent<br><em>Delegate parallel work</em></td>
<td>

**Features to highlight**

- Assigning an issue to Copilot, or starting a cloud session from the Copilot app.
- Work runs asynchronously in the cloud while you keep going locally.
- Draft PR plus session logs to follow progress.
- Scoping the agent with prompt boundaries and repository instructions.

**Presenter steps**

1. Open the issue **Add device telemetry history**.
2. Assign it to Copilot (or start it as a cloud session from the Copilot app) with:

```text
Implement device telemetry history with recent timestamped
readings, following current API/UI conventions. Keep changes
within readings API/service and device-detail UI; add focused
tests.
```

3. Show the draft PR and session log once it appears, then move on without waiting.

</td>
<td>The agent has started and opened a draft PR scoped to the readings API/service and device-detail UI. If it's slow, show <code>reference/<wbr>telemetry-history</code> later.</td>
</tr>

<tr>
<td><strong>35–45</strong><br>Copilot CLI<br><em>Fix the red PR</em></td>
<td>

**Features to highlight**

- Copilot as an agent in the terminal, working in a local checkout.
- Approving tool and command permissions as it runs.
- Tracing a failing test to a root cause and making the smallest fix.
- Running only the relevant test, then committing and pushing yourself.

**Presenter steps**

1. Check out the PR branch and start the CLI:

```sh
git fetch origin
git switch demo/stale-telemetry-boundary
copilot
```

2. Ask:

```text
Explain why
`AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary`
fails, make the smallest fix, and run only that test.
```

3. Confirm the one-character fix (`>` becomes `>=`), then run each command in turn.

Verify the fix:

```sh
dotnet test tests/HomeLab.Api.Tests \
  --filter \
  FullyQualifiedName~SuppressesReadingAtFiveMinuteBoundary
```

Commit:

```sh
git commit -am \
  "Treat readings exactly five minutes old as stale"
```

Push:

```sh
git push
```

</td>
<td>The targeted test passes locally and the PR check reruns green.</td>
</tr>

<tr>
<td><strong>45–65</strong><br>Copilot app<br><em>Plan from an issue</em></td>
<td>

**Features to highlight**

- Starting a session from an issue (**Add automation dry-run explanations**) automatically kicks off the plan agent with the issue as context. No prompt needed.
- Research built into planning: the agent reads the code and cites the files and test patterns it relies on before proposing changes.
- Clarifying questions with suggested answers, asked one at a time.
- A reviewable `plan.md` with an approach, todos, files in scope, and acceptance tests.
- Steering the plan with feedback so it doesn't conflict with the Cloud agent's telemetry-history work.
- The human approves the plan before any code changes.

**Presenter steps**

1. In the Copilot app, start a session from the issue **Add automation dry-run explanations**. Point out that planning starts on its own.
2. While it works, narrate what the agent is doing: reading the automation and readings code, finding test patterns, and noting constraints from `.github/copilot-instructions.md` (previews only, no hardware).
3. Answer its clarifying questions. Prefer the recommended choices unless you want to show steering.
4. Open the plan and walk through it: the approach, the files in scope, the acceptance tests, and preview-only semantics in both the API and the UI.
5. If the plan touches telemetry-history files, use **Suggest changes** to push back and ask it to stay out of them.
6. Stop at the approval prompt. Don't approve yet.

> [!TIP]
> The automatic planning is optional. To drive it by hand, stop the initial run and prompt the session yourself, for example:
>
> ```text
> Plan an automation dry-run explanation with trigger, proposed
> action, and explicit preview-only semantics. List files and
> acceptance tests before implementation.
> ```

</td>
<td>The plan cites existing code, names its files and tests, stays out of telemetry-history code, and is waiting for approval. No files have changed.</td>
</tr>

<tr>
<td><strong>65–78</strong><br>Copilot app<br><em>Autopilot</em></td>
<td>

**Features to highlight**

- Approving a plan to run in **Autopilot**.
- Autonomous edits and test runs that follow repository instructions (`dotnet test HomeLab.sln`).
- Reviewing the resulting diff before accepting it.
- Preview-only semantics visible in both the API and the UI.

**Presenter steps**

1. Approve the plan with **Autopilot**. If the agent needs a nudge, use:

```text
Implement the approved dry-run explanation plan, add focused
tests, and report the resulting diff.
```

2. When it finishes, review the diff and run:

```sh
dotnet test HomeLab.sln
```

</td>
<td>Tests pass and the automation preview explains its trigger and action in plain language. If it's delayed, show <code>reference/<wbr>automation-dry-run</code>.</td>
</tr>

<tr>
<td><strong>78–90</strong><br>Agent Merge<br><em>Ship it</em></td>
<td>

**Features to highlight**

- Turning on Agent Merge for a PR from the Copilot app.
- Agent Merge actions: address review comments, fix failing CI, and resolve merge conflicts.
- Keeping **merge PR** off so the human makes the final merge decision.
- CI/CD on `main`: CI plus the **Build demo artifacts** workflow publishing `homelab-demo`.

**Presenter steps**

1. Open the stale-telemetry PR in the Copilot app.
2. Turn on **Agent Merge** with address reviews, fix CI, and resolve conflicts enabled. Leave **merge PR** off.
3. Watch it reply to and resolve the review thread from the Code Review step and confirm checks are green.
4. Merge manually (the attendee's call), then show the `homelab-demo` artifact on `main`.

</td>
<td>The review thread is resolved, required checks pass, and the PR shows as ready to merge. After merge, <code>main</code> publishes artifacts.</td>
</tr>

</tbody>
</table>

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
