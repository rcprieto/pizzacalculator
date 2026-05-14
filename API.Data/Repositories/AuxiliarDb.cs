using Dapper;
using MySql.Data.MySqlClient;

namespace API.Data.Repositories;

public static class AuxiliarDb
{
    public static List<TEntity> RodaQuery<TEntity>(string sql, string connectionString) where TEntity : new()
    {
        List<TEntity> retorno;
        using (MySqlConnection con = new MySqlConnection(connectionString))
        {
            try
            {
                con.Open();
                retorno = con.Query<TEntity>(sql).ToList();
            }
            catch
            {
                try
                {
                    con.Open();
                    retorno = con.Query<TEntity>(sql).ToList();
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
            finally
            {
                con.Close();
            }
        }

        return retorno;
    }
}
