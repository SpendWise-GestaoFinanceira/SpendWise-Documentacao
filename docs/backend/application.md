# Application Layer

A camada de aplicação contém a lógica de aplicação, coordenando o fluxo de dados entre a camada de domínio e a camada de apresentação.

## Princípios

- **CQRS**: Separação entre Commands (escrita) e Queries (leitura)
- **MediatR**: Mediator pattern para desacoplar handlers
- **Validação**: FluentValidation para validar requests
- **DTOs**: Data Transfer Objects para comunicação entre camadas

## Estrutura

```
SpendWise.Application/
├── Commands/
│   ├── Auth/
│   ├── Categorias/
│   ├── Transacoes/
│   ├── OrcamentosMensais/
│   ├── FechamentoMensal/
│   └── Metas/
├── Queries/
│   ├── Auth/
│   ├── Categorias/
│   ├── Transacoes/
│   ├── OrcamentosMensais/
│   ├── FechamentoMensal/
│   ├── Metas/
│   └── Relatorios/
├── Handlers/
│   ├── Auth/
│   ├── Categorias/
│   ├── Transacoes/
│   ├── OrcamentosMensais/
│   ├── FechamentoMensal/
│   ├── Metas/
│   └── Relatorios/
├── Validators/
│   ├── Auth/
│   ├── Categorias/
│   ├── Transacoes/
│   ├── OrcamentosMensais/
│   ├── FechamentoMensal/
│   └── Metas/
├── DTOs/
│   ├── Auth/
│   ├── Categorias/
│   ├── Transacoes/
│   ├── OrcamentosMensais/
│   ├── FechamentoMensal/
│   ├── Metas/
│   └── Relatorios/
├── Behaviors/
│   ├── ValidationBehavior.cs
│   └── LoggingBehavior.cs
└── Services/
    └── ExportService.cs
```

## CQRS Pattern

### Commands (Escrita)

Commands representam intenções de modificar o estado do sistema.

**Características:**
- Modificam dados
- Retornam resultado de sucesso/falha
- Validados antes da execução
- Podem falhar

**Exemplo:**

```csharp
public class CreateTransacaoCommand : IRequest<Result<TransacaoDto>>
{
    public string Descricao { get; set; }
    public decimal Valor { get; set; }
    public DateTime Data { get; set; }
    public TipoTransacao Tipo { get; set; }
    public Guid? CategoriaId { get; set; }
    public Guid UsuarioId { get; set; }
}
```

### Queries (Leitura)

Queries representam consultas de dados sem modificação.

**Características:**
- Apenas leitura
- Não modificam estado
- Podem ser cacheadas
- Sempre retornam dados

**Exemplo:**

```csharp
public class GetTransacoesByPeriodoQuery : IRequest<Result<List<TransacaoDto>>>
{
    public int Mes { get; set; }
    public int Ano { get; set; }
    public Guid UsuarioId { get; set; }
    public TipoTransacao? Tipo { get; set; }
    public Guid? CategoriaId { get; set; }
}
```

## Handlers

Handlers processam Commands e Queries.

### Command Handler

```csharp
public class CreateTransacaoCommandHandler 
    : IRequestHandler<CreateTransacaoCommand, Result<TransacaoDto>>
{
    private readonly ITransacaoRepository _repository;
    private readonly ICategoriaRepository _categoriaRepository;
    private readonly IUnitOfWork _unitOfWork;

    public async Task<Result<TransacaoDto>> Handle(
        CreateTransacaoCommand request, 
        CancellationToken cancellationToken)
    {
        // 1. Validar categoria (se despesa)
        if (request.Tipo == TipoTransacao.Despesa && request.CategoriaId.HasValue)
        {
            var categoria = await _categoriaRepository.GetByIdAsync(request.CategoriaId.Value);
            
            // Validar limite de categoria
            if (categoria.LimiteDefinido)
            {
                var gastoAtual = await _repository.GetTotalByCategoriaAsync(
                    categoria.Id, request.Data.Month, request.Data.Year);
                
                if (gastoAtual + request.Valor > categoria.LimiteMensal)
                {
                    return Result<TransacaoDto>.Failure("Limite da categoria excedido");
                }
            }
        }

        // 2. Criar entidade
        var transacao = new Transacao
        {
            Descricao = request.Descricao,
            Valor = new Money(request.Valor),
            Data = request.Data,
            Tipo = request.Tipo,
            CategoriaId = request.CategoriaId,
            UsuarioId = request.UsuarioId
        };

        // 3. Persistir
        await _repository.AddAsync(transacao);
        await _unitOfWork.CommitAsync();

        // 4. Retornar DTO
        var dto = MapToDto(transacao);
        return Result<TransacaoDto>.Success(dto);
    }
}
```

