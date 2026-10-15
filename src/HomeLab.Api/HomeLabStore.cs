namespace HomeLab.Api;

public sealed record Device(Guid Id, string Name, string Kind, string Location, string Status, string LastSeen);
public sealed record Reading(Guid DeviceId, string Metric, double Value, string Unit, DateTimeOffset RecordedAt);
public sealed record Automation(Guid Id, string Name, string Trigger, string Action, bool Enabled);
public sealed record AutomationPreview(Guid AutomationId, string Name, string Trigger, string Action, string Result, DateTimeOffset CreatedAt);

public sealed class HomeLabStore
{
    private static readonly Guid RackSensorId = Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f001001");
    private static readonly Guid AirSensorId = Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f001002");
    private static readonly Guid PrinterId = Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f001003");
    private static readonly Guid PlugId = Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f001004");
    private readonly TimeProvider _clock;

    public HomeLabStore(TimeProvider clock)
    {
        _clock = clock;
        var now = _clock.GetUtcNow();
        Devices =
        [
            new(RackSensorId, "Rack temperature", "Temperature sensor", "Office rack", "Healthy", now.AddSeconds(-18).ToString("O")),
            new(AirSensorId, "Air quality", "CO₂ sensor", "Workshop", "Healthy", now.AddSeconds(-35).ToString("O")),
            new(PrinterId, "Workshop printer", "3D printer", "Workshop", "Idle", now.AddMinutes(-12).ToString("O")),
            new(PlugId, "Printer power", "Smart plug", "Workshop", "On", now.AddSeconds(-9).ToString("O"))
        ];
        Readings =
        [
            new(RackSensorId, "Temperature", 28.4, "°C", now.AddMinutes(-1)),
            new(RackSensorId, "Temperature", 27.9, "°C", now.AddMinutes(-4)),
            new(AirSensorId, "CO₂", 812, "ppm", now.AddMinutes(-1)),
            new(AirSensorId, "CO₂", 790, "ppm", now.AddMinutes(-6)),
            new(PrinterId, "Print progress", 0, "%", now.AddMinutes(-2)),
            new(PlugId, "Power draw", 3.2, "W", now.AddSeconds(-30))
        ];
        Automations =
        [
            new(Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f002001"), "Cool the rack", "Rack temperature ≥ 28 °C", "Preview turning on the ventilation fan", true),
            new(Guid.Parse("a3c5d40b-2226-4a4f-b123-6de78f002002"), "Power down idle printer", "Printer idle for 30 minutes", "Preview switching off Printer power", true)
        ];
    }

    public IReadOnlyList<Device> Devices { get; }
    public IReadOnlyList<Reading> Readings { get; }
    public IReadOnlyList<Automation> Automations { get; }
}
