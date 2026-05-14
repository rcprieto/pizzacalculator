using System.Linq.Expressions;
using API.Data.Context;
using API.Domain.Helpers;
using API.Domain.Interfaces.Repositories;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace API.Data.Repositories;

public abstract class RepositoryBase<TEntity> : IRepositoryBase<TEntity> where TEntity : class
{
    protected PizzaCalculatorDbContext Db;
    protected DbSet<TEntity> DbSet;

    protected RepositoryBase(PizzaCalculatorDbContext context)
    {
        Db = context;
        DbSet = Db.Set<TEntity>();
    }

    public virtual async Task<TEntity> GetByIdAsync(int id)
    {
        return await DbSet.FindAsync(id);
    }

    public virtual async Task<IQueryable<TEntity>> GetAllAsync(string? include = null)
    {
        if (!string.IsNullOrEmpty(include))
            return DbSet.AsNoTracking().Include(include);
        else
            return DbSet.AsNoTracking();
    }

    public virtual async Task<PagedList<TDto>> GetAllPaginatedAsync<TDto>(Expression<Func<TEntity, bool>> filterFunction, PaginationParams pgParams, IMapper mapper)
    {
        var query = DbSet.Where(filterFunction).OrderBy(pgParams.OrderBy + " " + pgParams.Order);
        return await PagedList<TDto>.CreateAsync(query.AsNoTracking().ProjectTo<TDto>(mapper.ConfigurationProvider), pgParams.PageNumber, pgParams.PageSize);
    }

    public async Task<IEnumerable<TEntity>> GetAllAsync(Expression<Func<TEntity, bool>> filterFunction, Expression<Func<TEntity, string>> orderByFunction)
    {
        return DbSet.Where(filterFunction).OrderBy(orderByFunction);
    }

    public virtual async Task<IQueryable<TEntity>> SearchAsync(Expression<Func<TEntity, bool>> predicate, string? include = null)
    {
        if (!string.IsNullOrEmpty(include))
            return DbSet.AsNoTracking().Where(predicate).Include(include);
        else
            return DbSet.AsNoTracking().Where(predicate);
    }

    public virtual async Task<bool> AddAsync(TEntity obj)
    {
        try
        {
            await DbSet.AddAsync(obj);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public virtual async Task<bool> AddRangeAsync(List<TEntity> obj)
    {
        try
        {
            await DbSet.AddRangeAsync(obj);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public virtual bool Update(TEntity obj)
    {
        try
        {
            DbSet.Update(obj);
            Db.SaveChanges();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public virtual bool UpdateRange(List<TEntity> obj)
    {
        try
        {
            DbSet.UpdateRange(obj);
            Db.SaveChanges();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public virtual bool Delete(int id)
    {
        try
        {
            DbSet.Remove(DbSet.Find(id));
            Db.SaveChanges();
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task<int> SaveChangesAsync()
    {
        try
        {
            return await Db.SaveChangesAsync();
        }
        catch { }

        return -1;
    }

    public void Dispose()
    {
        Db.Dispose();
    }
}
