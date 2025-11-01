# Testes - Backend

Documentação completa sobre a estratégia de testes do backend do SpendWise.

## Visão Geral

O backend possui uma cobertura de testes abrangente, incluindo testes unitários, de integração e de API.

### Estatísticas

- **Cobertura de Código:** 70%+
- **Total de Testes:** 150+
- **Framework:** xUnit
- **Mocking:** Moq
- **Assertions:** FluentAssertions

## Estrutura de Testes

```
tests/
├── SpendWise.Domain.Tests/
│   ├── Entities/
│   ├── ValueObjects/
│   └── coverage.cobertura.xml
├── SpendWise.Application.Tests/
│   ├── Handlers/
│   ├── Validators/
│   └── Core/
├── SpendWise.Infrastructure.Tests/
│   ├── Repositories/
│   └── Data/
└── SpendWise.API.Tests/
    ├── Controllers/
    └── Fixtures/
```

## Testes de Domínio

### Entidades

Testam validações e comportamentos das entidades.

**Exemplo: UsuarioTests.cs**

```csharp
public class UsuarioTests
{
    [Fact]
    public void SetPasswordResetToken_DeveDefinirTokenEExpiracao()
    {
        // Arrange
        var usuario = new Usuario
        {
            Nome = "Teste",
            Email = "teste@teste.com",
            SenhaHash = "hash"
        };
        var token = "token123";
        var expiry = DateTime.UtcNow.AddMinutes(30);

        // Act
        usuario.SetPasswordResetToken(token, expiry);

        // Assert
        usuario.PasswordResetToken.Should().Be(token);
        usuario.PasswordResetTokenExpiry.Should().Be(expiry);
    }

    [Fact]
    public void IsPasswordResetTokenValid_ComTokenExpirado_DeveRetornarFalse()
    {
        // Arrange
        var usuario = new Usuario
        {
            Nome = "Teste",
            Email = "teste@teste.com",
            SenhaHash = "hash",
            PasswordResetToken = "token",
            PasswordResetTokenExpiry = DateTime.UtcNow.AddMinutes(-1)
        };

        // Act
        var result = usuario.IsPasswordResetTokenValid();

        // Assert
        result.Should().BeFalse();
    }
}
```

### Value Objects

Testam validações e comportamentos de value objects.

**Exemplo: MoneyTests.cs**

```csharp
public class MoneyTests
{
    [Fact]
    public void Constructor_ComValorNegativo_DeveLancarException()
    {
        // Act
        Action act = () => new Money(-10);

        // Assert
        act.Should().Throw<ArgumentException>()
            .WithMessage("Valor não pode ser negativo");
    }

    [Fact]
    public void Add_DeveSomarValoresCorretamente()
    {
        // Arrange
        var money1 = new Money(100);
        var money2 = new Money(50);

        // Act
        var result = money1.Add(money2);

        // Assert
        result.Amount.Should().Be(150);
    }
}
```

## Testes de Aplicação

### Handlers

Testam a lógica de negócio dos handlers.

**Exemplo: CreateTransacaoCommandHandlerTests.cs**

```csharp
public class CreateTransacaoCommandHandlerTests
{
    private readonly Mock<ITransacaoRepository> _repositoryMock;
    private readonly Mock<ICategoriaRepository> _categoriaRepositoryMock;
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly CreateTransacaoCommandHandler _handler;

    public CreateTransacaoCommandHandlerTests()
    {
        _repositoryMock = new Mock<ITransacaoRepository>();
        _categoriaRepositoryMock = new Mock<ICategoriaRepository>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        
        _handler = new CreateTransacaoCommandHandler(
            _repositoryMock.Object,
            _categoriaRepositoryMock.Object,
            _unitOfWorkMock.Object);
    }

    [Fact]
    public async Task Handle_ComDadosValidos_DeveCriarTransacao()
    {
        // Arrange
        var command = new CreateTransacaoCommand
        {
            Descricao = "Teste",
            Valor = 100,
            Data = DateTime.Now,
            Tipo = TipoTransacao.Despesa,
            CategoriaId = Guid.NewGuid(),
            UsuarioId = Guid.NewGuid()
        };

        var categoria = new Categoria
        {
            Id = command.CategoriaId.Value,
            Nome = "Teste",
            LimiteDefinido = false
        };

        _categoriaRepositoryMock
            .Setup(x => x.GetByIdAsync(command.CategoriaId.Value))
            .ReturnsAsync(categoria);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        _repositoryMock.Verify(x => x.AddAsync(It.IsAny<Transacao>()), Times.Once);
        _unitOfWorkMock.Verify(x => x.CommitAsync(), Times.Once);
    }

    [Fact]
    public async Task Handle_ExcedendoLimiteCategoria_DeveRetornarErro()
    {
        // Arrange
        var command = new CreateTransacaoCommand
        {
            Descricao = "Teste",
            Valor = 200,
            Data = DateTime.Now,
            Tipo = TipoTransacao.Despesa,
            CategoriaId = Guid.NewGuid(),
            UsuarioId = Guid.NewGuid()
        };

        var categoria = new Categoria
        {
            Id = command.CategoriaId.Value,
            Nome = "Teste",
            LimiteDefinido = true,
            LimiteMensal = 1000
        };

        _categoriaRepositoryMock
            .Setup(x => x.GetByIdAsync(command.CategoriaId.Value))
            .ReturnsAsync(categoria);

        _repositoryMock
            .Setup(x => x.GetTotalByCategoriaAsync(
                categoria.Id, 
                command.Data.Month, 
                command.Data.Year))
            .ReturnsAsync(900);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Contain("Limite da categoria excedido");
    }
}
```

