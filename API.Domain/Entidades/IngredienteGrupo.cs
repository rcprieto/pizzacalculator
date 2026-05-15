using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace API.Domain.Entidades;

[Table("tbc_ingrediente_grupo")]
public class IngredienteGrupo
{
    [Column("ing_grupo_id")]
    public int Id { get; set; }

    [Column("ing_grupo_nome")]
    [MaxLength(200)]
    public string Nome { get; set; }

    [Column("ing_grupo_ordem")]
    public int Ordem { get; set; }

    [Column("ing_grupo_status")]
    public bool Status { get; set; } = true;

    public ICollection<ReceitaItem> ReceitaItens { get; set; }
}
