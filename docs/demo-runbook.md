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

Start in VS Code with read-only code exploration. Then switch to GitHub in the browser for Code Review and Cloud agent delegation. Introduce the GitHub Copilot app at **Plan from an issue**, after the CLI exercise.

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
<td><strong>0–8</strong><br>VS Code<br><em>Orientation</em></td>
<td>

**Features to highlight**

- Copilot Chat in VS Code: use **Ask** for code questions without requesting edits.
- Adding files or a selection as chat context so Copilot can answer about the code you're showing.
- Repository custom instructions (`.github/copilot-instructions.md`): simulated hardware only, previews only, run tests.
- Inline chat: ask about a selected block without leaving the editor.
- Following file references in an answer and checking them against the source.

**Presenter steps**

1. In VS Code, use **File > Open Folder** to open the cloned repository on `main`. Open Copilot Chat and select **Ask**.
2. Open `.github/copilot-instructions.md` and point out the preview-only constraint.
3. Add `src/HomeLab.Api/Program.cs`, `src/HomeLab.Api/HomeLabStore.cs`, and `src/HomeLab.Web/Components/Pages/Home.razor` as chat context using **Add Context**. Ask:

```text
Explain how the API and web projects fit together.
Does the dashboard's Preview button call the API?
Can anything here control real hardware?
Cite the files that support your answer. Do not change any files.
```

4. Follow the answer's file references. Point out that the dashboard uses hard-coded data and its Preview button doesn't call the API yet.
5. In `Home.razor`, select the `Preview` method, open **Inline Chat** from the editor context menu, and ask:

```text
Explain what this selected method does and whether it calls
the API or controls hardware. Explain only; do not edit code.
```

6. Read the explanation, then close inline chat. Discard any proposed edits; keep the working tree unchanged and leave the red PR for the CLI exercise.
7. Switch to the browser, show the running dashboard at `http://localhost:5072`, then open the repository's PR for Code Review. The GitHub Copilot app comes later.

</td>
<td>Attendees can name the API and web projects, find the seed data (<code>HomeLabStore.cs</code>), and explain the local Preview method using Chat and inline chat. No files have changed.</td>
</tr>

<tr>
<td><strong>8–20</strong><br>GitHub in the browser<br><em>Code Review: find the bug</em></td>
<td>

**Features to highlight**

- Requesting Copilot as a PR reviewer from **Reviewers**.
- Inline review comments tied to specific lines, with suggested changes.
- Pairing review findings with CI evidence, such as the failing check log.
- What makes a review actionable: an exact condition, the code, and a test that proves it.

**Presenter steps**

1. In GitHub in the browser, open the PR **Guard automation runs against stale telemetry** and request **Copilot** under **Reviewers** (skip if `--request-review` already did).
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
<td><strong>20–35</strong><br>GitHub in the browser<br><em>Cloud agent: delegate parallel work</em></td>
<td>

**Features to highlight**

- Assigning an issue to Copilot from GitHub in the browser.
- Work runs asynchronously in the cloud while you keep going locally.
- Draft PR plus session logs to follow progress.
- Scoping the agent with prompt boundaries and repository instructions.

**Presenter steps**

1. Stay in the browser and open the issue **Add device telemetry history**.
2. Assign it to Copilot with:

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

- Adding the repository as a project in the GitHub Copilot app; local sessions use isolated worktrees and branches.
- Starting a session from an issue (**Add automation dry-run explanations**) automatically kicks off the plan agent with the issue as context. No prompt needed.
- Research built into planning: the agent reads the code and cites the files and test patterns it relies on before proposing changes.
- Clarifying questions with suggested answers, asked one at a time.
- A reviewable `plan.md` with an approach, todos, files in scope, and acceptance tests.
- Steering the plan with feedback so it doesn't conflict with the Cloud agent's telemetry-history work.
- The human approves the plan before any code changes.

**Presenter steps**

1. Open the GitHub Copilot app and add the repository as a project. Start a session from the issue **Add automation dry-run explanations**. Point out that planning starts on its own.
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
<td><strong>Parallel</strong><br>Copilot app<br><em>Multitask</em></td>
<td>

Run this alongside the **Plan from an issue** and **Autopilot** rows. Start the sessions while the plan agent researches, then check on them between steps.

**Features to highlight**

