using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public enum ProjectStatus { idea, active, pause, done }

[Table("projects")]
public class Project {
    [Column("id")]
    public int Id { get; set; }

    [Column("user_id")]
    public int UserId { get; set; }

    [Column("title")]
    [Required]
    public string Title { get; set; } = "";

    [Column("description")]
    public string? Description { get; set; }

    [Column("status")]
    public ProjectStatus Status { get; set; } = ProjectStatus.idea;

    [Column("progress")]
    public short Progress { get; set; } = 0;

    [Column("deadline")]
    public DateOnly? Deadline { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}