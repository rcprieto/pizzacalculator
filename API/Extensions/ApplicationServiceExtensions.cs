using API.Data.Context;
using API.Data.Repositories;
using API.Domain.Auxiliar;
using API.Domain.Interfaces.Repositories;
using API.Domain.Interfaces.Services;
using API.Domain.Services;
using Microsoft.EntityFrameworkCore;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;

namespace API.Extensions;

public static class ApplicationServiceExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
        var emailSettings = config.GetSection("EmailSettings").Get<EmailSettings>() ?? new EmailSettings();
        services.AddSingleton(emailSettings);
        services.AddScoped<IEmailService, API.Services.EmailService>();

        services.AddDbContext<PizzaCalculatorDbContext>(options => options
            .UseMySql(config.GetConnectionString("DbConnectionString"),
            new MySqlServerVersion(new Version(8, 0, 19)),
            b => b.SchemaBehavior(MySqlSchemaBehavior.Translate, (schemaName, objectName) => objectName))
            .EnableSensitiveDataLogging()
            .EnableDetailedErrors());

        services.AddCors();
        services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
        services.AddScoped<DbContext, PizzaCalculatorDbContext>();
        services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();
        services.AddScoped<PizzaCalculatorDbContext>();

        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IIngredienteRepository, IngredienteRepository>();
        services.AddScoped<IIngredienteGrupoRepository, IngredienteGrupoRepository>();
        services.AddScoped<IReceitaRepository, ReceitaRepository>();
        services.AddScoped<IReceitaItemRepository, ReceitaItemRepository>();

        return services;
    }
}