### Query Handler

```csharp
public class GetTransacoesByPeriodoQueryHandler 
    : IRequestHandler<GetTransacoesByPeriodoQuery, Result<List<TransacaoDto>>>
{
    private readonly ITransacaoRepository _repository;

    public async Task<Result<List<TransacaoDto>>> Handle(
        GetTransacoesByPeriodoQuery request, 
        CancellationToken cancellationToken)
    {
        var transacoes = await _repository.GetByPeriodoAsync(
            request.Mes, 
            request.Ano, 
            request.UsuarioId,
            request.Tipo,
            request.CategoriaId);

        var dtos = transacoes.Select(MapToDto).ToList();
        return Result<List<TransacaoDto>>.Success(dtos);
    }
}
```

## Validação com FluentValidation

Cada Command tem um Validator correspondente.

```csharp
public class CreateTransacaoCommandValidator 
    : AbstractValidator<CreateTransacaoCommand>
{
    public CreateTransacaoCommandValidator()
    {
        RuleFor(x => x.Descricao)
            .NotEmpty().WithMessage("Descrição é obrigatória")
            .MaximumLength(200).WithMessage("Descrição muito longa");

        RuleFor(x => x.Valor)
            .GreaterThan(0).WithMessage("Valor deve ser positivo");

        RuleFor(x => x.Data)
            .LessThanOrEqualTo(DateTime.Now)
            .WithMessage("Data não pode ser futura");

        RuleFor(x => x.CategoriaId)
            .NotEmpty()
            .When(x => x.Tipo == TipoTransacao.Despesa)
            .WithMessage("Categoria é obrigatória para despesas");
    }
}
```

## Pipeline Behaviors

### ValidationBehavior

Executa validações antes de processar o request.

```csharp
public class ValidationBehavior<TRequest, TResponse> 
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        if (_validators.Any())
        {
            var context = new ValidationContext<TRequest>(request);
            
            var validationResults = await Task.WhenAll(
                _validators.Select(v => v.ValidateAsync(context, cancellationToken)));
            
            var failures = validationResults
                .SelectMany(r => r.Errors)
                .Where(f => f != null)
                .ToList();

            if (failures.Count != 0)
            {
                throw new ValidationException(failures);
            }
        }

        return await next();
    }
}
```

### LoggingBehavior

Loga todas as requisições e respostas.

```csharp
public class LoggingBehavior<TRequest, TResponse> 
    : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly ILogger<LoggingBehavior<TRequest, TResponse>> _logger;

    public async Task<TResponse> Handle(
        TRequest request,
        RequestHandlerDelegate<TResponse> next,
        CancellationToken cancellationToken)
    {
        var requestName = typeof(TRequest).Name;
        
        _logger.LogInformation("Handling {RequestName}", requestName);
        
        var response = await next();
        
        _logger.LogInformation("Handled {RequestName}", requestName);
        
        return response;
    }
}
```

## DTOs (Data Transfer Objects)

DTOs são usados para transferir dados entre camadas.

