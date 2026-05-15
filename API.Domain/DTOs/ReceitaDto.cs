namespace API.Domain.DTOs;

public class ReceitaDto
{
    public int Id { get; set; }
    public string Nome { get; set; }
    public string ModoPreparo { get; set; }
    public bool Status { get; set; }
    public List<ReceitaItemDto> Itens { get; set; } = new();
}

public class ReceitaItemDto
{
    public int Id { get; set; }
    public int ReceitaId { get; set; }
    public int IngredienteId { get; set; }
    public string IngredienteNome { get; set; }
    public string IngredienteMarca { get; set; }
    public decimal PesoG { get; set; }
    public decimal Percentual { get; set; }
    public string Observacao { get; set; }
    public decimal IngredientePreco { get; set; }
    public int? IngredienteGrupoId { get; set; }
    public string IngredienteGrupoNome { get; set; }
    public int IngredienteGrupoOrdem { get; set; }
}
