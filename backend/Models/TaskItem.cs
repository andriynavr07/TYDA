using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public enum TaskStatus   { todo, in_progress, done }

[Table("tasks")]
public class TaskItem {
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("project_id")]
    public int ProjectId { get; set; }

    [Column("title")]
    [Required]
    public string Title { get; set; } = "";

    [Column("status")]
    public TaskStatus Status { get; set; } = TaskStatus.todo;

    [Column("priority")]
    public short Priority { get; set; } = 0;

    [Column("due_date")]
    public DateOnly? DueDate { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}