- Several sessions running at once, each in its own worktree and branch.
- Session status at a glance (working, waiting for input, done) and switching between sessions without losing context.
- Each prompt is self-contained and starts from `main`, so no session waits on another.
- The sessions overlap on purpose (`Program.cs`, `HomeLabStore.cs`, `MainLayout.razor`, `app.css`, `HomeLab.sln`). Merge conflicts are expected and are a good lead-in to Agent Merge.

**Presenter steps**

1. In the Copilot app, start a new session from `main` for each prompt below and paste the prompt. Pick **Autopilot** if you don't want to babysit them.
2. Switch back to the plan session and keep going with the main flow.
3. Between steps, open the session list to show progress, then open one finished session to review its diff.
4. To demo the simulator, run the API, then in two terminals in that session's worktree:

```sh
dotnet run --project tools/HomeLab.Simulator -- emit
```

```sh
dotnet run --project tools/HomeLab.Simulator -- fail printer-power-off
```

Clear it again with `clear`.

**1. Live dashboard: bind the Web UI to the API**

```text
Bind the Blazor dashboard (src/HomeLab.Web) to the existing API
(src/HomeLab.Api) instead of hard-coded markup. Add a typed
HttpClient whose base URL comes from config (ApiBaseUrl, default
http://localhost:5071). Render devices, the latest reading per
device, and automations from GET /api/devices, /api/readings and
/api/automations, refreshing every 5 seconds. Make the Preview
buttons call POST /api/automations/{id}/preview and show the API's
result text. Keep the current look. Show a clear "API unreachable"
state instead of crashing. Both projects must still run on their
own. Add focused tests.

Decisions already made (do not ask about these again):

- Refresh failures: If a refresh fails, keep the last successful
  data and show an "API unreachable" banner. If the dashboard has
  never loaded successfully, show an unavailable state. Do not show
  made-up placeholder data.
- Unsupported markup details: The API does not provide the current
  trend claims ("↑ …") or last-print details. Replace them with
  API-backed timestamps and reading history. Keep the existing
  layout, colors, card classes and responsive styling.
- Previews remain hypothetical. Keep the visible preview-only,
  no-hardware wording, and do not add hardware actuation.
- Change only the Web project and tests. Do not change API contracts
  or seed data, and do not add a shared contracts project.

Execution instructions:

- Implement the change fully. Do not stop after writing a plan, and
  do not ask for confirmation before starting.
- Replace the Web project's local preview generator with API calls,
  and update its tests to match.
- Use deterministic clocks (TimeProvider) and a fake
  HttpMessageHandler in tests. Cover routes and methods, the
  configured and default base URL, latest-reading selection, empty
  and missing data, HTTP, network and invalid-response failures,
  keeping data after a failure and recovering afterward, preview
  result text and preview errors (including 404), and the 5-second
  polling cycle and its cancellation.
- Update the README with ApiBaseUrl configuration, the refresh
  behavior, and how to run each project independently.
- Run `dotnet test HomeLab.sln` and make sure it passes. Commit the
  work on the current branch.
```

**2. Telemetry simulator CLI with failure injection**

