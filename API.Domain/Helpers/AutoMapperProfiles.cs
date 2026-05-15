using API.Domain.DTOs;
using API.Domain.Entidades;
using AutoMapper;

namespace API.Domain.Helpers;

public class AutoMapperProfiles : Profile
{
    public AutoMapperProfiles()
    {
        CreateMap<Ingrediente, IngredienteDto>().ReverseMap();

        CreateMap<IngredienteGrupo, IngredienteGrupoDto>().ReverseMap();

        CreateMap<Receita, ReceitaDto>().ReverseMap();

        CreateMap<ReceitaItem, ReceitaItemDto>()
            .ForMember(d => d.IngredienteNome, o => o.MapFrom(s => s.Ingrediente.Nome))
            .ForMember(d => d.IngredienteMarca, o => o.MapFrom(s => s.Ingrediente.Marca))
            .ForMember(d => d.IngredientePreco, o => o.MapFrom(s => s.Ingrediente.Preco))
            .ForMember(d => d.IngredienteGrupoNome, o => o.MapFrom(s => s.IngredienteGrupo != null ? s.IngredienteGrupo.Nome : null))
            .ForMember(d => d.IngredienteGrupoOrdem, o => o.MapFrom(s => s.IngredienteGrupo != null ? s.IngredienteGrupo.Ordem : 0));
        CreateMap<ReceitaItemDto, ReceitaItem>();
    }
}
