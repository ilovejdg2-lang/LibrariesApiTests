using LibraryService.WebAPI.Data;
using LibraryService.WebAPI.Services;
using Microsoft.AspNetCore.Mvc;

namespace LibraryService.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FraudController : ControllerBase
    {
        private readonly IFraudService _fraudService;

        public FraudController(IFraudService fraudService)
        {
            _fraudService = fraudService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var frauds = await _fraudService.GetAllAsync();
            return Ok(frauds);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Fraud fraud)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _fraudService.AddAsync(fraud);
            return CreatedAtAction(nameof(GetAll), new { id = created.Id }, created);
        }
    }
}
