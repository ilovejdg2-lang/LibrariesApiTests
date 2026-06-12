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

        public async Task<Fraud> AddAsync(Fraud fraud)
        {
            fraud.CreatedAt = DateTime.UtcNow;

            await _context.Frauds.AddAsync(fraud);
            await _context.SaveChangesAsync();

            return fraud;
        }
    }

    public interface IFraudService
    {
        Task<IEnumerable<Fraud>> GetAllAsync();
        Task<Fraud> AddAsync(Fraud fraud);
    }
}
