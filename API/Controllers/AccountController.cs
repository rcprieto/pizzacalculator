using API.Domain.DTOs;
using API.Domain.Entidades;
using API.Domain.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AccountController : ControllerBase
{
    private readonly UserManager<AppUser> _userManager;
    private readonly ITokenService _tokenService;

    public AccountController(UserManager<AppUser> userManager, ITokenService tokenService)
    {
        _userManager = userManager;
        _tokenService = tokenService;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<UserDto>> Login(LoginDto model)
    {
        var user = await _userManager.FindByEmailAsync(model.Email);
        if (user == null || !user.Status)
            return Unauthorized("Email ou senha inválidos");

        var resultado = await _userManager.CheckPasswordAsync(user, model.Password);
        if (!resultado)
            return Unauthorized("Email ou senha inválidos");

        var roles = await _userManager.GetRolesAsync(user);
        var role = roles.FirstOrDefault() ?? "User";

        return Ok(new UserDto
        {
            Email = user.Email,
            Token = _tokenService.CreateToken(user, role),
            Role = role
        });
    }

    [HttpGet("usuarios")]
    [Authorize(Policy = "RequireAdminRole")]
    public async Task<ActionResult<IEnumerable<UsuarioDto>>> ListarUsuarios()
    {
        var users = await _userManager.Users
            .Where(u => u.Status)
            .OrderBy(u => u.Email)
            .ToListAsync();

        var resultado = new List<UsuarioDto>();
        foreach (var u in users)
        {
            var roles = await _userManager.GetRolesAsync(u);
            resultado.Add(new UsuarioDto
            {
                Id = u.Id,
                Email = u.Email,
                Role = roles.FirstOrDefault() ?? "User",
                Status = u.Status
            });
        }
        return Ok(resultado);
    }

    [HttpPost("registrar")]
    [Authorize(Policy = "RequireAdminRole")]
    public async Task<ActionResult<UsuarioDto>> Registrar(RegisterDto model)
    {
        if (await _userManager.Users.AnyAsync(u => u.Email == model.Email.ToLower()))
            return BadRequest("Email já cadastrado");

        var user = new AppUser
        {
            UserName = model.Email.ToLower(),
            Email = model.Email.ToLower(),
            EmailConfirmed = true,
            Status = true
        };

        var resultado = await _userManager.CreateAsync(user, model.Password);
        if (!resultado.Succeeded)
            return BadRequest(resultado.Errors.Select(e => e.Description));

        await _userManager.AddToRoleAsync(user, "User");

        return Ok(new UsuarioDto
        {
            Id = user.Id,
            Email = user.Email,
            Role = "User",
            Status = true
        });
    }

    [HttpDelete("{id}")]
    [Authorize(Policy = "RequireAdminRole")]
    public async Task<ActionResult> Excluir(string id)
    {
        var user = await _userManager.FindByIdAsync(id);
        if (user == null) return NotFound();

        // Não permite excluir a si mesmo
        var emailAtual = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
        if (user.Email == emailAtual)
            return BadRequest("Não é possível excluir o próprio usuário");

        user.Status = false;
        await _userManager.UpdateAsync(user);
        return NoContent();
    }
}
