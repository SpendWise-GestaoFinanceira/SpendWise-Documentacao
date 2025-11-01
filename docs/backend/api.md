# API Layer

A camada de API é responsável por expor endpoints REST, gerenciar requisições HTTP e orquestrar a comunicação entre o cliente e a aplicação.

## Princípios

- **RESTful**: Seguir princípios REST
- **Controllers Magros**: Delegar lógica para handlers
- **Validação**: Validar entrada antes de processar
- **Documentação**: Swagger/OpenAPI para documentação automática

## Estrutura

```
SpendWise.API/
├── Controllers/
│   ├── AuthController.cs
│   ├── UsuariosController.cs
│   ├── CategoriasController.cs
│   ├── TransacoesController.cs
│   ├── OrcamentosMensaisController.cs
│   ├── FechamentoMensalController.cs
│   ├── MetasController.cs
│   ├── RelatoriosController.cs
│   ├── HealthController.cs
│   └── HealthCheckController.cs
├── Middleware/
│   ├── ErrorHandlingMiddleware.cs
│   └── RequestLoggingMiddleware.cs
├── Extensions/
│   └── ClaimsPrincipalExtensions.cs
├── Program.cs
├── appsettings.json
└── appsettings.Development.json
```

## Controllers

### AuthController

Gerencia autenticação e autorização.

```csharp
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IMediator _mediator;

    public AuthController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterUserCommand command)
    {
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginCommand command)
    {
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return Unauthorized(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpPost("forgot-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordCommand command)
    {
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return Ok(new { message = "Email enviado com sucesso" });
    }

    [HttpPost("reset-password")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordCommand command)
    {
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });
        
        return Ok(new { message = "Senha redefinida com sucesso" });
    }
}
```

### TransacoesController

