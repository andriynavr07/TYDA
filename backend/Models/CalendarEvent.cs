using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public enum EventType { deadline, reminder, milestone }

[Table("calendar_events")]
public class CalendarEvent {
    [Column("id")]
    public int Id { get; set; }

    [Column("user_id")]
    public int UserId { get; set; }

    [Column("project_id")]
    public int ProjectId { get; set; }

    [Column("title")]
    [Required]
    public string Title { get; set; } = "";

    [Column("event_date")]
    public DateTime EventDate { get; set; }

    [Column("event_type")]
    public EventType EventType { get; set; } = EventType.deadline;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}