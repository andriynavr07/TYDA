using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;

    public AuthController(AppDbContext db) { _db = db; }

    private static string HashPassword(string password) {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(password));
        return BitConverter.ToString(bytes).Replace("-", "").ToLower();
    }

    [HttpPost("login")]
    public IActionResult Login([FromBody] LoginDto dto) {

        if (dto.EmailOrNickname == "admin@tyda.com" && dto.Password == "Admin1234#")
            return Ok(new { message = "Успішно!", userId = 0, role = "admin" });

        var input = dto.EmailOrNickname.TrimStart('@').Trim();

        var hash = HashPassword(dto.Password);
        var user = _db.Users
            .FirstOrDefault(u => u.PasswordHash == hash &&
                (u.Email == input || u.Nickname == input));

        if (user == null)
            return Unauthorized(new { message = "Невірні дані" });

        return Ok(new { message = "Успішно!", userId = user.Id, role = "user" });
    }

    [HttpPost("register")]
    public IActionResult Register([FromBody] RegisterDto dto) {

        if (_db.Users.Any(u => u.Email == dto.Email))
            return BadRequest(new { message = "Email вже існує" });

        var nickname = dto.Nickname?.TrimStart('@').Trim() ?? null;
        if (nickname == "") nickname = null;

        if (nickname != null && _db.Users.Any(u => u.Nickname == nickname))
            return BadRequest(new { message = "Нікнейм вже зайнятий" });

        _db.Users.Add(new User {
            Email        = dto.Email,
            PasswordHash = HashPassword(dto.Password),
            Name         = dto.Name,
            Nickname     = nickname
        });
        _db.SaveChanges();

        return Ok(new { message = "Зареєстровано!" });
    }

    public record LoginDto(string EmailOrNickname, string Password);
    public record RegisterDto(string Email, string Password, string? Name, string? Nickname);
}