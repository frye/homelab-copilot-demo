# Attendee guide: A Day in the Life of a Developer with Copilot

You'll work in your own copy of **Labwatch**, a simulated home-lab dashboard (ASP.NET Core API + Blazor web UI). Over 90 minutes you'll explore the code with Copilot in VS Code, move to GitHub in the browser for Code Review and Cloud agent delegation, and fix a red pull request with Copilot CLI. Later, you'll use the GitHub Copilot app to plan from an issue, build it with Autopilot, and finish with Agent Merge. Nothing here controls real hardware.

## Before the session (15 minutes)

### You need

Follow [prerequisites and installation](prerequisites.md) for Windows, macOS, or Linux before setting up your copy. It covers .NET 9, Git, GitHub CLI, Copilot clients, sign-in, and optional launcher dependencies.

- A GitHub account with a Copilot plan that includes Code Review, the Cloud agent, and Agent Merge.
- VS Code with GitHub Copilot enabled and signed in. Confirm Copilot Chat and inline chat are available.
- The GitHub Copilot app and Copilot CLI (`copilot`), both signed in, for the later modules.
- On Windows, run the setup script from Git Bash or WSL.

### Set up your copy

1. On the template repository, select **Use this template → Create a new repository**. Make it yours (private is fine). You only need the `main` branch.
2. Clone it and check the baseline is green:

   ```sh
   git clone https://github.com/<you>/<your-repo>.git
   cd <your-repo>
   dotnet test HomeLab.sln
   ```

   You should see `Passed: 2`.
3. Seed the demo starting state:

   ```sh
   scripts/setup-demo.sh
   ```

   This pushes `demo/stale-telemetry-boundary`, opens the PR **Guard automation runs against stale telemetry**, and opens two issues: **Add device telemetry history** and **Add automation dry-run explanations**. Re-running it is safe.
4. In your repo's **Actions** tab, enable workflows if prompted. Within a couple of minutes, the PR's `build-and-test` check should be **red** with exactly one failing test. That's intentional.
5. Open the cloned repository folder in VS Code. Stay on `main`; you'll add the repo to the GitHub Copilot app in module 5.

### Starting-state checklist

- [ ] `main` CI is green.
- [ ] One open PR with one failing test (`AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary`).
- [ ] Two open issues.
- [ ] The app runs locally (below).

```sh
dotnet run --project src/HomeLab.Api --urls http://localhost:5071
dotnet run --project src/HomeLab.Web --urls http://localhost:5072   # second terminal
```

Open <http://localhost:5072>. You should see four devices (rack temperature, CO₂, 3D printer, smart plug) and two automations.

## During the session

Follow along with the presenter. Each module lists what to do and how you know you're done. If something stalls, move on with the group and come back later. The modules are mostly independent.

### 1. VS Code: get oriented with Copilot (0–8 min)

1. In VS Code, use **File > Open Folder** to open your cloned repository on `main`. Open Copilot Chat and select **Ask** to explore without requesting edits.
2. Read `.github/copilot-instructions.md` so you can see the repository's preview-only and testing instructions.
3. Use **Add Context** in Chat to attach `src/HomeLab.Api/Program.cs`, `src/HomeLab.Api/HomeLabStore.cs`, and `src/HomeLab.Web/Components/Pages/Home.razor`. Ask:

   > Explain how the API and web projects fit together. Does the dashboard's Preview button call the API? Can anything here control real hardware? Cite the files that support your answer. Do not change any files.

4. Follow the file references in the answer and check the source.
5. In `Home.razor`, select the `Preview` method and open **Inline Chat** from the editor context menu. Ask:

   > Explain what this selected method does and whether it calls the API or controls hardware. Explain only; do not edit code.

6. Close inline chat after reading the explanation. Discard any proposed edits. Leave the intentionally failing PR untouched for module 4.

