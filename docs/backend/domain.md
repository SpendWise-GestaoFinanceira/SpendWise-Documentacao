# Domain Layer

A camada de domínio contém a lógica de negócio central do sistema, incluindo entidades, value objects, enums e interfaces de repositórios.

## Princípios

- **Independência**: Não depende de nenhuma outra camada
- **Regras de Negócio**: Contém toda a lógica de negócio
- **Imutabilidade**: Entidades e value objects são imutáveis quando possível
- **Validação**: Validações de domínio são feitas nas próprias entidades

## Estrutura

```
SpendWise.Domain/
 Entities/
    Usuario.cs
    Categoria.cs
    Transacao.cs
    OrcamentoMensal.cs
    FechamentoMensal.cs
    Meta.cs
 ValueObjects/
    Email.cs
    Money.cs
    Periodo.cs
 Enums/
    TipoTransacao.cs
    TipoCategoria.cs
    StatusMeta.cs
 Interfaces/
    IRepository.cs
    IUsuarioRepository.cs
    ICategoriaRepository.cs
    ITransacaoRepository.cs
    IOrcamentoMensalRepository.cs
    IFechamentoMensalRepository.cs
    IMetaRepository.cs
    IUnitOfWork.cs
    IEmailService.cs
 Exceptions/
     DomainException.cs
     ValidationException.cs
```

## Entidades

### Usuario

Representa um usuário do sistema.

**Propriedades:**
- `Id` (Guid): Identificador único
- `Nome` (string): Nome completo
- `Email` (Email): Email do usuário (Value Object)
- `SenhaHash` (string): Hash da senha
- `NotificacoesAtivas` (bool): Se notificações estão ativas
- `PasswordResetToken` (string): Token para reset de senha
- `PasswordResetTokenExpiry` (DateTime?): Expiração do token
- `CreatedAt` (DateTime): Data de criação
- `UpdatedAt` (DateTime?): Data de atualização

**Métodos:**
- `SetPasswordResetToken(string token, DateTime expiry)`: Define token de reset
- `ClearPasswordResetToken()`: Limpa token de reset
- `IsPasswordResetTokenValid()`: Verifica se token é válido

### Categoria

Representa uma categoria de transações.

**Propriedades:**
- `Id` (Guid): Identificador único
- `Nome` (string): Nome da categoria
- `Tipo` (TipoCategoria): Essencial ou Supérfluo
- `Cor` (string): Cor em hexadecimal
- `LimiteDefinido` (bool): Se tem limite mensal
- `LimiteMensal` (decimal?): Valor do limite mensal
- `UsuarioId` (Guid): ID do usuário dono
- `CreatedAt` (DateTime): Data de criação
- `UpdatedAt` (DateTime?): Data de atualização

**Regras:**
- Nome é obrigatório
- Cor deve ser hexadecimal válida
- Limite mensal deve ser positivo se definido

### Transacao

Representa uma transação financeira (receita ou despesa).

**Propriedades:**
- `Id` (Guid): Identificador único
- `Descricao` (string): Descrição da transação
- `Valor` (Money): Valor da transação (Value Object)
- `Data` (DateTime): Data da transação
- `Tipo` (TipoTransacao): Receita ou Despesa
- `CategoriaId` (Guid?): ID da categoria (obrigatório para despesas)
- `UsuarioId` (Guid): ID do usuário dono
- `CreatedAt` (DateTime): Data de criação
- `UpdatedAt` (DateTime?): Data de atualização

**Regras:**
- Valor deve ser positivo
- Data não pode ser futura
- Despesas devem ter categoria
- Receitas podem ter categoria opcional

### OrcamentoMensal

Representa o orçamento planejado para um mês.

**Propriedades:**
- `Id` (Guid): Identificador único
- `Mes` (int): Mês (1-12)
- `Ano` (int): Ano
- `ValorLimite` (Money): Valor limite do orçamento
- `UsuarioId` (Guid): ID do usuário dono
- `CreatedAt` (DateTime): Data de criação
- `UpdatedAt` (DateTime?): Data de atualização

**Regras:**
- Mês deve estar entre 1 e 12
- Ano deve ser válido
- Valor limite deve ser positivo
- Apenas um orçamento por mês/ano por usuário

### FechamentoMensal

Representa o fechamento consolidado de um mês.

