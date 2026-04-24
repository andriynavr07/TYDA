using System.ComponentModel.DataAnnotations.Schema;

[Table("project_tags")]
public class ProjectTag {
    [Column("project_id")]
    public int ProjectId { get; set; }

    [Column("tag_id")]
    public int TagId { get; set; }
}