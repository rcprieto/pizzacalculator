using API.Domain.Entidades;

namespace API.Domain.Interfaces.Repositories;

public interface IReceitaRepository : IRepositoryBase<Receita>
{
    Task<Receita> GetReceitaComItensAsync(int id);
}
