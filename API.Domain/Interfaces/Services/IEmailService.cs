namespace API.Domain.Interfaces.Services;

public interface IEmailService
{
    Task EnviarAsync(string destinatario, string assunto, string corpoHtml);
}