**Done when:** you can name the API project, the web project, and where seed data lives (`HomeLabStore.cs`), and explain why Preview doesn't call the API. You've used Chat with file context and inline chat with a selection, without changing files.

Now switch to the browser, view the dashboard at <http://localhost:5072>, and open your repository on GitHub. The GitHub Copilot app comes in module 5.

### 2. Code Review: find the bug (8–20 min)

In GitHub in the browser, open your PR, open **Reviewers**, and request **Copilot**. While it runs, open the failing check's log.

> Review this PR for correctness at the exact five-minute freshness boundary. Cite the code and test that demonstrate the issue.

**Done when:** a review comment points at the `age > TimeSpan.FromMinutes(5)` comparison in `AutomationFreshness.cs`. **Leave that thread unresolved.** Agent Merge handles it in module 7.

### 3. Cloud agent: delegate parallel work (20–35 min)

Stay in GitHub in the browser. Open the **Add device telemetry history** issue and assign it to Copilot. Don't wait for it; it runs while you continue.

**Done when:** the agent has started and opened a draft PR. Check back after module 5.

### 4. Copilot CLI: fix the red PR (35–45 min)

```sh
git fetch origin
git switch demo/stale-telemetry-boundary
copilot
```

> Explain why `AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary` fails, make the smallest fix, and run only that test.

Expect a one-character fix (`>` becomes `>=`). Then verify, commit, and push:

```sh
dotnet test tests/HomeLab.Api.Tests --filter FullyQualifiedName~AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary
git commit -am "Treat readings exactly five minutes old as stale"
git push
```

**Done when:** the test passes locally and the PR's check turns green.

### 5. Plan from an issue (45–65 min)

Now open the GitHub Copilot app and add your repository as a project. Start a session from the **Add automation dry-run explanations** issue. Copilot starts planning automatically: it reads the code, asks a few clarifying questions, and writes a plan with the files and tests it intends to change.

Answer its questions, then read the plan. Push back with **Suggest changes** if it touches telemetry-history files, since the Cloud agent owns those. Don't approve it yet.

Prefer to drive it yourself? Stop the initial planning run and prompt it manually:

> Plan an automation dry-run explanation with trigger, proposed action, and explicit preview-only semantics. List files and acceptance tests before implementation.

**Done when:** the plan names its files and tests, stays out of telemetry-history code, and no files have changed.

### 6. Autopilot (65–78 min)

Approve the plan with **Autopilot**. When it finishes, review the diff and run `dotnet test HomeLab.sln`.

**Done when:** tests pass and the preview explains its trigger and action in plain language.

### 7. Agent Merge (78–90 min)

Back on the stale-telemetry PR, turn on **Agent Merge** from the Copilot app. Don't enable automatic merging. Watch it reply to and resolve the review thread from module 2 and confirm the checks are green.

**Done when:** the PR shows as ready to merge. Merging is your call. When you merge, `main` runs CI and the **Build demo artifacts** workflow publishes a `homelab-demo` artifact.

## End state

After 90 minutes your repository should have:

- The stale-telemetry PR fixed, its review thread resolved, checks green, and the PR ready to merge (or merged).
- A Cloud agent PR for telemetry history, ready for your review.
- An Autopilot-built change for automation dry-run explanations, with tests.
- A `homelab-demo` artifact on `main`, if you merged.

## Troubleshooting

| Problem | Try |
|---|---|
| `setup-demo.sh: Permission denied` | `bash scripts/setup-demo.sh` |
| PR check never starts | Enable workflows in the **Actions** tab, then push an empty commit to the PR branch. |
| Port already in use | Pick other ports and pass them with `--urls`. |
| Copilot isn't listed as a reviewer | Your plan or org policy may not include Code Review. Use Copilot CLI with the module 2 prompt instead. |
| Cloud agent or Agent Merge is unavailable | Watch the presenter's screen; the remaining modules don't depend on it. |
| Want to start over | Create another repo from the template and rerun `scripts/setup-demo.sh`. |