```text
Add a console app tools/HomeLab.Simulator (.NET 9, add it to
HomeLab.sln with `dotnet sln add`) that talks only to the API over
HTTP (default http://localhost:5071). It must not reference the
HomeLab.Api project or touch its store directly. `--api <url>` works
on every command.

Commands:

- emit [--api URL] [--seed INT] [--min SECONDS] [--max SECONDS]:
  send generated readings for the four seeded devices at random
  intervals until Ctrl+C. --min/--max are interval bounds in seconds
  (doubles, defaults 2 and 10; require 0 < min <= max). Default seed
  is 42. Fetch /api/devices once at startup and identify devices by
  Kind ("Temperature sensor", "CO₂ sensor", "3D printer", "Smart
  plug"). Report a missing or ambiguous device as an error. Before
  each tick, GET /api/faults and apply them. Handle Ctrl+C
  gracefully: cancel the delay and exit 0.
- fail <fault>: inject a simulated fault. Valid faults:
  printer-power-off, rack-overheat, co2-sensor-offline.
- clear [fault]: clear one fault, or all faults if none is given.
- status: list active faults with their activation times.

Every command prints a banner saying the data is simulated and no
physical hardware is contacted. Invalid arguments and HTTP or
network failures return a nonzero exit code with an actionable
message. If a reading POST returns 409 because a fault became active
between GET and POST, print an explicit "skipped due to active
fault" line and continue; the next tick refreshes the fault list.
Any other emit failure exits 1.

Generation (seeded Random; timestamps from an injected TimeProvider;
delays via Task.Delay(TimeSpan, TimeProvider, CancellationToken)):

- Rack "Temperature" °C: normally 26.0–29.0 (1 decimal). During
  rack-overheat, add 0.8–1.6 to the previous value on every tick.
  After the fault clears, return to the normal range.
- Air "CO₂" ppm: integer 650–950. Send nothing while
  co2-sensor-offline is active.
- Printer "Print progress" %: 0 (Idle). Send nothing while
  printer-power-off is active.
- Plug "Power draw" W: standby 2.5–4.5 (1 decimal). Send exactly 0
  while printer-power-off is active.
- Each tick's delay is min + random × (max − min).

API changes (src/HomeLab.Api):

- HomeLabStore: keep the seed data byte-identical. Store private
  List-based devices and readings plus a fault dictionary behind a
  single lock. The Devices, Readings, and Faults properties return
  snapshot arrays. Automations stay immutable and preview behavior
  is unchanged. Never hold the lock across awaits. History is
  append-only and in memory; faults reset when the API restarts.
- AppendReading returns Accepted, UnknownDevice, Invalid (blank
  metric or unit, or a non-finite value), or BlockedByFault. Block
  printer readings and nonzero plug readings during
  printer-power-off, and air-sensor readings during
  co2-sensor-offline, atomically under the lock. An accepted reading
  sets the device's LastSeen to the clock's now and does not change
  Status.
- Faults are idempotent and timestamped with the TimeProvider.
  Activating printer-power-off immediately sets the printer and plug
  Status to "Offline" and appends a 0 W plug reading. Activating
  co2-sensor-offline sets the air sensor to "Offline". rack-overheat
  changes no status and only affects generation. Clearing a fault
  restores the affected devices' seeded statuses and keeps history.
- Endpoints (keep the existing GET responses as plain arrays):
    - POST /api/readings, body { deviceId, metric, value, unit,
      recordedAt }: 201 with { reading, isSimulated: true, message
      }. Unknown device: 404. Invalid: 400. Blocked by fault: 409.
    - GET /api/faults: { isSimulated: true, message, faults: [{
      name, description, activatedAt }] }.
    - POST /api/faults, body { "fault": "<name>" }: 200 with the
      envelope plus the fault. Unknown name: 400 listing the valid
      names.
    - DELETE /api/faults/{fault}: clears one fault and returns 200
      with the envelope plus `cleared: [...]`; the list is empty if
      the fault wasn't active. Unknown name: 400.
    - DELETE /api/faults: clears all faults and returns 200 with
      `cleared: [...]`.
    - message = "Simulated state only; no physical hardware was
      contacted." Every new endpoint response, including errors,
      carries isSimulated and message.

Tests (tests/HomeLab.Api.Tests; reference the simulator project;
keep the existing tests passing unchanged):

- Add packages Microsoft.AspNetCore.Mvc.Testing 9.0.x and
  Microsoft.Extensions.TimeProvider.Testing 9.x. Make the
  simulator's types public in namespace HomeLab.Simulator.
- Store: append validation, snapshot isolation, concurrent appends,
  clock-based LastSeen and fault timestamps, idempotency, immediate
  fault effects, clearing one or all faults, and retained history.
- Endpoints: use WebApplicationFactory<Program> with a
  FakeTimeProvider.
- Simulator: seeded determinism, interval bounds, fault-aware
  generation, rack temperature climbing and resetting, parser
  errors, request paths and payloads via a fake HttpMessageHandler,
  the 409 path, and cancellation.

Out of scope: hardware integrations, Web UI changes, persistent
storage, and changes to automation previews.

Update the README with simulator usage and examples for every
command and option, the new endpoint contracts, fault effects,
in-memory lifetime, and the no-hardware guarantee. Run `dotnet test
HomeLab.sln`. Then smoke-test locally: start the API on 5071 and run
a short emit plus fail, status, and clear. Also confirm that POST
/api/readings rejects an unknown device. Stop any background
processes afterward.
```

**3. Rack threshold settings page**

