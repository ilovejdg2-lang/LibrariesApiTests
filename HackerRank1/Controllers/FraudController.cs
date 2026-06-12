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
            try
            {
                var frauds = await _fraudService.GetAllAsync();
                return StatusCode(200, frauds);
            }
            catch (Exception)
            {
                return StatusCode(500, "No se pudieron consultar los reportes. Verifique la conexión con la base de datos.");
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Fraud fraud)
        {
            if (fraud == null)
                return StatusCode(400, "Debe enviar un reporte en el cuerpo de la solicitud.");

            var error = _fraudService.Validate(fraud);
            if (error != null)
                return StatusCode(400, error);

            var created = await _fraudService.AddAsync(fraud);
            return StatusCode(201, created);
        }
    }
}
