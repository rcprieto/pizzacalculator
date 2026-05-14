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
public class IngredienteController : ControllerBase
{
    private readonly IIngredienteRepository _repo;
    private readonly IMapper _mapper;

    public IngredienteController(IIngredienteRepository repo, IMapper mapper)
    {
        _repo = repo;
        _mapper = mapper;
    }

    [HttpGet]
    public async Task<ActionResult<PagedList<IngredienteDto>>> Get([FromQuery] PaginationParams paginationParams)
    {
        var items = await _repo.GetAllPaginatedAsync<IngredienteDto>(
            i => i.Status == true && (string.IsNullOrEmpty(paginationParams.Search) || i.Nome.Contains(paginationParams.Search)),
            paginationParams, _mapper);
        Response.AddPaginationHeader(new PaginationHeader(items.CurrentPage, items.PageSize, items.TotalCount, items.TotalPages));
        return Ok(items);
    }

    [HttpGet("todos")]
    public async Task<ActionResult<IEnumerable<IngredienteDto>>> GetTodos()
    {
        var query = await _repo.GetAllAsync(i => i.Status == true, i => i.Nome);
        return Ok(_mapper.Map<IEnumerable<IngredienteDto>>(query));
    }

    [HttpPost]
    public async Task<ActionResult<IngredienteDto>> Add([FromBody] IngredienteDto model)
    {
        var item = _mapper.Map<Ingrediente>(model);
        item.Status = true;
        await _repo.AddAsync(item);
        if (await _repo.SaveChangesAsync() <= 0) return BadRequest("Erro ao salvar ingrediente");
        model.Id = item.Id;
        return Ok(model);
    }

    [HttpPut]
    public async Task<ActionResult<IngredienteDto>> Update([FromBody] IngredienteDto model)
    {
        var item = await _repo.GetByIdAsync(model.Id);
        if (item == null) return NotFound();
        _mapper.Map(model, item);
        _repo.Update(item);
        return Ok(model);
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> Delete(int id)
    {
        var item = await _repo.GetByIdAsync(id);
        if (item == null) return NotFound();
        item.Status = false;
        _repo.Update(item);
        return NoContent();
    }
}
