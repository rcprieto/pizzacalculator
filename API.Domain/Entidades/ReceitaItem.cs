using System.ComponentModel.DataAnnotations.Schema;

namespace API.Domain.Entidades;

[Table("tbc_receita_item")]
public class ReceitaItem
{
  [Column("rec_item_id")]
  public int Id { get; set; }

  [Column("rec_id")]
  public int ReceitaId { get; set; }

  [Column("ing_id")]
  public int IngredienteId { get; set; }

  [Column("rec_item_peso_g")]
  public decimal PesoG { get; set; }

  [Column("percentual")]
  public decimal Percentual { get; set; }

  [Column("rec_item_obs")]
  public string Observacao { get; set; }

  [Column("ing_grupo_id")]
  public int? IngredienteGrupoId { get; set; }

  [ForeignKey("ReceitaId")]
  public Receita? Receita { get; set; }

  [ForeignKey("IngredienteId")]
  public Ingrediente? Ingrediente { get; set; }

  [ForeignKey("IngredienteGrupoId")]
  public IngredienteGrupo? IngredienteGrupo { get; set; }
}
