using System.ComponentModel.DataAnnotations.Schema;

namespace API.Domain.Entidades;

[Table("tbc_receita")]
public class Receita
{
    [Column("rec_id")]
    public int Id { get; set; }

    [Column("rec_nome")]
    public string Nome { get; set; }

    [Column("rec_modo_preparo")]
    public string ModoPreparo { get; set; }

    [Column("rec_status")]
    public bool Status { get; set; } = true;

    [Column("rec_user_id")]
    public string UserId { get; set; }

    public AppUser User { get; set; }

    public ICollection<ReceitaItem> Itens { get; set; }
}