### Validators

Testam as validações com FluentValidation.

**Exemplo: CreateTransacaoCommandValidatorTests.cs**

```csharp
public class CreateTransacaoCommandValidatorTests
{
    private readonly CreateTransacaoCommandValidator _validator;

    public CreateTransacaoCommandValidatorTests()
    {
        _validator = new CreateTransacaoCommandValidator();
    }

    [Fact]
    public void Validate_ComDescricaoVazia_DeveRetornarErro()
    {
        // Arrange
        var command = new CreateTransacaoCommand
        {
            Descricao = "",
            Valor = 100,
            Data = DateTime.Now,
            Tipo = TipoTransacao.Despesa
        };

        // Act
        var result = _validator.Validate(command);

        // Assert
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Descricao");
    }

    [Fact]
    public void Validate_ComValorNegativo_DeveRetornarErro()
    {
        // Arrange
        var command = new CreateTransacaoCommand
        {
            Descricao = "Teste",
            Valor = -10,
            Data = DateTime.Now,
            Tipo = TipoTransacao.Despesa
        };

        // Act
        var result = _validator.Validate(command);

        // Assert
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "Valor");
    }

    [Fact]
    public void Validate_DespesaSemCategoria_DeveRetornarErro()
    {
        // Arrange
        var command = new CreateTransacaoCommand
        {
            Descricao = "Teste",
            Valor = 100,
            Data = DateTime.Now,
            Tipo = TipoTransacao.Despesa,
            CategoriaId = null
        };

        // Act
        var result = _validator.Validate(command);

        // Assert
        result.IsValid.Should().BeFalse();
        result.Errors.Should().Contain(e => e.PropertyName == "CategoriaId");
    }
}
```

## Testes de Infraestrutura

### Repositórios

Testam queries e persistência com banco de dados em memória.

**Exemplo: TransacaoRepositoryTests.cs**

```csharp
public class TransacaoRepositoryTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly TransacaoRepository _repository;

    public TransacaoRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _repository = new TransacaoRepository(_context);
    }

    [Fact]
    public async Task GetByPeriodoAsync_DeveRetornarTransacoesDoMes()
    {
        // Arrange
        var usuarioId = Guid.NewGuid();
        var transacao1 = new Transacao
        {
            Descricao = "Teste 1",
            Valor = 100,
            Data = new DateTime(2024, 1, 15),
            Tipo = TipoTransacao.Despesa,
            UsuarioId = usuarioId
        };
        var transacao2 = new Transacao
        {
            Descricao = "Teste 2",
            Valor = 200,
            Data = new DateTime(2024, 2, 15),
            Tipo = TipoTransacao.Despesa,
            UsuarioId = usuarioId
        };

        await _context.Transacoes.AddRangeAsync(transacao1, transacao2);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetByPeriodoAsync(1, 2024, usuarioId);

        // Assert
        result.Should().HaveCount(1);
        result.First().Descricao.Should().Be("Teste 1");
    }

    [Fact]
    public async Task GetTotalByCategoriaAsync_DeveRetornarSomaCorreta()
    {
        // Arrange
        var categoriaId = Guid.NewGuid();
        var usuarioId = Guid.NewGuid();
        
        var transacoes = new[]
        {
            new Transacao
            {
                Descricao = "Teste 1",
                Valor = 100,
                Data = new DateTime(2024, 1, 15),
                Tipo = TipoTransacao.Despesa,
                CategoriaId = categoriaId,
                UsuarioId = usuarioId
            },
            new Transacao
            {
                Descricao = "Teste 2",
                Valor = 200,
                Data = new DateTime(2024, 1, 20),
                Tipo = TipoTransacao.Despesa,
                CategoriaId = categoriaId,
                UsuarioId = usuarioId
            }
        };

        await _context.Transacoes.AddRangeAsync(transacoes);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetTotalByCategoriaAsync(categoriaId, 1, 2024);

        // Assert
        result.Should().Be(300);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
```

