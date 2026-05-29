using System.ComponentModel.DataAnnotations;

namespace API.Domain.DTOs;

public class UserDto
{
    public string? Email { get; set; }
    public string? Token { get; set; }
    public string? Role { get; set; }
}

public class LoginDto
{
    public string Email { get; set; }
    public string Password { get; set; }
}

public class RegisterDto
{
    public string Email { get; set; }
}

public class EsqueciSenhaDto
{
    [EmailAddress]
    public string Email { get; set; }
}

public class UsuarioDto
{
    public string Id { get; set; }
    public string Email { get; set; }
    public string Role { get; set; }
    public bool Status { get; set; }
}
