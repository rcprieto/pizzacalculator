using System.Security.Claims;
using API.Domain.DTOs;
using API.Domain.Entidades;
using API.Domain.Helpers;
using API.Domain.Interfaces.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace API.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class ReceitaController : ControllerBase
{
    private readonly IReceitaRepository _repo;
    private readonly IReceitaItemRepository _itemRepo;
    private readonly IMapper _mapper;

    public ReceitaController(IReceitaRepository repo, IReceitaItemRepository itemRepo, IMapper mapper)
    {
        _repo = repo;
        _itemRepo = itemRepo;
        _mapper = mapper;
    }

    private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier);
    private bool IsAdmin => User.IsInRole("Admin");

    // Listagem pública (tela de receitas sem login)
    [AllowAnonymous]
    [HttpGet("publica")]
    public async Task<ActionResult<PagedList<ReceitaDto>>> GetPublica([FromQuery] PaginationParams paginationParams)
    {
        var items = await _repo.GetAllPaginatedAsync<ReceitaDto>(
            r => r.Status == true && (string.IsNullOrEmpty(paginationParams.Search) || r.Nome.Contains(paginationParams.Search)),
            paginationParams, _mapper);
        Response.AddPaginationHeader(new PaginationHeader(items.CurrentPage, items.PageSize, items.TotalCount, items.TotalPages));
        return Ok(items);
    }

    // Listagem admin: Admin vê todas, User vê apenas as suas
    [Authorize(Policy = "RequireUserRole")]
    [HttpGet]
    public async Task<ActionResult<PagedList<ReceitaDto>>> Get([FromQuery] PaginationParams paginationParams)
    {
        var items = await _repo.GetAllPaginatedAsync<ReceitaDto>(
            r => r.Status == true
                && (IsAdmin || r.UserId == UserId)
                && (string.IsNullOrEmpty(paginationParams.Search) || r.Nome.Contains(paginationParams.Search)),
            paginationParams, _mapper);
        Response.AddPaginationHeader(new PaginationHeader(items.CurrentPage, items.PageSize, items.TotalCount, items.TotalPages));
        return Ok(items);
    }

    [AllowAnonymous]
    [HttpGet("{id}")]
    public async Task<ActionResult<ReceitaDto>> GetById(int id)
    {
        var receita = await _repo.GetReceitaComItensAsync(id);
        if (receita == null) return NotFound();
        return Ok(_mapper.Map<ReceitaDto>(receita));
    }

    [Authorize(Policy = "RequireUserRole")]
    [HttpPost]
    public async Task<ActionResult<ReceitaDto>> Add([FromBody] ReceitaDto model)
    {
        var item = _mapper.Map<Receita>(model);
        item.Status = true;
        item.UserId = UserId;
        item.Itens = new List<ReceitaItem>();
        await _repo.AddAsync(item);
        if (await _repo.SaveChangesAsync() <= 0) return BadRequest("Erro ao salvar receita");
        model.Id = item.Id;
        return Ok(model);
    }

    [Authorize(Policy = "RequireUserRole")]
    [HttpPut]
    public async Task<ActionResult<ReceitaDto>> Update([FromBody] ReceitaDto model)
    {
        var item = await _repo.GetByIdAsync(model.Id);
        if (item == null) return NotFound();
        if (!IsAdmin && item.UserId != UserId) return Forbid();
        _mapper.Map(model, item);
        _repo.Update(item);
        return Ok(model);
    }

    [Authorize(Policy = "RequireUserRole")]
    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var item = await _repo.GetByIdAsync(id);
        if (item == null) return NotFound();
        if (!IsAdmin && item.UserId != UserId) return Forbid();
        item.Status = false;
        _repo.Update(item);
        return NoContent();
    }

    // --- Itens da Receita ---

    [Authorize(Policy = "RequireUserRole")]
    [HttpPost("{receitaId}/item")]
    public async Task<ActionResult<ReceitaItemDto>> AddItem(int receitaId, [FromBody] ReceitaItemDto model)
    {
        var receita = await _repo.GetByIdAsync(receitaId);
        if (receita == null) return NotFound();
        if (!IsAdmin && receita.UserId != UserId) return Forbid();

        model.ReceitaId = receitaId;
        var item = _mapper.Map<ReceitaItem>(model);
        await _itemRepo.AddAsync(item);
        if (await _itemRepo.SaveChangesAsync() <= 0) return BadRequest("Erro ao salvar item");
        model.Id = item.Id;
        return Ok(model);
    }

    [Authorize(Policy = "RequireUserRole")]
    [HttpPut("item")]
    public async Task<ActionResult<ReceitaItemDto>> UpdateItem([FromBody] ReceitaItemDto model)
    {
        var item = await _itemRepo.GetByIdAsync(model.Id);
        if (item == null) return NotFound();
        _mapper.Map(model, item);
        _itemRepo.Update(item);
        return Ok(model);
    }

    [Authorize(Policy = "RequireUserRole")]
    [HttpDelete("item/{id}")]
    public async Task<ActionResult> DeleteItem(int id)
    {
        var item = await _itemRepo.GetByIdAsync(id);
        if (item == null) return NotFound();
        _itemRepo.Delete(id);
        return NoContent();
    }
}
