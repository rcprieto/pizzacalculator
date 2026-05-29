namespace API.Domain.Auxiliar;

public class EmailSettings
{
    public string Host { get; set; } = "";
    public int Port { get; set; } = 587;
    public bool UseSsl { get; set; } = true;
    public string Usuario { get; set; } = "";
    public string Senha { get; set; } = "";
    public string NomeRemetente { get; set; } = "";
    public string EmailRemetente { get; set; } = "";
}
