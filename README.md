# Labwatch — HomeLab Copilot demo

A small, simulated home-lab dashboard for a 90-minute “A Day in the Life of a Developer with Copilot” session. It includes an ASP.NET Core API, a Blazor Server web UI, seeded sensor data, and safe automation previews. **No endpoint controls physical hardware.**

## Run locally

Requires the .NET 9 SDK.

```sh
dotnet run --project src/HomeLab.Api --urls http://localhost:5071
dotnet run --project src/HomeLab.Web --urls http://localhost:5072
```

Open <http://localhost:5072>. The API exposes `/api/devices`, `/api/readings`, `/api/automations`, and `POST /api/automations/{id}/preview`. The preview endpoint only returns a simulated result.

```sh
dotnet test HomeLab.sln
```

See [the demo runbook](docs/demo-runbook.md) for the 90-minute talk track, GitHub setup, and reset procedure.
