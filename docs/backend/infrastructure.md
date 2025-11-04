# Infrastructure Layer

A camada de infraestrutura contém implementações concretas de interfaces definidas no domínio, incluindo acesso a dados, serviços externos e configurações.

## Princípios

- **Implementação de Interfaces**: Implementa interfaces do domínio
- **Entity Framework Core**: ORM para acesso a dados
- **PostgreSQL**: Banco de dados relacional
- **Dependency Injection**: Injeção de dependências

## Estrutura

```
SpendWise.Infrastructure/
 Data/
    ApplicationDbContext.cs
    Configurations/
       UsuarioConfiguration.cs
       CategoriaConfiguration.cs
       TransacaoConfiguration.cs
       OrcamentoMensalConfiguration.cs
       FechamentoMensalConfiguration.cs
       MetaConfiguration.cs
    Migrations/
 Repositories/
    Repository.cs
    UsuarioRepository.cs
    CategoriaRepository.cs
    TransacaoRepository.cs
    OrcamentoMensalRepository.cs
    FechamentoMensalRepository.cs
    MetaRepository.cs
    UnitOfWork.cs
 Services/
     JwtService.cs
     PasswordHasher.cs
     TokenService.cs
     MockEmailService.cs
     BrevoEmailService.cs
     InMemoryCacheService.cs
```

## Entity Framework Core

### ApplicationDbContext

Contexto principal do banco de dados.

```csharp
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Categoria> Categorias { get; set; }
    public DbSet<Transacao> Transacoes { get; set; }
    public DbSet<OrcamentoMensal> OrcamentosMensais { get; set; }
    public DbSet<FechamentoMensal> FechamentosMensais { get; set; }
    public DbSet<Meta> Metas { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplicar configurações
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Auditoria automática
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
```

### Configurações de Entidades

Cada entidade tem sua configuração Fluent API.

**UsuarioConfiguration.cs:**

