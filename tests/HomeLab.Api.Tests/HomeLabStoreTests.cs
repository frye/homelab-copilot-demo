using HomeLab.Api;

namespace HomeLab.Api.Tests;

public sealed class HomeLabStoreTests
{
    [Fact]
    public void SeedContainsFourDevicesAndTwoAutomations()
    {
        var store = new HomeLabStore(TimeProvider.System);

        Assert.Equal(4, store.Devices.Count);
        Assert.Equal(2, store.Automations.Count);
        Assert.All(store.Readings, reading => Assert.Contains(store.Devices, device => device.Id == reading.DeviceId));
    }

    [Fact]
    public void AutomationPreviewExplainsSimulationWithoutHardware()
    {
        var store = new HomeLabStore(TimeProvider.System);
        var automation = Assert.Single(store.Automations, item => item.Name == "Cool the rack");

        Assert.Contains("28", automation.Trigger);
        Assert.Contains("Preview", automation.Action);
        Assert.True(automation.Enabled);
    }

    [Fact]
    public void AutomationEvaluator_SuppressesReadingAtFiveMinuteBoundary()
    {
        var now = new DateTimeOffset(2026, 10, 14, 12, 0, 0, TimeSpan.Zero);
        var recordedAt = now.AddMinutes(-5);

        var decision = AutomationFreshness.Evaluate(recordedAt, now);

        Assert.Equal(AutomationDecision.Suppressed, decision);
    }
}