**Propriedades:**
- `Id` (Guid): Identificador único
- `Mes` (int): Mês (1-12)
- `Ano` (int): Ano
- `TotalReceitas` (Money): Total de receitas
- `TotalDespesas` (Money): Total de despesas
- `Saldo` (Money): Saldo final (receitas - despesas)
- `DataFechamento` (DateTime): Data do fechamento
- `UsuarioId` (Guid): ID do usuário dono
- `CreatedAt` (DateTime): Data de criação

**Regras:**
- Mês deve estar entre 1 e 12
- Ano deve ser válido
- Saldo é calculado automaticamente
- Não pode fechar mês já fechado

### Meta

Representa uma meta financeira do usuário.

**Propriedades:**
- `Id` (Guid): Identificador único
- `Nome` (string): Nome da meta
- `Descricao` (string): Descrição detalhada
- `ValorObjetivo` (Money): Valor a ser alcançado
- `ValorAtual` (Money): Valor atual acumulado
- `Prazo` (DateTime): Data limite
- `Status` (StatusMeta): Ativa, Alcançada ou Vencida
- `UsuarioId` (Guid): ID do usuário dono
- `CreatedAt` (DateTime): Data de criação
- `UpdatedAt` (DateTime?): Data de atualização

**Propriedades Calculadas:**
- `PercentualProgresso`: (ValorAtual / ValorObjetivo) * 100
- `ValorRestante`: ValorObjetivo - ValorAtual
- `DiasRestantes`: Prazo - DateTime.Now

**Regras:**
- Valor objetivo deve ser positivo
- Prazo deve ser data futura
- Status é atualizado automaticamente

## Value Objects

### Email

Representa um endereço de email válido.

**Validações:**
- Formato válido de email
- Não pode ser nulo ou vazio
- Normalizado para lowercase

### Money

Representa um valor monetário.

**Propriedades:**
- `Amount` (decimal): Valor
- `Currency` (string): Moeda (padrão: BRL)

**Validações:**
- Valor deve ser >= 0
- Precisão de 2 casas decimais

### Periodo

Representa um período de tempo (mês/ano).

**Propriedades:**
- `Mes` (int): Mês (1-12)
- `Ano` (int): Ano

**Validações:**
- Mês entre 1 e 12
- Ano válido

## Enums

### TipoTransacao

```csharp
public enum TipoTransacao
{
    Receita = 1,
    Despesa = 2
}
```

### TipoCategoria

```csharp
public enum TipoCategoria
{
    Essencial = 1,
    Superfluo = 2
}
```

### StatusMeta

```csharp
public enum StatusMeta
{
    Ativa = 1,
    Alcancada = 2,
    Vencida = 3
}
```

## Interfaces de Repositório

### IRepository<T>

Interface genérica base para todos os repositórios.

```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);
}
```

### Repositórios Específicos

Cada entidade tem seu repositório específico que estende `IRepository<T>` e adiciona métodos especializados:

- **IUsuarioRepository**: `GetByEmailAsync`, `ExistsByEmailAsync`
- **ICategoriaRepository**: `GetByUsuarioIdAsync`, `GetWithTransacoesAsync`
- **ITransacaoRepository**: `GetByPeriodoAsync`, `GetByCategoriaAsync`
- **IOrcamentoMensalRepository**: `GetByPeriodoAsync`, `ExistsByPeriodoAsync`
- **IFechamentoMensalRepository**: `GetByPeriodoAsync`, `GetByUsuarioIdAsync`
- **IMetaRepository**: `GetByUsuarioIdAsync`, `GetVencidasAsync`, `GetAlcancadasAsync`

## Exceções de Domínio

### DomainException

Exceção base para erros de domínio.

```csharp
public class DomainException : Exception
{
    public DomainException(string message) : base(message) { }
}
```

### ValidationException

Exceção para erros de validação.

```csharp
public class ValidationException : DomainException
{
    public Dictionary<string, string[]> Errors { get; }
    
    public ValidationException(Dictionary<string, string[]> errors) 
        : base("Validation failed")
    {
        Errors = errors;
    }
}
```

## Boas Práticas

1. **Entidades Ricas**: Entidades contêm comportamento, não apenas dados
2. **Validação no Construtor**: Validações são feitas ao criar a entidade
3. **Imutabilidade**: Propriedades são readonly quando possível
4. **Value Objects**: Valores que não têm identidade são value objects
5. **Interfaces de Repositório**: Definem contratos sem implementação
6. **Exceções Específicas**: Exceções de domínio são específicas e descritivas

## Testes

A camada de domínio é testada com testes unitários que verificam:

- Validações de entidades
- Comportamentos de métodos
- Regras de negócio
- Value objects
- Exceções

Localização: `tests/SpendWise.Domain.Tests/`
