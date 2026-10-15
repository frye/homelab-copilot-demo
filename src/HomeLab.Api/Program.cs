using HomeLab.Api;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddOpenApi();
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddSingleton<HomeLabStore>();
builder.Services.AddCors(options => options.AddDefaultPolicy(policy =>
    policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.MapGet("/api/devices", (HomeLabStore store) => Results.Ok(store.Devices));
app.MapGet("/api/readings", (HomeLabStore store) => Results.Ok(store.Readings));
app.MapGet("/api/automations", (HomeLabStore store) => Results.Ok(store.Automations));
app.MapPost("/api/automations/{id:guid}/preview", (Guid id, HomeLabStore store) =>
{
    var automation = store.Automations.FirstOrDefault(item => item.Id == id);
    return automation is null
        ? Results.NotFound()
        : Results.Ok(new AutomationPreview(automation.Id, automation.Name, automation.Trigger, automation.Action,
            "Preview only — no hardware was contacted.", DateTimeOffset.UtcNow));
});
app.MapGet("/", () => Results.Redirect("/api/devices"));
app.Run();

public partial class Program;