```text
Add configurable alert thresholds: rack temperature warning/critical
(°C) and CO₂ warning/critical (ppm), seeded with 28/32 °C and
1000/1500 ppm.

API: add GET and PUT /api/settings/thresholds, stored in memory.
Settings reset to the seeded defaults when the API restarts.
Validation rules:

- Rack temperature: allowed range is 0–100 °C, inclusive.
- CO₂: allowed range is 400–10,000 ppm, inclusive.
- For each metric, warning must be strictly less than critical.
  Equal values are invalid.
- Return 400 with field errors.

Web: add a /settings page with a form that loads and saves through
the API. Read the API base URL from config, with a default of
http://localhost:5071. The form must show validation errors inline
and confirm successful saves. Add navigation between the dashboard
and settings. State on the page that thresholds only describe when
previews would fire and never control hardware.

Dashboard alignment: the dashboard currently uses fixed 28 °C text
and builds previews locally without calling the API. Update it so
the dashboard rack trigger and preview text, and the API rack
preview text, use the saved rack warning threshold. If the API is
unavailable, the dashboard uses the seeded defaults and shows a
visible notice. Do not add new automations, live alert evaluation,
CO₂ automations, or persistence across restarts.

Tests: add API tests for validation.
```

**4. Alerts feed**

```text
Add an alerts feed to the HomeLab demo.

API (src/HomeLab.Api):

- GET /api/alerts builds alerts from the current readings and device
  status. For each device and metric, use only the latest reading
  (by RecordedAt). Ignore older readings that crossed a threshold.
    - Rack temperature >= 28 °C is a warning. At >= 32 °C, produce
      one critical alert instead of the warning. This rule applies
      only to the seeded rack temperature sensor (by its stable
      device id), not to every Temperature reading.
    - CO₂ >= 1000 ppm is a warning.
    - A device whose status is anything other than Healthy, Idle or
      On gets a warning.
- Each alert has: a stable id (based on device + condition, not on
  the value or severity), severity, device, message, timestamp,
  acknowledged flag, and an explicit informational-only indicator.
- Sort critical alerts before warnings, with a deterministic
  tie-breaker.
- The timestamp is when the alert was first detected, taken from the
  injected TimeProvider. It stays the same on repeat GETs.
- POST /api/alerts/{id}/ack marks an alert acknowledged, in memory
  only (thread-safe). Repeating it on an active alert is harmless
  and returns that alert. An unknown or resolved id returns 404.
  Acknowledging never changes readings, devices or automations.

Acknowledgment behavior (decided, don't ask):

- Acknowledged alerts stay in the GET results, marked acknowledged,
  while their condition is still active.
- When an evaluation finds the condition has cleared, remove its
  state. If the condition comes back later, it's a new episode:
  unacknowledged, with a new timestamp.

Web (src/HomeLab.Web), decided, don't ask:

- The Web app must keep running without the API. The API base URL is
  configured via HomeLabApi:BaseUrl (env var HomeLabApi__BaseUrl).
  It is optional and unset by default. If set, the alerts page calls
  the API only. If unset, the page runs in a clearly labeled
  standalone demo mode that uses the same shared alert rules and
  seed data. If it is set but not a valid http(s) URL, show a
  configuration error instead of switching to standalone mode.
- If the API is configured and a call fails, show an error with a
  retry option. Never fall back to local data silently.
- Put the shared telemetry models, seed data and alert evaluator in
  a small shared library (e.g. src/HomeLab.Core) referenced by both
  apps, and add it to HomeLab.sln. Keep the existing API endpoints
  and automation-preview behavior unchanged.
- Add an interactive /alerts page with alerts grouped/ordered by
  severity. Show severity, device, message, timestamp and
  acknowledgment state, with Acknowledge buttons that are disabled
  once acknowledged or while pending. Include loading, empty and
  error states, a refresh button, an indicator of the source mode,
  and a link back to the dashboard.
- Show clearly on the page that alerts are informational only and
  never trigger hardware.
- Link to /alerts from the dashboard without changing the existing
  cards.

Tests (deterministic, fixed clock / fake TimeProvider):

- The seed data produces exactly one warning, from the 28.4 °C rack
  reading.
- Cover: threshold boundaries; critical replacing warning;
  latest-reading selection; CO₂ and all status rules; stable ids and
  timestamps; repeated ack; unknown/resolved ids; reset when a
  condition clears and recurs (use synthetic telemetry snapshots,
  not new mutation endpoints).
- Add API endpoint tests with WebApplicationFactory and an
  overridden TimeProvider.
- Add Web alerts-service tests for local mode, HTTP mode and failure
  handling.

Also update the README: endpoints, thresholds, ack semantics,
in-memory lifecycle, API vs standalone configuration, and the
informational-only note. No persistence, alert history, background
polling or hardware integrations.

Run `dotnet test HomeLab.sln`, make sure both apps still start on
their own, and smoke-test GET/ack and the page.
```

