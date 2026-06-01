using System.Security.Claims;
using API.Domain.DTOs;
using API.Domain.Entidades;
using API.Domain.Helpers;
using API.Domain.Interfaces.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[Authorize(Policy = "RequireUserRole")]
[Route("api/[controller]")]
[ApiController]
public class IngredienteGrupoController : ControllerBase
{
    private readonly IIngredienteGrupoRepository _repo;
    private readonly IMapper _mapper;

    public IngredienteGrupoController(IIngredienteGrupoRepository repo, IMapper mapper)
    {
        _repo = repo;
        _mapper = mapper;
    }

    private string CurrentUserId => User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "";
    private bool IsAdmin => User.IsInRole("Admin");

    [HttpGet]
    public async Task<ActionResult<PagedList<IngredienteGrupoDto>>> Get([FromQuery] PaginationParams paginationParams)
    {
        var userId = CurrentUserId;
        var isAdmin = IsAdmin;
        var items = await _repo.GetAllPaginatedAsync<IngredienteGrupoDto>(
            g => g.Status == true
                && (isAdmin || g.UserId == null || g.UserId == userId)
                && (string.IsNullOrEmpty(paginationParams.Search) || g.Nome.Contains(paginationParams.Search)),
            paginationParams, _mapper);
        Response.AddPaginationHeader(new PaginationHeader(items.CurrentPage, items.PageSize, items.TotalCount, items.TotalPages));
        return Ok(items);
    }

    [HttpGet("todos")]
    public async Task<ActionResult<IEnumerable<IngredienteGrupoDto>>> GetTodos()
    {
        var userId = CurrentUserId;
        var query = await _repo.GetAllAsync(g => g.Status == true && (g.UserId == null || g.UserId == userId), g => g.Nome);
        var lista = _mapper.Map<IEnumerable<IngredienteGrupoDto>>(query);
        return Ok(lista.OrderBy(g => g.Ordem).ThenBy(g => g.Nome));
    }

    [HttpPost]
    public async Task<ActionResult<IngredienteGrupoDto>> Add([FromBody] IngredienteGrupoDto model)
    {
        var item = _mapper.Map<IngredienteGrupo>(model);
        item.Status = true;
        item.UserId = CurrentUserId;
        await _repo.AddAsync(item);
        if (await _repo.SaveChangesAsync() <= 0) return BadRequest("Erro ao salvar grupo");
        model.Id = item.Id;
        model.UserId = item.UserId;
        return Ok(model);
    }

    [HttpPut]
    public async Task<ActionResult<IngredienteGrupoDto>> Update([FromBody] IngredienteGrupoDto model)
    {
        try
        {
            var item = await _repo.GetByIdAsync(model.Id);
            if (item == null) return NotFound();
            if (!IsAdmin && item.UserId != CurrentUserId) return Forbid();
            item.Nome = model.Nome;
            item.Ordem = model.Ordem;
            item.Status = model.Status;
            var ok = _repo.Update(item);
            if (!ok) return BadRequest("Falha ao salvar no banco de dados");
            return Ok(model);
        }
        catch (Exception ex)
        {
            return BadRequest(ex.InnerException?.Message ?? ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var item = await _repo.GetByIdAsync(id);
        if (item == null) return NotFound();
        if (!IsAdmin && item.UserId != CurrentUserId) return Forbid();
        item.Status = false;
        _repo.Update(item);
        return NoContent();
    }
}
