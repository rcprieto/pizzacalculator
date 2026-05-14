using System.ComponentModel.DataAnnotations.Schema;

namespace API.Domain.Entidades;

[Table("tbc_ingrediente")]
public class Ingrediente
{
    [Column("ing_id")]
    public int Id { get; set; }

    [Column("ing_nome")]
    public string Nome { get; set; }

    [Column("ing_marca")]
    public string Marca { get; set; }

    [Column("ing_preco")]
    public decimal Preco { get; set; }

    [Column("ing_status")]
    public bool Status { get; set; } = true;

    public ICollection<ReceitaItem> ReceitaItens { get; set; }
}