**5. Light/dark theme toggle**

```text
Add a light/dark theme toggle to the Blazor UI in src/HomeLab.Web
only. Implement it now. Don't stop at a plan or ask clarifying
questions, because the decisions are below.

Scope and constraints:

- Only edit files under src/HomeLab.Web: wwwroot/app.css,
  Components/App.razor, Components/Layout/MainLayout.razor,
  Components/Layout/MainLayout.razor.css, and one new
  wwwroot/theme.js.
- Don't change src/HomeLab.Api, the tests, Program.cs,
  Components/Pages/*.razor (page content), seed data, or render
  modes. No new NuGet or npm packages.
- Keep the API and Web projects independently runnable.

Colors and palettes:

- Move every hard-coded color in wwwroot/app.css into CSS custom
  properties. This covers the hex values, the body radial-gradient,
  the card/button linear-gradients, the sparkline gradient and the
  border colors in the @media blocks.
- Use semantic names with a --color- prefix (for example --color-bg,
  --color-surface, --color-border, --color-text, --color-text-muted,
  --color-accent, --color-warm). Reuse one variable for
  near-duplicate values only if the dark theme still looks the same.
- Define the current values as the dark palette on :root and
  :root[data-theme="dark"], and the light palette on
  :root[data-theme="light"]. The dark theme must render exactly as
  it does today.
- Write a matching light palette with the same green, blue, violet
  and amber accent families, adjusted for a light background. Body
  text and important text must reach at least 4.5:1 contrast (WCAG
  AA). Muted/mono labels must reach at least 4.5:1 too, because
  they're small (8–11px).
- Set color-scheme: dark or light for each theme.
- Keep app.css's minified one-line style. Leave the #blazor-error-ui
  styles as they are.

Toggle:

- Put a native <button type="button"> in MainLayout.razor above
  @Body, fixed in the top-right corner. Style it in
  MainLayout.razor.css with the theme variables.
- It needs a visible text label (for example "☀ Light" / "☾ Dark",
  showing the current theme) and aria-pressed="true" when dark is
  active. Use one stable aria-label of "Dark theme" so the label and
  the pressed state don't contradict each other.
- Give it a clear :focus-visible outline and make it
  keyboard-operable.
- The layout uses static SSR, so the toggle can't depend on Blazor
  interactivity. Wire it up with plain JS in wwwroot/theme.js and
  use event delegation on document, so it keeps working after Blazor
  enhanced navigation re-renders the layout. Update the label and
  aria-pressed when the page loads, when the button is clicked, and
  on Blazor's "enhancedload" event.

Persistence and avoiding a flash on load:

- Store the choice in localStorage under the key "homelab-theme" as
  "light" or "dark". Wrap storage access in try/catch.
- With no saved choice, follow prefers-color-scheme, and keep
  following live OS changes until the user picks a theme explicitly.
  There's no "reset to system" option.
- Put a small inline <script> in the <head> of App.razor, before the
  stylesheet links. It sets document.documentElement.dataset.theme
  from localStorage, falling back to matchMedia, so the correct
  theme applies before the first paint. Load theme.js with a normal
  script tag via @Assets["theme.js"] before blazor.web.js.
- Don't add theme transitions that would cause visible animation on
  load.

Verification:

- Run `dotnet build HomeLab.sln` and `dotnet test HomeLab.sln`. Both
  must pass. No new tests are required, since there's no Web test
  project.
- Run the Web app, then curl the page to confirm the inline head
  script, the button with aria-pressed and a visible label, and
  theme.js are in the HTML.
- If a browser canvas is available, check both themes visually and
  confirm a reload keeps the saved choice.
- Commit to the current branch.
```

</td>
<td>Five sessions are running on their own branches and none is waiting on another. At least one has finished with passing tests by the Autopilot checkpoint.</td>
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
3. Watch it reply to and resolve the review thread from the Code Review step. Inspect the fix before accepting the resolution. Confirm the latest commit passes required CI and any optional security gates enabled during preflight.
4. Confirm Copilot's review has finished, all review threads are resolved, and no required check is pending or failing. If optional GHAS merge gates were enabled, confirm those pass too. Merge manually without bypassing the rules (the attendee's call), then show the `homelab-demo` artifact on `main`.

