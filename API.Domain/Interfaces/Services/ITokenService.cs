using API.Domain.Entidades;

namespace API.Domain.Interfaces.Services;

public interface ITokenService
{
    string CreateToken(AppUser user, string role);
}
