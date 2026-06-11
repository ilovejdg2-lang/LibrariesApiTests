using HackerRank1.DTO;
using HackerRank1.Entities;
using HackerRank1.Helpers;
using HackerRank1.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace HackerRank1.Controllers;

public record TokenResponse(string token);

[ApiController]
public class AuthController : Controller
{
    private readonly IAuthenticationService authenticationService;
    
    private readonly JwtSettings jwtSettings;

    public AuthController(IAuthenticationService _authenticationService, JwtSettings _jwtSettings)
    {
        authenticationService = _authenticationService;
        jwtSettings = _jwtSettings;
    }

    [HttpPost("/login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login(User user) 
    {
        var validuser = await authenticationService.AuthenticateAsync(user.Email, user.Password);
        if (validuser is null)
            return Unauthorized();


        var token = TokenGenerator.GenerateToken(validuser, jwtSettings);

        return Ok(new TokenResponse(token));
    }

}