```csharp
public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("Usuarios");

        builder.HasKey(u => u.Id);

        builder.Property(u => u.Nome)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(200);

        builder.HasIndex(u => u.Email)
            .IsUnique();

        builder.Property(u => u.SenhaHash)
            .IsRequired();

        builder.Property(u => u.NotificacoesAtivas)
            .HasDefaultValue(true);

        // Relacionamentos
        builder.HasMany(u => u.Categorias)
            .WithOne()
            .HasForeignKey(c => c.UsuarioId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.Transacoes)
            .WithOne()
            .HasForeignKey(t => t.UsuarioId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

**TransacaoConfiguration.cs:**

```csharp
public class TransacaoConfiguration : IEntityTypeConfiguration<Transacao>
{
    public void Configure(EntityTypeBuilder<Transacao> builder)
    {
        builder.ToTable("Transacoes");

        builder.HasKey(t => t.Id);

        builder.Property(t => t.Descricao)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(t => t.Valor)
            .HasColumnType("decimal(18,2)")
            .IsRequired();

        builder.Property(t => t.Data)
            .IsRequired();

        builder.Property(t => t.Tipo)
            .IsRequired()
            .HasConversion<int>();

        // Índices para performance
        builder.HasIndex(t => t.UsuarioId);
        builder.HasIndex(t => t.CategoriaId);
        builder.HasIndex(t => t.Data);
        builder.HasIndex(t => new { t.UsuarioId, t.Data });

        // Relacionamentos
        builder.HasOne<Categoria>()
            .WithMany()
            .HasForeignKey(t => t.CategoriaId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

### Migrations

Migrations são geradas automaticamente pelo EF Core.

**Comandos:**

```bash
# Criar migration
dotnet ef migrations add NomeDaMigration

# Aplicar migrations
dotnet ef database update

# Reverter migration
dotnet ef database update PreviousMigration

# Gerar script SQL
dotnet ef migrations script
```

## Repositórios

### Repository Base

Implementação genérica do `IRepository<T>`.

```csharp
public class Repository<T> : IRepository<T> where T : class
{
    protected readonly ApplicationDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public Repository(ApplicationDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public virtual async Task<T?> GetByIdAsync(Guid id)
    {
        return await _dbSet.FindAsync(id);
    }

    public virtual async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public virtual async Task<T> AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
        return entity;
    }

    public virtual async Task UpdateAsync(T entity)
    {
        _dbSet.Update(entity);
        await Task.CompletedTask;
    }

    public virtual async Task DeleteAsync(T entity)
    {
        _dbSet.Remove(entity);
        await Task.CompletedTask;
    }
}
```

### TransacaoRepository

Repositório específico com queries otimizadas.

```csharp
public class TransacaoRepository : Repository<Transacao>, ITransacaoRepository
{
    public TransacaoRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IEnumerable<Transacao>> GetByPeriodoAsync(
        int mes, 
        int ano, 
        Guid usuarioId,
        TipoTransacao? tipo = null,
        Guid? categoriaId = null)
    {
        var query = _dbSet
            .Include(t => t.Categoria)
            .Where(t => t.UsuarioId == usuarioId
                     && t.Data.Month == mes
                     && t.Data.Year == ano);

        if (tipo.HasValue)
        {
            query = query.Where(t => t.Tipo == tipo.Value);
        }

        if (categoriaId.HasValue)
        {
            query = query.Where(t => t.CategoriaId == categoriaId.Value);
        }

        return await query
            .OrderByDescending(t => t.Data)
            .ToListAsync();
    }

    public async Task<decimal> GetTotalByCategoriaAsync(
        Guid categoriaId, 
        int mes, 
        int ano)
    {
        return await _dbSet
            .Where(t => t.CategoriaId == categoriaId
                     && t.Data.Month == mes
                     && t.Data.Year == ano
                     && t.Tipo == TipoTransacao.Despesa)
            .SumAsync(t => t.Valor);
    }

    public async Task<Dictionary<Guid, decimal>> GetTotaisPorCategoriaAsync(
        Guid usuarioId, 
        int mes, 
        int ano)
    {
        return await _dbSet
            .Where(t => t.UsuarioId == usuarioId
                     && t.Data.Month == mes
                     && t.Data.Year == ano
                     && t.Tipo == TipoTransacao.Despesa
                     && t.CategoriaId != null)
            .GroupBy(t => t.CategoriaId.Value)
            .Select(g => new { CategoriaId = g.Key, Total = g.Sum(t => t.Valor) })
            .ToDictionaryAsync(x => x.CategoriaId, x => x.Total);
    }
}
```

### UnitOfWork

Implementa o padrão Unit of Work para transações.

```csharp
public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<int> CommitAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task RollbackAsync()
    {
        await Task.CompletedTask;
        // EF Core não precisa de rollback explícito
        // Se não chamar SaveChanges, as mudanças são descartadas
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
```

## Serviços

### JwtService

Serviço para geração e validação de tokens JWT.

```csharp
public class JwtService
{
    private readonly IConfiguration _configuration;

    public string GenerateToken(Usuario usuario)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, usuario.Id.ToString()),
            new Claim(ClaimTypes.Email, usuario.Email),
            new Claim(ClaimTypes.Name, usuario.Nome)
        };

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["JWT:SecretKey"]));
        
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["JWT:Issuer"],
            audience: _configuration["JWT:Audience"],
            claims: claims,
            expires: DateTime.Now.AddDays(7),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public ClaimsPrincipal? ValidateToken(string token)
    {
        var tokenHandler = new JwtSecurityTokenHandler();
        var key = Encoding.UTF8.GetBytes(_configuration["JWT:SecretKey"]);

        try
        {
            var principal = tokenHandler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(key),
                ValidateIssuer = true,
                ValidIssuer = _configuration["JWT:Issuer"],
                ValidateAudience = true,
                ValidAudience = _configuration["JWT:Audience"],
                ValidateLifetime = true,
                ClockSkew = TimeSpan.Zero
            }, out SecurityToken validatedToken);

            return principal;
        }
        catch
        {
            return null;
        }
    }
}
```

### PasswordHasher

Serviço para hash de senhas com BCrypt.

```csharp
public class PasswordHasher
{
    public string HashPassword(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool VerifyPassword(string password, string hash)
    {
        return BCrypt.Net.BCrypt.Verify(password, hash);
    }
}
```

### TokenService

Serviço para geração de tokens seguros.

```csharp
public class TokenService
{
    public string GenerateSecureToken()
    {
        var randomBytes = new byte[32];
        using (var rng = RandomNumberGenerator.Create())
        {
            rng.GetBytes(randomBytes);
        }
        return Convert.ToBase64String(randomBytes);
    }

    public DateTime GetTokenExpiry(int minutes = 30)
    {
        return DateTime.UtcNow.AddMinutes(minutes);
    }
}
```

### MockEmailService

Serviço mock para desenvolvimento (loga no console).

```csharp
public class MockEmailService : IEmailService
{
    private readonly ILogger<MockEmailService> _logger;

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        _logger.LogInformation("EMAIL MOCK - Para: {To}", to);
        _logger.LogInformation("EMAIL MOCK - Assunto: {Subject}", subject);
        _logger.LogInformation("EMAIL MOCK - Corpo: {Body}", body);
        
        await Task.CompletedTask;
    }

    public async Task SendPasswordResetEmailAsync(string to, string token, string email)
    {
        var resetUrl = $"http://localhost:3000/redefinir-senha?token={token}&email={email}";
        
        _logger.LogInformation("EMAIL MOCK - Reset de Senha");
        _logger.LogInformation("EMAIL MOCK - Para: {To}", to);
        _logger.LogInformation("EMAIL MOCK - URL: {Url}", resetUrl);
        
        await Task.CompletedTask;
    }
}
```

### BrevoEmailService

Serviço real para produção (Brevo/Sendinblue).

```csharp
public class BrevoEmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        var apiKey = _configuration["EmailSettings:ApiKey"];
        var senderEmail = _configuration["EmailSettings:SenderEmail"];
        var senderName = _configuration["EmailSettings:SenderName"];

        var request = new
        {
            sender = new { email = senderEmail, name = senderName },
            to = new[] { new { email = to } },
            subject = subject,
            htmlContent = body
        };

        _httpClient.DefaultRequestHeaders.Add("api-key", apiKey);
        
        var response = await _httpClient.PostAsJsonAsync(
            "https://api.brevo.com/v3/smtp/email", 
            request);

        response.EnsureSuccessStatusCode();
    }
}
```

## Configuração de Dependências

Registro de serviços no `Program.cs`:

```csharp
// Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repositories
builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<ICategoriaRepository, CategoriaRepository>();
builder.Services.AddScoped<ITransacaoRepository, TransacaoRepository>();
builder.Services.AddScoped<IOrcamentoMensalRepository, OrcamentoMensalRepository>();
builder.Services.AddScoped<IFechamentoMensalRepository, FechamentoMensalRepository>();
builder.Services.AddScoped<IMetaRepository, MetaRepository>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();

// Services
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<PasswordHasher>();
builder.Services.AddScoped<TokenService>();

// Email Service (Mock ou Brevo baseado em configuração)
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddScoped<IEmailService, MockEmailService>();
}
else
{
    builder.Services.AddScoped<IEmailService, BrevoEmailService>();
}
```

## Connection String

Configuração no `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=spendwise;Username=spendwise;Password=spendwise123"
  }
}
```

## Testes

A camada de infraestrutura é testada com:

- **Testes de Repositório**: Queries e persistência
- **Testes de Integração**: Com banco de dados real
- **Testes de Serviços**: Mocks de dependências externas

Localização: `tests/SpendWise.Infrastructure.Tests/`

## Boas Práticas

1. **Configurações Fluent API**: Sempre usar Fluent API para configurações
2. **Índices**: Criar índices para queries frequentes
3. **Async/Await**: Todas as operações são assíncronas
4. **Unit of Work**: Usar para transações complexas
5. **Dependency Injection**: Injetar dependências via construtor
6. **Logging**: Logar operações importantes
7. **Connection Pooling**: Configurar pool de conexões adequadamente
