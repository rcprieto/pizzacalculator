using API.Data.Context;
using API.Domain.Entidades;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace API.Data;

public static class DbInitializer
{
  public static async Task SeedAsync(
      UserManager<AppUser> userManager,
      RoleManager<IdentityRole> roleManager,
      PizzaCalculatorDbContext context)
  {
    // Criar roles
    foreach (var role in new[] { "Admin", "User" })
    {
      if (!await roleManager.RoleExistsAsync(role))
        await roleManager.CreateAsync(new IdentityRole(role));
    }

    // Criar usuário admin se não existir nenhum usuário
    if (!await userManager.Users.AnyAsync())
    {
      var admin = new AppUser
      {
        UserName = "rcprieto@gmail.com",
        Email = "rcprieto@gmail.com",
        EmailConfirmed = true,
        Status = true
      };

      var resultado = await userManager.CreateAsync(admin, "a5RCAU!!Xq7f");
      if (!resultado.Succeeded)
        throw new Exception("Falha ao criar usuário admin: " + string.Join(", ", resultado.Errors.Select(e => e.Description)));

      await userManager.AddToRoleAsync(admin, "Admin");

      // Associar todas as receitas existentes ao admin
      var receitas = await context.Receitas.ToListAsync();
      foreach (var receita in receitas)
        receita.UserId = admin.Id;

      if (receitas.Any())
        await context.SaveChangesAsync();
    }
  }
}
