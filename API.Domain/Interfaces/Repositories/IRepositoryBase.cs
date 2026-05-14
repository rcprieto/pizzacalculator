using System.Linq.Expressions;
using API.Domain.Helpers;
using AutoMapper;

namespace API.Domain.Interfaces.Repositories;

public interface IRepositoryBase<TEntity> : IDisposable where TEntity : class
{
    Task<TEntity> GetByIdAsync(int id);
    Task<IQueryable<TEntity>> GetAllAsync(string? include = null);
    Task<PagedList<TDto>> GetAllPaginatedAsync<TDto>(Expression<Func<TEntity, bool>> filterFunction, PaginationParams pgParams, IMapper mapper);
    Task<IEnumerable<TEntity>> GetAllAsync(Expression<Func<TEntity, bool>> filterFunction, Expression<Func<TEntity, string>> orderByFunction);
    Task<IQueryable<TEntity>> SearchAsync(Expression<Func<TEntity, bool>> predicate, string? include = null);
    Task<bool> AddRangeAsync(List<TEntity> obj);
    Task<bool> AddAsync(TEntity obj);
    bool Update(TEntity obj);
    bool UpdateRange(List<TEntity> obj);
    bool Delete(int id);
    Task<int> SaveChangesAsync();
}