```csharp
public class TransacaoDto
{
    public Guid Id { get; set; }
    public string Descricao { get; set; }
    public decimal Valor { get; set; }
    public DateTime Data { get; set; }
    public TipoTransacao Tipo { get; set; }
    public Guid? CategoriaId { get; set; }
    public string? CategoriaNome { get; set; }
    public string? CategoriaCor { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

## Principais Commands

### Autenticação

- `RegisterUserCommand`: Cadastrar novo usuário
- `LoginCommand`: Fazer login
- `ForgotPasswordCommand`: Solicitar reset de senha
- `ResetPasswordCommand`: Redefinir senha

### Categorias

- `CreateCategoriaCommand`: Criar categoria
- `UpdateCategoriaCommand`: Atualizar categoria
- `DeleteCategoriaCommand`: Excluir categoria
- `ReatribuirTransacoesCommand`: Reatribuir transações para outra categoria

### Transações

- `CreateTransacaoCommand`: Criar transação
- `UpdateTransacaoCommand`: Atualizar transação
- `DeleteTransacaoCommand`: Excluir transação
- `ImportTransacoesFromCsvCommand`: Importar de CSV

### Orçamentos Mensais

- `CreateOrcamentoMensalCommand`: Criar orçamento
- `UpdateOrcamentoMensalCommand`: Atualizar orçamento
- `DeleteOrcamentoMensalCommand`: Excluir orçamento

### Fechamento Mensal

- `FecharMesCommand`: Fechar mês
- `ReabrirMesCommand`: Reabrir mês

### Metas

- `CreateMetaCommand`: Criar meta
- `UpdateMetaCommand`: Atualizar meta
- `DeleteMetaCommand`: Excluir meta
- `UpdateMetaProgressoCommand`: Atualizar progresso

## Principais Queries

### Categorias

- `GetCategoriasQuery`: Listar categorias
- `GetCategoriaByIdQuery`: Buscar por ID
- `GetCategoriasComProgressoQuery`: Listar com progresso de gastos

### Transações

- `GetTransacoesQuery`: Listar transações
- `GetTransacaoByIdQuery`: Buscar por ID
- `GetTransacoesByPeriodoQuery`: Listar por período
- `ExportTransacoesToCsvQuery`: Exportar para CSV

### Orçamentos Mensais

- `GetOrcamentosMensaisQuery`: Listar orçamentos
- `GetOrcamentoMensalByPeriodoQuery`: Buscar por período
- `GetEstatisticasCategoriasQuery`: Estatísticas por categoria

### Fechamento Mensal

- `GetFechamentosMensaisQuery`: Listar fechamentos
- `GetFechamentoMensalByIdQuery`: Buscar por ID

### Metas

- `GetMetasQuery`: Listar metas
- `GetMetaByIdQuery`: Buscar por ID
- `GetMetasEstatisticasQuery`: Estatísticas gerais
- `GetMetasVencidasQuery`: Listar vencidas
- `GetMetasAlcancadasQuery`: Listar alcançadas

### Relatórios

- `GetRelatorioPorCategoriaQuery`: Relatório por categoria
- `GetEvolucaoMensalQuery`: Evolução mensal
- `GetComparativoMesesQuery`: Comparativo entre meses

## Services

### ExportService

Serviço para exportação e importação de dados.

**Métodos:**
- `ExportToCsvAsync`: Exporta transações para CSV
- `ImportFromCsvAsync`: Importa transações de CSV
- `ValidateCsvFormat`: Valida formato do CSV

## Result Pattern

Todas as operações retornam um `Result<T>` para tratamento de erros.

```csharp
public class Result<T>
{
    public bool IsSuccess { get; }
    public T Data { get; }
    public string Error { get; }

    public static Result<T> Success(T data) 
        => new Result<T>(true, data, null);

    public static Result<T> Failure(string error) 
        => new Result<T>(false, default, error);
}
```

## Testes

A camada de aplicação é testada com:

- **Testes Unitários**: Handlers isolados com mocks
- **Testes de Validação**: Validators com casos válidos e inválidos
- **Testes de Integração**: Fluxos completos com banco de dados

Localização: `tests/SpendWise.Application.Tests/`

## Boas Práticas

1. **Handlers Pequenos**: Cada handler faz uma coisa
2. **Validação Explícita**: Validações claras e descritivas
3. **DTOs Simples**: DTOs contêm apenas dados
4. **Separação CQRS**: Commands e Queries separados
5. **Result Pattern**: Tratamento de erros consistente
6. **Logging**: Todas as operações são logadas
7. **Async/Await**: Operações assíncronas por padrão
