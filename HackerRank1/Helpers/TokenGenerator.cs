using HackerRank1.DTO;
using HackerRank1.Entities;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace HackerRank1.Helpers;

public static class TokenGenerator
{
    public static string GenerateToken(User user, JwtSettings jwtSettings) 
    {
        var claims = new[]
        {
            new Claim (ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim (ClaimTypes.Email, user.Email),
            new Claim (ClaimTypes.Role, user.Role)
        };


        // Crea una llave simetrica para utilzar cinfrando el token.
        SymmetricSecurityKey key = new SymmetricSecurityKey (Encoding.UTF8.GetBytes(jwtSettings.SecretKey));

        // Crear la llave que garantiza que el Token fue emitido por este servicio.
        var cred = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Contruye el token
        var token = new JwtSecurityToken(
            issuer: jwtSettings.Issuer,
            audience: jwtSettings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddHours(1),
            signingCredentials: cred
        );        

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

}