</td>
<td>Copilot's review is complete, all review threads are resolved, required CI (and any optional security gates enabled) passes, and the PR shows as ready to merge without bypass. After merge, <code>main</code> publishes artifacts.</td>
</tr>

</tbody>
</table>

## CI/CD

`.github/workflows/ci.yml` restores/builds/tests on PRs and pushes to `main`. `.github/workflows/deliver.yml` publishes API and web output as a downloadable `homelab-demo` artifact on `main`. No cloud credentials are needed. The intentionally red check is a single deterministic test failure in the demo PR, not a broken workflow or failure on `main`.

## Preflight and contingency

Before the session:
- Confirm attendees can see the template. A private template is only usable by people with access, so make it public or add attendees.
- Confirm VS Code opens the cloned repository, Copilot is enabled and signed in, and Chat and inline chat are available. Keep the opening on `main` and read-only.
- Confirm Actions run in a fresh copy, and that Code Review, Cloud agent, and Agent Merge are available on the accounts in use.
- Configure and verify the merge gates below in each presenter/attendee repository before the walkthrough. Template copies do not inherit these settings, and `scripts/setup-demo.sh` does not configure them.
- Do a full rehearsal in a fresh copy. Push the Cloud agent and Autopilot results to `reference/telemetry-history` and `reference/automation-dry-run` branches to use as fallbacks. These aren't pre-built.
- Optionally rehearse the five parallel sessions and push their results to `reference/*` branches as fallbacks. Each one starts from `main`, so they can be rehearsed in any order.
- Agent Merge is not pre-enabled.

### Configure branch protection (GHAS is optional)

Use a **branch ruleset** to protect `main`. It combines required checks,
review-thread resolution, with optional security results. These instructions change
GitHub settings manually; the demo scripts do not change repository access
or protection settings.

You need repository administration access and a plan that supports rulesets
for the repository's visibility. **The standard walkthrough requires only
CI and review-thread resolution. Skip the optional GHAS section to avoid
additional setup and scan waits.** If you choose to include it, private
repositories need the appropriate GitHub Code Security/Secret Protection
features enabled. Do not describe an unavailable or disabled gate as enforced.

#### 1. Confirm CI runs before requiring it

1. Open a rehearsal PR in the demo repository and inspect its **Checks** tab.
   Confirm `build-and-test` from the **CI** workflow actually runs.
2. Use that exact check name when configuring the ruleset. Do not require
   invented check names or `Build demo artifacts`, which runs only after a
   push to `main`.

#### 2. Create an enforced ruleset for `main`

1. Go to **Settings > Rules > Rulesets > New ruleset > New branch ruleset**.
   If an existing repository ruleset already protects `main`, edit it instead
   and preserve its unrelated protections.
2. Name it **Demo merge gates** and set **Enforcement status** to **Active**,
   not **Evaluate** or **Disabled**.
3. Leave the **Bypass list** empty. Do not add the presenter, administrators,
   Copilot, or other automation as bypass actors.
4. Under **Target branches**, choose **Add target > Include by pattern** and
   enter `main`. Do not target all branches: agents need to push freely to
   their feature branches.
5. Enable **Require a pull request before merging**. In its options, enable
   **Require conversation resolution before merging** so unresolved inline
   review threads, including Copilot's, block merge. For a solo demo, leave
   required human approvals at **0**; use **1** if a second person with write
   access will review. If requiring approvals, also enable **Dismiss stale
   pull request approvals when new commits are pushed**. Copilot's comment
   review does not substitute for a required human approval.
6. Enable **Require status checks to pass**. Click **Add checks**, select the
   exact `build-and-test` check from **CI**, and choose **GitHub Actions** as
   its expected source where offered. Enable **Require branches to be up to
   date before merging**. Checking the rule with an empty required-check
   list does not require CI to pass.
7. For the standard walkthrough, do not add new code-scanning or
   secret-scanning requirements. If you want GHAS in the demo, follow the
   optional section below before enabling those gates. Preserve any existing
   organizational security requirements; do not bypass or disable them.
8. Keep **Block force pushes** and **Restrict deletions** enabled, then save
   the ruleset. Reopen it to confirm it is **Active**, targets `main`, and
   lists `build-and-test` and requires conversation resolution.

#### 3. Verify the gates and Copilot review before the live merge

