namespace HomeLab.Api;

public enum AutomationDecision
{
    Triggered,
    Suppressed
}

public static class AutomationFreshness
{
    public static AutomationDecision Evaluate(DateTimeOffset recordedAt, DateTimeOffset now)
    {
        var age = now - recordedAt;
        return age > TimeSpan.FromMinutes(5)
            ? AutomationDecision.Suppressed
            : AutomationDecision.Triggered;
    }
}
