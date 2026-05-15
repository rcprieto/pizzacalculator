using API.Data.Context;
using API.Domain.Entidades;
using API.Domain.Interfaces.Repositories;

namespace API.Data.Repositories;

public class IngredienteGrupoRepository : RepositoryBase<IngredienteGrupo>, IIngredienteGrupoRepository
{
    public IngredienteGrupoRepository(PizzaCalculatorDbContext context) : base(context)
    {
    }
}