1. Use the intentionally red stale-telemetry PR from `scripts/setup-demo.sh`
   to verify that failed `build-and-test` blocks merge. Do not bypass it.
2. Request **Copilot** from the PR's **Reviewers** menu and wait for the
   review to finish. Leave the boundary-bug thread unresolved to demonstrate
   the conversation-resolution gate.
3. After fixing the bug, update the feature branch with the latest `main`
   if GitHub requests it, and wait for CI on the new commit. Confirm all
   required checks pass. If optional security gates were enabled, wait for
   their analysis and confirm they pass too.
4. Inspect the replies and fixes for every Copilot thread before resolving
   it. Re-request review after substantial changes. The merge box must show
   no unresolved conversations or remaining approval requirements.
5. Keep Agent Merge's **merge PR** action off for this walkthrough. Enable
   **address reviews**, **fix CI**, and **resolve conflicts** as described
   above, then merge manually only after all gates pass. Do not use an admin
   override or temporarily remove a required check to make the demo proceed.

**Copilot review is not a green-check requirement.** Conversation resolution
blocks existing unresolved review threads; it does not guarantee a Copilot
review was requested or completed, and it does not gate top-level PR comments.
The presenter must verify review completion and address those comments before
merging. Required status checks may also accept neutral/skipped conclusions;
for this demo, confirm the build and test job actually ran successfully.

#### Optional: Add GHAS security scans and merge gates

This is an optional preflight extension, not a prerequisite for the standard
walkthrough. Complete it before presenting if you want to demonstrate security
merge protection; scanning adds extra waits on PR updates.

1. Open **Settings > Advanced Security** (under **Security and quality**;
   older layouts may say **Code security**). Verify feature availability.
   If unavailable, skip this extension and do not claim it is enforced.
2. Under **Code Security**, find **CodeQL analysis**, choose **Set up >
   Default**, confirm C# is selected, and enable CodeQL. Wait for its initial
   analysis to succeed. Default setup runs PR analysis without adding a
   workflow file to this repository.
3. Enable **Secret scanning** and **Push protection** where available.
   Push protection blocks detected secrets during a push; it is not a
   replacement for the secret-scanning merge rule below.
4. Open a rehearsal PR and confirm the security analyses run. Record the
   exact names of any additional PR security checks you intend to require.
   This repository has no dependency-review workflow; Dependabot alerts
   alone are not a PR status check or a merge gate.
5. Edit **Demo merge gates** in **Settings > Rules > Rulesets**. Enable
   **Require code scanning results**. Under **Required tools and alert
   thresholds**, click **Add tool**, select **CodeQL**, set **Alerts** to
   **All**, and set **Security alerts** to **All**. This blocks merge for
   qualifying PR findings and missing or pending required analysis, not just
   a failed workflow run. A green analysis job alone does not mean it found
   no vulnerabilities.
6. Where available, enable **Require secret scanning alerts are resolved**,
   and select all supported secret types offered for the demo. This requires
   scanning to finish and blocks applicable open secrets introduced by the
   PR. The feature is in preview and does not cover AI-detected secrets.
7. Add any additional security checks verified in step 4 to the required
   status-check list using their actual names, then save the active ruleset.
8. Confirm the rehearsal PR satisfies all enabled security gates before
   merging. Once enabled, these gates are mandatory for merge, even though
   adding them to the demo was optional. Do not bypass them to save time.
   Never introduce a real secret or vulnerability just to test a gate.

References: [Ruleset rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets),
[CodeQL default setup](https://docs.github.com/en/code-security/how-tos/find-and-fix-code-vulnerabilities/configure-code-scanning/configure-code-scanning),
and [Code scanning merge protection](https://docs.github.com/en/code-security/how-tos/find-and-fix-code-vulnerabilities/manage-your-configuration/set-merge-protection).

If Cloud agent is unavailable or still running at its checkpoint, show the rehearsal reference branch and leave its issue open. If Code Review is unavailable, use Copilot CLI to inspect the same diff/test; do not claim a Code Review ran. If Agent Merge is unavailable, walk through the checks and thread manually and show readiness without claiming automation. Use the rehearsal Autopilot branch if its task is still running.

## Safe reset

Never reset or rewrite the template's `main`. To start fresh, create a new repository from the template and run `scripts/setup-demo.sh` in a clone. Each run is a clean, identical starting state, and earlier copies stay untouched for reference.
