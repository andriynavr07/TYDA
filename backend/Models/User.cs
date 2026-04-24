using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Table("users")]
public class User {
    [Column("id")]
    public int Id { get; set; }

    [Column("email")]
    [Required]
    public string Email { get; set; } = "";

    [Column("password_hash")]
    [Required]
    public string PasswordHash { get; set; } = "";

    [Column("name")]
    public string? Name { get; set; }

    [Column("nickname")]
    public string? Nickname { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}