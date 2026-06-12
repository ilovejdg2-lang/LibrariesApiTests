using LibraryService.WebAPI.Data;
using Microsoft.EntityFrameworkCore;

namespace LibraryService.WebAPI.Services
{
    public class FraudService : IFraudService
    {
        private readonly LibraryContext _context;

        public FraudService(LibraryContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Fraud>> GetAllAsync()
        {
            return await _context.Frauds
                .OrderByDescending(f => f.CreatedAt)
                .ToListAsync();
        }

        public string? Validate(Fraud fraud)
        {
            if (string.IsNullOrWhiteSpace(fraud.ImpostorDetails))
                return "ImpostorDetails es obligatorio.";

            if (string.IsNullOrWhiteSpace(fraud.ContactInfo))
                return "ContactInfo es obligatorio.";

            return null;
        }

        public async Task<Fraud> AddAsync(Fraud fraud)
        {
            fraud.Comments ??= string.Empty;
            fraud.CreatedAt = DateTime.UtcNow;

            await _context.Frauds.AddAsync(fraud);
            await _context.SaveChangesAsync();

            return fraud;
        }
    }

    public interface IFraudService
    {
        Task<IEnumerable<Fraud>> GetAllAsync();
        string? Validate(Fraud fraud);
        Task<Fraud> AddAsync(Fraud fraud);
    }
}
