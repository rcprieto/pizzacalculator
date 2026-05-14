namespace API.Domain.DTOs;

public class IngredienteDto
{
    public int Id { get; set; }
    public string Nome { get; set; }
    public string Marca { get; set; }
    public decimal Preco { get; set; }
    public bool Status { get; set; }
}
