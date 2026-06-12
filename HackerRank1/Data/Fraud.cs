using System.ComponentModel.DataAnnotations;

namespace LibraryService.WebAPI.Data
{
    public class Fraud
    {
        [Key]
        public int Id { get; set; }

        public string ImpostorDetails { get; set; } = string.Empty;

        public string ContactInfo { get; set; } = string.Empty;

        public string Comments { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }
    }
}
