namespace API.Domain.Helpers;

public class PaginationParams
{
    private const int MaxPageSize = 50;
    public int PageNumber { get; set; } = 1;
    private int _pageSize = 50;
    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = (value > MaxPageSize) ? MaxPageSize : value;
    }

    public string CurrentUserName { get; set; }
    public string Search { get; set; }
    public string OrderBy { get; set; } = "Nome";
    public string Order { get; set; } = "asc";
}