## Testes de API

### Controllers

Testam endpoints com WebApplicationFactory.

**Exemplo: CategoriasControllerTests.cs**

```csharp
public class CategoriasControllerTests : IClassFixture<SpendWiseWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly SpendWiseWebApplicationFactory _factory;

    public CategoriasControllerTests(SpendWiseWebApplicationFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetAll_ComUsuarioAutenticado_DeveRetornarCategorias()
    {
        // Arrange
        var token = await _factory.GetAuthTokenAsync();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);

        // Act
        var response = await _client.GetAsync("/api/categorias");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        var categorias = JsonSerializer.Deserialize<List<CategoriaDto>>(content);
        categorias.Should().NotBeNull();
    }

    [Fact]
    public async Task Create_ComDadosValidos_DeveCriarCategoria()
    {
        // Arrange
        var token = await _factory.GetAuthTokenAsync();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);

        var command = new CreateCategoriaCommand
        {
            Nome = "Teste",
            Tipo = TipoCategoria.Essencial,
            Cor = "#FF0000"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/categorias", command);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var content = await response.Content.ReadAsStringAsync();
        var categoria = JsonSerializer.Deserialize<CategoriaDto>(content);
        categoria.Nome.Should().Be("Teste");
    }

    [Fact]
    public async Task GetAll_SemAutenticacao_DeveRetornar401()
    {
        // Act
        var response = await _client.GetAsync("/api/categorias");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }
}
```

## Executando Testes

### Comandos

```bash
# Executar todos os testes
dotnet test

# Executar com cobertura
dotnet test --collect:"XPlat Code Coverage"

# Executar testes específicos
dotnet test --filter "FullyQualifiedName~TransacaoTests"

# Executar com verbosidade
dotnet test --logger "console;verbosity=detailed"
```

### Gerar Relatório de Cobertura

```bash
# Instalar ReportGenerator
dotnet tool install -g dotnet-reportgenerator-globaltool

# Gerar relatório
reportgenerator \
  -reports:./coverage/**/coverage.cobertura.xml \
  -targetdir:./coverage/report \
  -reporttypes:Html

# Abrir relatório
start ./coverage/report/index.html
```

## CI/CD

Os testes são executados automaticamente no pipeline CI/CD:

```yaml
- name: Run unit tests
  run: dotnet test --no-restore --configuration Release --collect:"XPlat Code Coverage"

- name: Upload coverage
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/**/coverage.cobertura.xml
```

## Boas Práticas

1. **AAA Pattern**: Arrange, Act, Assert
2. **Nomes Descritivos**: Métodos de teste com nomes claros
3. **Testes Isolados**: Cada teste é independente
4. **Mocks**: Usar mocks para dependências externas
5. **Cobertura**: Manter cobertura acima de 70%
6. **Testes Rápidos**: Testes unitários devem ser rápidos
7. **Testes Determinísticos**: Sempre produzem o mesmo resultado
8. **Um Assert por Teste**: Focar em um comportamento por teste

## Métricas

### Cobertura por Camada

- **Domain:** 85%
- **Application:** 75%
- **Infrastructure:** 65%
- **API:** 70%

### Tempo de Execução

- **Testes Unitários:** ~30 segundos
- **Testes de Integração:** ~2 minutos
- **Testes de API:** ~1 minuto

## Ferramentas

- **xUnit:** Framework de testes
- **Moq:** Biblioteca de mocking
- **FluentAssertions:** Assertions fluentes
- **Bogus:** Geração de dados fake
- **WebApplicationFactory:** Testes de integração
- **ReportGenerator:** Relatórios de cobertura
