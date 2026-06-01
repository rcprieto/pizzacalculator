using API.Domain.Entidades;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace API.Data.Context;

public class PizzaCalculatorDbContext : IdentityDbContext<AppUser, IdentityRole, string>
{
    public PizzaCalculatorDbContext(DbContextOptions<PizzaCalculatorDbContext> options) : base(options)
    {
    }

    public DbSet<Ingrediente> Ingredientes { get; set; }
    public DbSet<IngredienteGrupo> IngredienteGrupos { get; set; }
    public DbSet<Receita> Receitas { get; set; }
    public DbSet<ReceitaItem> ReceitaItens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<AppUser>().ToTable("tbc_usuario");

        modelBuilder.Entity<Ingrediente>()
            .Property(p => p.Preco)
            .HasPrecision(10, 4);

        modelBuilder.Entity<ReceitaItem>()
            .Property(p => p.PesoG)
            .HasPrecision(10, 3);

        modelBuilder.Entity<ReceitaItem>()
            .Property(p => p.Percentual)
            .HasPrecision(10, 4);

        // Receita (1) -> ReceitaItem (N): cascade delete
        modelBuilder.Entity<Receita>()
            .HasMany(r => r.Itens)
            .WithOne(i => i.Receita)
            .HasForeignKey(i => i.ReceitaId)
            .OnDelete(DeleteBehavior.Cascade);

        // Ingrediente (1) -> ReceitaItem (N): restrict delete
        modelBuilder.Entity<Ingrediente>()
            .HasMany(i => i.ReceitaItens)
            .WithOne(ri => ri.Ingrediente)
            .HasForeignKey(ri => ri.IngredienteId)
            .OnDelete(DeleteBehavior.Restrict);

        // IngredienteGrupo (1) -> ReceitaItem (N): restrict delete, nullable FK
        modelBuilder.Entity<IngredienteGrupo>()
            .HasMany(g => g.ReceitaItens)
            .WithOne(ri => ri.IngredienteGrupo)
            .HasForeignKey(ri => ri.IngredienteGrupoId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.Restrict);

        // AppUser (1) -> Receita (N)
        modelBuilder.Entity<AppUser>()
            .HasMany(u => u.Receitas)
            .WithOne(r => r.User)
            .HasForeignKey(r => r.UserId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);

        // AppUser (1) -> Ingrediente (N)
        modelBuilder.Entity<AppUser>()
            .HasMany(u => u.Ingredientes)
            .WithOne(i => i.User)
            .HasForeignKey(i => i.UserId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);

        // AppUser (1) -> IngredienteGrupo (N)
        modelBuilder.Entity<AppUser>()
            .HasMany(u => u.IngredienteGrupos)
            .WithOne(g => g.User)
            .HasForeignKey(g => g.UserId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
