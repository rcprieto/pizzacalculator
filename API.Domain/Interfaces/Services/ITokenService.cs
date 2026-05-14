using API.Domain.DTOs;

namespace API.Domain.Interfaces.Services;

public interface ITokenService
{
    Task<string> CreateToken(UserDto user);
}
