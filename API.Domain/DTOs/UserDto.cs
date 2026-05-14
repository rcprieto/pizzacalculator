using System.ComponentModel.DataAnnotations;

namespace API.Domain.DTOs;

public class UserDto
{
    public string? Email { get; set; }
    public string? Token { get; set; }
    public string? Password { get; set; }
}

public class LoginDto
{
    public string Email { get; set; }
    public string Password { get; set; }
}
