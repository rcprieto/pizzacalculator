using API.Domain.DTOs;
using API.Domain.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AccountController : ControllerBase
{
    private readonly ITokenService _tokenService;

    public AccountController(ITokenService tokenService)
    {
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<UserDto>> Login(LoginDto model)
    {
        if (model.Email.ToLower() != "rcprieto@gmail.com")
            return BadRequest("Login Inválido");

        if (model.Password != "pizza@123")
            return BadRequest("Login Inválido");

        var user = new UserDto
        {
            Email = model.Email,
            Password = model.Password
        };
        user.Token = await _tokenService.CreateToken(user);

        return Ok(user);
    }
}
