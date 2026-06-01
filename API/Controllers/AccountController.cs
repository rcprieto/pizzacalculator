using API.Data.Context;
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
    private readonly PizzaCalculatorDbContext _context;

    public AccountController(UserManager<AppUser> userManager, ITokenService tokenService, IEmailService emailService, PizzaCalculatorDbContext context)
    {
        _userManager = userManager;
        _tokenService = tokenService;
        _emailService = emailService;
        _context = context;
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

    [HttpPost("registrar-publico")]
    [AllowAnonymous]
    public async Task<ActionResult> RegistrarPublico(RegisterDto model)
    {
        if (await _userManager.Users.AnyAsync(u => u.Email == model.Email.ToLower()))
            return BadRequest("Este e-mail já possui uma conta cadastrada.");

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
            return BadRequest("Não foi possível criar a conta. Verifique o e-mail e tente novamente.");

        await _userManager.AddToRoleAsync(user, "User");

        var corpo = $@"
            <div style='font-family:sans-serif;max-width:480px;margin:0 auto'>
              <h2 style='color:#3d200e'>🍕 Pizza Calculator</h2>
              <p>Sua conta foi criada com sucesso! Use as credenciais abaixo para entrar no aplicativo:</p>
              <p><strong>E-mail:</strong> {user.Email}</p>
              <p><strong>Senha:</strong></p>
              <p style='font-size:26px;font-weight:bold;letter-spacing:3px;color:#c07a0a;background:#fff8e7;padding:12px 20px;border-radius:8px;display:inline-block'>{senha}</p>
              <p style='margin-top:16px'>Após o primeiro acesso, você pode solicitar a redefinição da senha pela opção <em>Esqueci minha senha</em> no aplicativo.</p>
              <p style='color:#999;font-size:12px;margin-top:24px'>Se você não solicitou este cadastro, ignore este e-mail.</p>
            </div>";

        await _emailService.EnviarAsync(user.Email!, "Bem-vindo ao Pizza Calculator — suas credenciais de acesso", corpo);

        return Ok();
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

    [HttpPost("excluir-conta")]
    [AllowAnonymous]
    public async Task<ActionResult> ExcluirConta(ExcluirContaDto model)
    {
        var user = await _userManager.FindByEmailAsync(model.Email);
        if (user == null || !user.Status)
            return Unauthorized("Email ou senha inválidos");

        var senhaCorreta = await _userManager.CheckPasswordAsync(user, model.Password);
        if (!senhaCorreta)
            return Unauthorized("Email ou senha inválidos");

        // IDs dos ingredientes e grupos do usuário (para limpar referências externas)
        var ingIds = await _context.Ingredientes
            .Where(i => i.UserId == user.Id)
            .Select(i => i.Id)
            .ToListAsync();

        var grupoIds = await _context.IngredienteGrupos
            .Where(g => g.UserId == user.Id)
            .Select(g => g.Id)
            .ToListAsync();

        // Remove ReceitaItens de qualquer receita que referenciem ingredientes do usuário
        if (ingIds.Count > 0)
        {
            var itensReferenciados = await _context.ReceitaItens
                .Where(ri => ingIds.Contains(ri.IngredienteId))
                .ToListAsync();
            _context.ReceitaItens.RemoveRange(itensReferenciados);
        }

        // Remove referência aos grupos do usuário em ReceitaItens de outras receitas
        if (grupoIds.Count > 0)
        {
            var itensComGrupo = await _context.ReceitaItens
                .Where(ri => ri.IngredienteGrupoId.HasValue && grupoIds.Contains(ri.IngredienteGrupoId.Value))
                .ToListAsync();
            foreach (var item in itensComGrupo) item.IngredienteGrupoId = null;
        }

        await _context.SaveChangesAsync();

        // Remove as receitas do usuário (cascade deleta os itens restantes)
        var receitas = await _context.Receitas.Where(r => r.UserId == user.Id).ToListAsync();
        _context.Receitas.RemoveRange(receitas);

        // Remove ingredientes e grupos do usuário (sem ReceitaItens referenciando)
        if (ingIds.Count > 0)
        {
            var ingredientes = await _context.Ingredientes.Where(i => i.UserId == user.Id).ToListAsync();
            _context.Ingredientes.RemoveRange(ingredientes);
        }

        if (grupoIds.Count > 0)
        {
            var grupos = await _context.IngredienteGrupos.Where(g => g.UserId == user.Id).ToListAsync();
            _context.IngredienteGrupos.RemoveRange(grupos);
        }

        await _context.SaveChangesAsync();

        await _userManager.DeleteAsync(user);

        return NoContent();
    }
}
