using API.Data.Context;
using API.Domain.Entidades;
using API.Domain.Interfaces.Repositories;

namespace API.Data.Repositories;

public class IngredienteRepository : RepositoryBase<Ingrediente>, IIngredienteRepository
{
    public IngredienteRepository(PizzaCalculatorDbContext context) : base(context)
    {
    }
}
