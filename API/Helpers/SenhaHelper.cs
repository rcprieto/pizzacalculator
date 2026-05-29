using System.Security.Cryptography;

namespace API.Helpers;

public static class SenhaHelper
{
    private const string Maiusculas = "ABCDEFGHJKLMNPQRSTUVWXYZ";
    private const string Minusculas = "abcdefghjkmnpqrstuvwxyz";
    private const string Digitos    = "23456789";
    private const string Especiais  = "!@#$%&*";

    public static string Gerar(int tamanho = 12)
    {
        var todos = Maiusculas + Minusculas + Digitos + Especiais;
        var senha = new char[tamanho];

        // Garante ao menos 1 de cada categoria exigida pelo Identity
        senha[0] = Maiusculas[RandomNumberGenerator.GetInt32(Maiusculas.Length)];
        senha[1] = Minusculas[RandomNumberGenerator.GetInt32(Minusculas.Length)];
        senha[2] = Digitos[RandomNumberGenerator.GetInt32(Digitos.Length)];
        senha[3] = Especiais[RandomNumberGenerator.GetInt32(Especiais.Length)];

        for (int i = 4; i < tamanho; i++)
            senha[i] = todos[RandomNumberGenerator.GetInt32(todos.Length)];

        // Embaralha para não deixar o padrão previsível
        return new string(senha.OrderBy(_ => RandomNumberGenerator.GetInt32(int.MaxValue)).ToArray());
    }
}
