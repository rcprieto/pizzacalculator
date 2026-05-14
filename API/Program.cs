using System.Globalization;
using System.Text.Json.Serialization;
using API.Domain.Auxiliar;
using API.Extensions;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Localization.Routing;
using Microsoft.IdentityModel.Logging;

var builder = WebApplication.CreateBuilder(args);

var connect = builder.Configuration.GetSection("ConnectionStrings");
builder.Services.Configure<ConnStringsHelper>(connect);
builder.Services.AddSingleton(connect.Get<ConnStringsHelper>());

builder.Services.AddApplicationServices(builder.Configuration);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddControllers().AddNewtonsoftJson(options =>
{
  options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
});

builder.Services.AddIdentityServices(builder.Configuration);

builder.Services.Configure<RequestLocalizationOptions>(opts =>
{
  var supportedCultures = new List<CultureInfo>
    {
        new CultureInfo("pt-BR")
    };

  opts.DefaultRequestCulture = new RequestCulture("pt-BR");
  opts.SetDefaultCulture("pt-BR");
  opts.SupportedCultures = supportedCultures;
  opts.SupportedUICultures = supportedCultures;
  var provider = new RouteDataRequestCultureProvider { RouteDataStringKey = "lang", UIRouteDataStringKey = "lang", Options = opts };
  opts.RequestCultureProviders = new[] { provider };
});

builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
  options.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
});

if (builder.Environment.IsDevelopment())
{
  IdentityModelEventSource.ShowPII = true;
}
IdentityModelEventSource.LogCompleteSecurityArtifact = true;

var app = builder.Build();

app.UseRouting();
app.UseCors(x =>
    x.AllowAnyHeader()
    .AllowAnyMethod()
    .WithOrigins(["https://localhost:4028", "https://localhost:4200", "https://localhost:4215", "https://pizza.citapps.com.br"]));

app.UseAuthentication();
app.UseAuthorization();
app.Use(async (context, next) =>
{
  try
  {
    await next();
  }
  catch (Exception ex)
  {
    context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
    context.Response.StatusCode = 500;
    await context.Response.WriteAsync("Erro interno no servidor." + ex.Message);
  }
});

app.UseDefaultFiles();
app.UseStaticFiles();
app.MapControllers();

app.MapFallbackToController("Index", "Fallback");

app.UseEndpoints(endpoints =>
{
  endpoints.MapControllerRoute(
      name: "default",
      pattern: "{controller=Home}/{action=Index}/{id?}");
});

app.Run();
