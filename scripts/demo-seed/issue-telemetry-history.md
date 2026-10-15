## Goal
Add a history view for the simulated home-lab devices. (Cloud agent exercise.)

## Scope
- Add a recent telemetry-history API endpoint for one device.
- Show the readings as a simple history/trend in a device detail UI.
- Keep edits to the readings API/service and device-history UI; do not change automation logic.

## Acceptance criteria
- Endpoint returns timestamped readings for the requested device and 404 for unknown devices.
- UI shows metric, value/unit, and timestamp.
- Focused tests added; no real device integrations or hardware control.
