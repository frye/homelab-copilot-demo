# Prerequisites and installation

Install and verify these tools before following the [attendee guide](attendee-guide.md). Choose the instructions for your operating system below. Labwatch is a simulated dashboard; no hardware, device credentials, or home-lab equipment is needed.

## What you need

| Purpose | Requirements |
|---|---|
| Build and run the dashboard locally | Git, the **.NET 9 SDK**, a terminal, and a browser |
| Seed the workshop repository | Bash, GitHub CLI (`gh`), a signed-in GitHub account with permission to push branches and create issues/PRs, and a configured Git commit identity |
| Follow the Copilot exercises | Copilot access, VS Code with GitHub Copilot, Copilot CLI (`copilot`), and the GitHub Copilot app |
| Use the optional `scripts/run.sh` launcher | Bash, **Python 3 available as `python3`**, and `curl`, in addition to .NET |

Install the SDK, not just a runtime: it includes the build tools and the .NET/ASP.NET Core 9 runtimes needed by the `net9.0` projects. A newer SDK alone may not include those runtimes. No separate Blazor workload, database server, Docker, or Node.js is required. VS Code is used in the opening workshop module, but is not needed to build or run the dashboard.

### Account and feature access

- Use a GitHub account that can access the template repository and create its own repository. Private repositories are fine.
- Check your [Copilot plan](https://github.com/features/copilot/plans) and organization policies for the features used in the session: Code Review, the Cloud agent, Copilot CLI, and Agent Merge. Access to one client does not guarantee access to every feature.
- Ensure GitHub Actions can run in your copy of the repository. Organization policies may restrict Actions, Copilot, or repository creation; resolve those restrictions with your administrator before the session.
- If a client is unavailable, use another available Copilot client for the prompts and coding tasks. UI steps differ, and switching clients does not bypass feature or policy restrictions. For unavailable features, use the fallbacks in the [attendee guide](attendee-guide.md) or follow the presenter's demonstration.

## Windows

### Native Windows tools

Use [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/) from **PowerShell** to install the tools you are missing:

```powershell
winget install --id Git.Git --exact --source winget
winget install --id Microsoft.DotNet.SDK.9 --exact --source winget
winget install --id GitHub.cli --exact --source winget
winget install --id Microsoft.PowerShell --exact --source winget
winget install --id GitHub.Copilot --exact --source winget
```

Copilot CLI on Windows requires PowerShell 6 or later; the PowerShell package above provides a current version. Open **PowerShell 7** (`pwsh`) to use it rather than the older built-in Windows PowerShell.

If WinGet is unavailable, use the official installers for [Git for Windows](https://git-scm.com/install/windows), the [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0), [GitHub CLI](https://cli.github.com/), and [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows), plus the [Copilot CLI installation guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli). Match the installer architecture to your machine.

Close and reopen terminals after installation so they see the updated `PATH`. Git for Windows includes **Git Bash**: use it for `scripts/setup-demo.sh` and `scripts/run.sh`. Run the .NET commands in PowerShell or Git Bash, and Copilot CLI in PowerShell 7, from the same repository clone.

### WSL alternative

If you prefer Linux tooling, [install WSL](https://learn.microsoft.com/en-us/windows/wsl/install), then follow the Linux instructions **inside WSL**. Install Git, .NET, `gh`, and `copilot` there, authenticate there, and clone and run the repository there. Do not mix Windows and Linux SDKs, authentication, or repository paths.

The desktop Copilot app is a separate installation. Check its current platform and workspace support before trying to open a WSL checkout; otherwise use Copilot CLI inside WSL for applicable tasks.

## macOS

1. Install Git and GitHub CLI. If you use [Homebrew](https://brew.sh/), run:

   ```sh
   brew install git gh
   ```

   Without Homebrew, follow the official [Git installation options](https://git-scm.com/install/mac) and [GitHub CLI installation instructions](https://github.com/cli/cli#installation).
2. Download and install the **.NET 9 SDK** from the [.NET 9 downloads page](https://dotnet.microsoft.com/download/dotnet/9.0). Choose **Arm64** for Apple Silicon or **x64** for Intel. See Microsoft's [macOS installation guide](https://learn.microsoft.com/en-us/dotnet/core/install/macos) for supported OS versions and PATH troubleshooting.
3. Install Copilot CLI with Homebrew:

   ```sh
   brew install --cask copilot-cli
   ```

   Alternatively, download and unpack the executable for your architecture from the [official Copilot CLI releases](https://github.com/github/copilot-cli/releases) and place it in a directory on your `PATH`.

Use Terminal with Bash or zsh for the commands in this guide. The repository scripts select Bash through their shebang. Reopen your terminal after installing tools.

## Linux

Use a distribution supported by [.NET's Linux installation guide](https://learn.microsoft.com/en-us/dotnet/core/install/linux). Run all commands in the same Linux environment (including WSL, if applicable).

1. Install Git and Bash with your distribution's package manager. For example, on Ubuntu/Debian:

   ```sh
   sudo apt update
   sudo apt install git bash
   ```

   On Fedora:

   ```sh
   sudo dnf install git bash
   ```
2. Follow the [official GitHub CLI Linux instructions](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) for your distribution, including its package repository setup, then install `gh`.
3. Follow Microsoft's [.NET installation instructions for your distribution](https://learn.microsoft.com/en-us/dotnet/core/install/linux), selecting the **9.0 SDK**. Where the configured package source provides it, the package is named `dotnet-sdk-9.0`. Do not assume every distribution's default package source includes it or mix package sources for the same .NET installation.
4. Install Copilot CLI using the [official installation guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli). A package-manager-independent option is to download the Linux executable for your architecture from the [official releases](https://github.com/github/copilot-cli/releases), unpack it, and place it on your `PATH`, for example in `~/.local/bin`. Ensure that directory is on your shell's `PATH`.

## Install and sign in to a Copilot client

For the desktop workflow, download the **GitHub Copilot app** from its [official installation page](https://github.com/github/app#install). Select a build for your OS and architecture from the listed downloads or releases and follow the installer prompts. Check the page for current platform requirements; if no compatible build is available, use another Copilot client. This app is separate from GitHub Desktop and Microsoft Copilot.

Open the app, sign in with your GitHub account, and confirm you can access your workshop repository when you create it. For setup help, see the [Copilot app documentation](https://docs.github.com/en/copilot/how-tos/github-copilot-app).

For Copilot CLI, verify the executable and start it:

```sh
copilot --version
copilot
```

Follow its sign-in prompts; enter `/login` if needed. Confirm that a simple prompt receives a response. GitHub CLI authentication and Copilot authentication are separate checks; a successful `gh auth status` alone does not establish Copilot access. See the [Copilot CLI setup guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/set-up-copilot-cli/install-copilot-cli).

For the opening workshop module, install [VS Code](https://code.visualstudio.com/download) for your OS and its GitHub Copilot integration using the [official IDE setup instructions](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-extension). Sign in and confirm both Copilot Chat and inline chat work. If VS Code is unavailable, use another available client's equivalent controls for applicable tasks rather than expecting the same UI.

## Authenticate GitHub CLI and configure Git

In the environment where you will run `scripts/setup-demo.sh`:

```sh
gh auth login
gh auth status
```

Select GitHub.com and follow the browser sign-in flow. Use the GitHub account that will own your workshop repository. If you choose HTTPS for Git operations, run `gh auth setup-git` to configure Git to use GitHub CLI credentials. If you choose SSH, ensure your SSH key is configured for GitHub and use an SSH clone URL.

The seed script creates a commit, so Git needs a name and email. Check your existing settings:

```sh
git config --get user.name
git config --get user.email
```

If either is missing, set it **inside your workshop clone** after cloning:

```sh
git config user.name "Your Name"
git config user.email "YOUR_GITHUB_NOREPLY_EMAIL"
```

Replace the placeholders with your chosen commit name and the exact no-reply address shown in your [GitHub email settings](https://github.com/settings/emails). These commands set repository-local values without changing your identity in other repositories.

## Optional: install launcher dependencies

Skip this section if you will run the API and web UI in two terminals using the [README commands](../README.md#run-locally).

`scripts/run.sh` requires `python3` for port checks and `curl` for service readiness checks:

- **Windows / Git Bash:** install Python 3 using the [official Windows downloads](https://www.python.org/downloads/windows/) and follow its PATH instructions. Git Bash normally includes `curl`; check it below. Verify that `python3` runs real Python in Git Bash. Having only `py` or `python`, or a Microsoft Store alias, does not satisfy the script.
- **macOS:** with Homebrew, run `brew install python`. macOS includes `curl`; if missing, use the [curl installation options](https://curl.se/download.html).
- **Ubuntu/Debian / WSL:** run `sudo apt install python3 curl`.
- **Fedora:** run `sudo dnf install python3 curl`. For other distributions, use their package manager.

Verify from the **Bash environment that will run the script**:

```sh
bash --version
python3 -c "import sys; print(sys.version)"
curl --version
```

If `python3` is not available under that exact name, use WSL with Python installed there or the two-terminal .NET commands instead.

## Verify before the session

From your chosen development environment:

```sh
git --version
dotnet --list-sdks
dotnet --list-runtimes
gh --version
gh auth status
```

Expect a `9.0.x` SDK and both `Microsoft.NETCore.App 9.0.x` and `Microsoft.AspNetCore.App 9.0.x` runtimes. For the CLI exercise, also check `copilot --version` and a signed-in chat as described above.

Return to [Set up your copy](attendee-guide.md#set-up-your-copy) to create a repository from the template, clone it, run `dotnet test HomeLab.sln`, and seed the exercises. First-time restore needs network access to NuGet; GitHub setup and Copilot also need network access.

| Problem | Try |
|---|---|
| A command is not found after installation | Reopen the terminal and check the installer's PATH instructions. In Bash, use `command -v git dotnet gh copilot` to see which executables are resolved. |
| .NET reports a missing SDK or framework | Install the .NET **9 SDK**, then recheck both SDKs and runtimes. Ensure your shell is not resolving another architecture or environment's installation. |
| A `.sh` script fails in PowerShell | Run it from Git Bash or WSL, not directly in PowerShell. |
| A tool works on Windows but not in WSL, or vice versa | Install and authenticate it in the environment containing your clone; do not rely on the other environment's configuration. |
| Git cannot create a commit | Set the repository-local commit name and email above. |
| GitHub or Copilot reports access denied | Check the signed-in account, repository access, subscription, organization policy, and any required organization SSO authorization. |
| Copilot app or a workshop feature is unavailable | Use another available client for applicable tasks; follow the attendee guide's feature-specific fallback or watch the presenter. |
