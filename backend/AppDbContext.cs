using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext {
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

    public DbSet<User>          Users          { get; set; }
    public DbSet<Project>       Projects       { get; set; }
    public DbSet<TaskItem>      Tasks          { get; set; }
    public DbSet<Tag>           Tags           { get; set; }
    public DbSet<ProjectTag>    ProjectTags    { get; set; }
    public DbSet<CalendarEvent> CalendarEvents { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder) {

        modelBuilder.Entity<ProjectTag>()
            .HasKey(pt => new { pt.ProjectId, pt.TagId });

        modelBuilder.Entity<Project>()
            .Property(p => p.Status)
            .HasConversion<string>();

        modelBuilder.Entity<TaskItem>()
            .Property(t => t.Status)
            .HasConversion<string>();

        modelBuilder.Entity<CalendarEvent>()
            .Property(e => e.EventType)
            .HasConversion<string>();
    }
}