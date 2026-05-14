using API.Data.Context;
using API.Domain.Entidades;
using API.Domain.Interfaces.Repositories;
using Microsoft.EntityFrameworkCore;

namespace API.Data.Repositories;

public class ReceitaRepository : RepositoryBase<Receita>, IReceitaRepository
{
    public ReceitaRepository(PizzaCalculatorDbContext context) : base(context)
    {
    }

    public async Task<Receita> GetReceitaComItensAsync(int id)
    {
        return await Db.Receitas
            .Include(r => r.Itens)
                .ThenInclude(i => i.Ingrediente)
            .AsNoTracking()
            .FirstOrDefaultAsync(r => r.Id == id);
    }
}
