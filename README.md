# Labwatch — HomeLab Copilot demo

A small, simulated home-lab dashboard for a 90-minute “A Day in the Life of a Developer with Copilot” session. It includes an ASP.NET Core API, a Blazor Server web UI, seeded sensor data, and safe automation previews. **No endpoint controls physical hardware.**

## Prerequisites

- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) and Git
- [GitHub CLI](https://cli.github.com/) (`gh`) and a Copilot client, such as Copilot CLI (`copilot`), for the workshop
- Bash, Python 3 (`python3`), and `curl` for the optional `scripts/run.sh` launcher

See [prerequisites and installation](docs/prerequisites.md) for install steps on Windows, macOS, and Linux, sign-in, and verification.

## Run locally

Requires the .NET 9 SDK.

```sh
dotnet run --project src/HomeLab.Api --urls http://localhost:5071
dotnet run --project src/HomeLab.Web --urls http://localhost:5072
```

Or start both at once with `scripts/run.sh` (requires Python 3 for port checks; Ctrl+C stops both; override ports with `API_PORT`/`WEB_PORT`). Occupied ports produce an error before building or launching. Use `scripts/run.sh --auto-ports` to select two unused ports and open the printed Web URL. If either service exits, the script stops the other and returns a nonzero exit status. Port checks cannot prevent another process from taking a selected port during startup.

Open <http://localhost:5072>. The API exposes `/api/devices`, `/api/readings`, `/api/automations`, and `POST /api/automations/{id}/preview`. The preview endpoint only returns a simulated result.

```sh
dotnet test HomeLab.sln
```

**Following along?** Start with [the attendee guide](docs/attendee-guide.md): create your own repo from this template and run `scripts/setup-demo.sh`.

Presenters: see [the demo runbook](docs/demo-runbook.md) for the 90-minute talk track, setup, and reset procedure.