Gerencia transações financeiras.

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TransacoesController : ControllerBase
{
    private readonly IMediator _mediator;

    public TransacoesController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<TransacaoDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(
        [FromQuery] int? mes,
        [FromQuery] int? ano,
        [FromQuery] TipoTransacao? tipo,
        [FromQuery] Guid? categoriaId)
    {
        var usuarioId = User.GetUserId();
        
        var query = new GetTransacoesQuery
        {
            Mes = mes,
            Ano = ano,
            Tipo = tipo,
            CategoriaId = categoriaId,
            UsuarioId = usuarioId
        };

        var result = await _mediator.Send(query);
        return Ok(result.Data);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(TransacaoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id)
    {
        var usuarioId = User.GetUserId();
        
        var query = new GetTransacaoByIdQuery { Id = id, UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpPost]
    [ProducesResponseType(typeof(TransacaoDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateTransacaoCommand command)
    {
        command.UsuarioId = User.GetUserId();
        
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });
        
        return CreatedAtAction(nameof(GetById), new { id = result.Data.Id }, result.Data);
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(TransacaoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateTransacaoCommand command)
    {
        command.Id = id;
        command.UsuarioId = User.GetUserId();
        
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id)
    {
        var usuarioId = User.GetUserId();
        
        var command = new DeleteTransacaoCommand { Id = id, UsuarioId = usuarioId };
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return NoContent();
    }

    [HttpGet("export-csv")]
    [ProducesResponseType(typeof(FileContentResult), StatusCodes.Status200OK)]
    public async Task<IActionResult> ExportCsv(
        [FromQuery] int mes,
        [FromQuery] int ano)
    {
        var usuarioId = User.GetUserId();
        
        var query = new ExportTransacoesToCsvQuery
        {
            Mes = mes,
            Ano = ano,
            UsuarioId = usuarioId
        };

        var result = await _mediator.Send(query);
        
        var fileName = $"transacoes_{ano}_{mes:D2}.csv";
        return File(result.Data, "text/csv", fileName);
    }

    [HttpPost("import-csv")]
    [ProducesResponseType(typeof(ImportResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> ImportCsv(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { error = "Arquivo inválido" });

        var usuarioId = User.GetUserId();
        
        using var stream = file.OpenReadStream();
        using var reader = new StreamReader(stream);
        var csvContent = await reader.ReadToEndAsync();

        var command = new ImportTransacoesFromCsvCommand
        {
            CsvContent = csvContent,
            UsuarioId = usuarioId
        };

        var result = await _mediator.Send(command);
        return Ok(result.Data);
    }
}
```

### MetasController

Gerencia metas financeiras.

```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class MetasController : ControllerBase
{
    private readonly IMediator _mediator;

    public MetasController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<MetaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var usuarioId = User.GetUserId();
        var query = new GetMetasQuery { UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        return Ok(result.Data);
    }

    [HttpGet("{id}")]
    [ProducesResponseType(typeof(MetaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id)
    {
        var usuarioId = User.GetUserId();
        var query = new GetMetaByIdQuery { Id = id, UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpGet("estatisticas")]
    [ProducesResponseType(typeof(MetasEstatisticasDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetEstatisticas()
    {
        var usuarioId = User.GetUserId();
        var query = new GetMetasEstatisticasQuery { UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        return Ok(result.Data);
    }

    [HttpGet("vencidas")]
    [ProducesResponseType(typeof(List<MetaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetVencidas()
    {
        var usuarioId = User.GetUserId();
        var query = new GetMetasVencidasQuery { UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        return Ok(result.Data);
    }

    [HttpGet("alcancadas")]
    [ProducesResponseType(typeof(List<MetaDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAlcancadas()
    {
        var usuarioId = User.GetUserId();
        var query = new GetMetasAlcancadasQuery { UsuarioId = usuarioId };
        var result = await _mediator.Send(query);
        return Ok(result.Data);
    }

    [HttpPost]
    [ProducesResponseType(typeof(MetaDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateMetaCommand command)
    {
        command.UsuarioId = User.GetUserId();
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });
        
        return CreatedAtAction(nameof(GetById), new { id = result.Data.Id }, result.Data);
    }

    [HttpPut("{id}")]
    [ProducesResponseType(typeof(MetaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateMetaCommand command)
    {
        command.Id = id;
        command.UsuarioId = User.GetUserId();
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpPatch("{id}/progresso")]
    [ProducesResponseType(typeof(MetaDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UpdateProgresso(
        Guid id, 
        [FromBody] UpdateMetaProgressoCommand command)
    {
        command.Id = id;
        command.UsuarioId = User.GetUserId();
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error });
        
        return Ok(result.Data);
    }

    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(Guid id)
    {
        var usuarioId = User.GetUserId();
        var command = new DeleteMetaCommand { Id = id, UsuarioId = usuarioId };
        var result = await _mediator.Send(command);
        
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error });
        
        return NoContent();
    }
}
```

## Middleware

### ErrorHandlingMiddleware

Captura e trata exceções globalmente.

```csharp
public class ErrorHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ErrorHandlingMiddleware> _logger;

    public ErrorHandlingMiddleware(
        RequestDelegate next,
        ILogger<ErrorHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (ValidationException ex)
        {
            _logger.LogWarning(ex, "Validation error");
            await HandleValidationExceptionAsync(context, ex);
        }
        catch (DomainException ex)
        {
            _logger.LogWarning(ex, "Domain error");
            await HandleDomainExceptionAsync(context, ex);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleValidationExceptionAsync(
        HttpContext context, 
        ValidationException exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = StatusCodes.Status400BadRequest;

        var response = new
        {
            error = "Validation failed",
            errors = exception.Errors
        };

        return context.Response.WriteAsJsonAsync(response);
    }

    private static Task HandleDomainExceptionAsync(
        HttpContext context, 
        DomainException exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = StatusCodes.Status400BadRequest;

        var response = new { error = exception.Message };
        return context.Response.WriteAsJsonAsync(response);
    }

    private static Task HandleExceptionAsync(
        HttpContext context, 
        Exception exception)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = StatusCodes.Status500InternalServerError;

        var response = new { error = "An error occurred processing your request" };
        return context.Response.WriteAsJsonAsync(response);
    }
}
```

### RequestLoggingMiddleware

Loga todas as requisições HTTP.

```csharp
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(
        RequestDelegate next,
        ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var requestId = Guid.NewGuid().ToString();
        context.Items["RequestId"] = requestId;

        _logger.LogInformation(
            "Request {RequestId}: {Method} {Path}",
            requestId,
            context.Request.Method,
            context.Request.Path);

        var sw = Stopwatch.StartNew();
        
        await _next(context);
        
        sw.Stop();

        _logger.LogInformation(
            "Request {RequestId} completed in {ElapsedMs}ms with status {StatusCode}",
            requestId,
            sw.ElapsedMilliseconds,
            context.Response.StatusCode);
    }
}
```

## Extensions

### ClaimsPrincipalExtensions

Extensões para facilitar acesso a claims do usuário.

```csharp
public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal principal)
    {
        var userIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (string.IsNullOrEmpty(userIdClaim))
            throw new UnauthorizedAccessException("User ID not found in token");
        
        return Guid.Parse(userIdClaim);
    }

    public static string GetUserEmail(this ClaimsPrincipal principal)
    {
        return principal.FindFirst(ClaimTypes.Email)?.Value 
            ?? throw new UnauthorizedAccessException("Email not found in token");
    }

    public static string GetUserName(this ClaimsPrincipal principal)
    {
        return principal.FindFirst(ClaimTypes.Name)?.Value 
            ?? throw new UnauthorizedAccessException("Name not found in token");
    }
}
```

## Program.cs

Configuração principal da aplicação.

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Swagger
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "SpendWise API",
        Version = "v1",
        Description = "API para gerenciamento de finanças pessoais"
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["JWT:SecretKey"])),
            ValidateIssuer = true,
            ValidIssuer = builder.Configuration["JWT:Issuer"],
            ValidateAudience = true,
            ValidAudience = builder.Configuration["JWT:Audience"],
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };
    });

// Health Checks
builder.Services.AddHealthChecks()
    .AddNpgSql(builder.Configuration.GetConnectionString("DefaultConnection"));

// Serilog
builder.Host.UseSerilog((context, configuration) =>
    configuration.ReadFrom.Configuration(context.Configuration));

var app = builder.Build();

// Configure pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseMiddleware<ErrorHandlingMiddleware>();
app.UseMiddleware<RequestLoggingMiddleware>();

app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
```

## Configuração

### appsettings.json

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=spendwise;Username=spendwise;Password=spendwise123"
  },
  "JWT": {
    "SecretKey": "your-secret-key-here",
    "Issuer": "SpendWise",
    "Audience": "SpendWise-Users",
    "ExpirationMinutes": "10080"
  },
  "EmailSettings": {
    "Provider": "Mock",
    "ApiKey": "",
    "SenderEmail": "noreply@spendwise.com",
    "SenderName": "SpendWise"
  }
}
```

## Documentação Swagger

Acesse `/swagger` para visualizar a documentação interativa da API.

## Boas Práticas

1. **Controllers Magros**: Delegar lógica para handlers
2. **Validação**: Validar entrada antes de processar
3. **Autorização**: Proteger endpoints com [Authorize]
4. **Logging**: Logar requisições e erros
5. **CORS**: Configurar CORS adequadamente
6. **Swagger**: Documentar todos os endpoints
7. **Status Codes**: Usar códigos HTTP apropriados
8. **DTOs**: Nunca expor entidades diretamente
