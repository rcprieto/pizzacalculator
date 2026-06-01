using Microsoft.AspNetCore.Identity;

namespace API.Domain.Entidades;

public class AppUser : IdentityUser
{
  public bool Status { get; set; } = true;
  public ICollection<Receita> Receitas { get; set; } = new List<Receita>();
  public ICollection<Ingrediente> Ingredientes { get; set; } = new List<Ingrediente>();
  public ICollection<IngredienteGrupo> IngredienteGrupos { get; set; } = new List<IngredienteGrupo>();
}
