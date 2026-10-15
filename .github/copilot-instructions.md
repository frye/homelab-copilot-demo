# HomeLab Copilot demo

- This is a simulated home-lab dashboard; never add integrations that actuate physical hardware.
- Keep the ASP.NET Core API (`src/HomeLab.Api`) and Blazor UI (`src/HomeLab.Web`) independently runnable.
- Use deterministic clocks in tests and keep demo seed data stable and human-readable.
- Treat automation operations as previews only and make that limitation visible in the UI and API.
- Run `dotnet test HomeLab.sln` after changes.
