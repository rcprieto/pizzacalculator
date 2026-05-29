using System.Net.Mail;
using API.Domain.Auxiliar;
using API.Domain.Interfaces.Services;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace API.Services;

public class EmailService : IEmailService
{
  private readonly EmailSettings _settings;

  public EmailService(EmailSettings settings)
  {
    _settings = settings;
  }


  public async Task EnviarAsync(string emailDestinatario, string assuntoMensagem, string mensagem)
  {

    //Define os dados do e-mail
    string nomeRemetente = "Pizza e Pão - ConstructoIT";
    string emailRemetente = "suporte@constructoit.com.br";


    //Cria objeto com dados do e-mail.
    MailMessage objEmail = new MailMessage();

    //Define o Campo From e ReplyTo do e-mail.
    objEmail.From = new System.Net.Mail.MailAddress(nomeRemetente + "<" + emailRemetente + ">");

    //Define os destinatários do e-mail.
    objEmail.To.Add(emailDestinatario);



    //Define os destinatários do e-mail.
    objEmail.To.Add(emailDestinatario);

    objEmail.Priority = System.Net.Mail.MailPriority.Normal;
    objEmail.IsBodyHtml = true;
    objEmail.Subject = assuntoMensagem;
    objEmail.Body = mensagem.ToString();

    //Para evitar problemas de caracteres "estranhos", configuramos o charset para "ISO-8859-1"
    objEmail.SubjectEncoding = System.Text.Encoding.GetEncoding("ISO-8859-1");
    objEmail.BodyEncoding = System.Text.Encoding.GetEncoding("ISO-8859-1");


    //Cria objeto com os dados do SMTP
    System.Net.Mail.SmtpClient objSmtp = new System.Net.Mail.SmtpClient();

    objSmtp.Host = "smtp.gmail.com";
    objSmtp.EnableSsl = true;
    objSmtp.Port = 587;
    objSmtp.UseDefaultCredentials = false;
    objSmtp.DeliveryMethod = SmtpDeliveryMethod.Network;
    objSmtp.Credentials = new System.Net.NetworkCredential("suporte@constructoit.com.br", "kbuv gtsn dnyz ujly");
    objSmtp.Timeout = 20000;
    //Enviamos o e-mail através do método .send()
    try
    {
      objSmtp.Send(objEmail);

    }
    catch (Exception ex)
    {
      string erroMensagem = "Ocorreram problemas no envio do e-mail. Erro = " + ex.Message;

    }
    finally
    {
      //excluímos o objeto de e-mail da memória
      objEmail.Dispose();
      //anexo.Dispose();
    }
  }
}
