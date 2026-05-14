using API.Data.Context;
using API.Domain.Entidades;
using API.Domain.Interfaces.Repositories;

namespace API.Data.Repositories;

public class ReceitaItemRepository : RepositoryBase<ReceitaItem>, IReceitaItemRepository
{
    public ReceitaItemRepository(PizzaCalculatorDbContext context) : base(context)
    {
    }
}
