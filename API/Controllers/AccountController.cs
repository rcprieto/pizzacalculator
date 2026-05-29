using API.Domain.DTOs;
using API.Domain.Entidades;
using API.Domain.Interfaces.Services;
using API.Helpers;
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
    private readonly IEmailService _emailService;

    public AccountController(UserManager<AppUser> userManager, ITokenService tokenService, IEmailService emailService)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _emailService = emailService;
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

    [HttpPost("esqueci-senha")]
    [AllowAnonymous]
    public async Task<ActionResult> EsqueciSenha(EsqueciSenhaDto model)
    {
        var user = await _userManager.FindByEmailAsync(model.Email);
        // Resposta genérica para não vazar se o email existe
        if (user == null || !user.Status)
            return Ok();

        var novaSenha = SenhaHelper.Gerar();
        var token = await _userManager.GeneratePasswordResetTokenAsync(user);
        var resultado = await _userManager.ResetPasswordAsync(user, token, novaSenha);
        if (!resultado.Succeeded)
            return BadRequest("Não foi possível redefinir a senha");

        var corpo = $@"
            <div style='font-family:sans-serif;max-width:480px;margin:0 auto'>
              <h2 style='color:#3d200e'>Pizza Calculator</h2>
              <p>Sua senha foi redefinida com sucesso.</p>
              <p>Acesse com a senha temporária abaixo e altere assim que possível:</p>
              <p style='font-size:22px;font-weight:bold;letter-spacing:2px;color:#c07a0a'>{novaSenha}</p>
              <p style='color:#999;font-size:12px'>Se não solicitou a redefinição, ignore este e-mail.</p>
            </div>";

        await _emailService.EnviarAsync(user.Email!, "Sua nova senha - Pizza Calculator", corpo);
        return Ok();
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

        var senha = SenhaHelper.Gerar();
        var user = new AppUser
        {
            UserName = model.Email.ToLower(),
            Email = model.Email.ToLower(),
            EmailConfirmed = true,
            Status = true
        };

        var resultado = await _userManager.CreateAsync(user, senha);
        if (!resultado.Succeeded)
            return BadRequest(resultado.Errors.Select(e => e.Description));

        await _userManager.AddToRoleAsync(user, "User");

        var corpo = $@"
            <div style='font-family:sans-serif;max-width:480px;margin:0 auto'>
              <h2 style='color:#3d200e'>Pizza Calculator</h2>
              <p>Seu acesso foi criado! Use as credenciais abaixo para entrar:</p>
              <p><strong>E-mail:</strong> {user.Email}</p>
              <p><strong>Senha:</strong> <span style='font-size:20px;font-weight:bold;letter-spacing:2px;color:#c07a0a'>{senha}</span></p>
              <p style='color:#999;font-size:12px'>Recomendamos alterar a senha após o primeiro acesso.</p>
            </div>";

        await _emailService.EnviarAsync(user.Email!, "Seu acesso - Pizza Calculator", corpo);

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

        var emailAtual = User.FindFirst(System.Security.Claims.ClaimTypes.Email)?.Value;
        if (user.Email == emailAtual)
            return BadRequest("Não é possível excluir o próprio usuário");

        user.Status = false;
        await _userManager.UpdateAsync(user);
        return NoContent();
    }
}
