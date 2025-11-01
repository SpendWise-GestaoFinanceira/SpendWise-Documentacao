# Backend - Introdução

## **Arquitetura do Backend**

O backend do SpendWise foi desenvolvido seguindo os princípios de **Clean Architecture** e **Domain-Driven Design (DDD)**, garantindo uma arquitetura robusta, testável e manutenível.

### **Tecnologias Utilizadas**

- **ASP.NET Core 8.0** - Framework web moderno
- **Entity Framework Core** - ORM para acesso a dados
- **PostgreSQL** - Banco de dados relacional
- **MediatR** - Implementação do padrão Mediator
- **FluentValidation** - Validação de dados
- **AutoMapper** - Mapeamento de objetos
- **Serilog** - Logging estruturado
- **xUnit** - Framework de testes

### **Princípios Aplicados**

#### **Clean Architecture**
- **Separação de responsabilidades** em camadas bem definidas
- **Inversão de dependências** através de interfaces
- **Testabilidade** com alta cobertura de testes

#### **Domain-Driven Design**
- **Rich Domain Models** com lógica de negócio encapsulada
- **Value Objects** para conceitos de domínio
- **Aggregates** para consistência transacional
- **Domain Services** para lógicas complexas

#### **CQRS (Command Query Responsibility Segregation)**
- **Commands** para operações de escrita
- **Queries** para operações de leitura
- **Handlers** especializados para cada operação

### **📁 Estrutura do Projeto**

```
SpendWise.Backend/
├── src/
│   ├── SpendWise.Domain/           # Camada de Domínio
│   │   ├── Entities/              # Entidades de domínio
│   │   ├── ValueObjects/          # Objetos de valor
│   │   ├── Aggregates/            # Agregados
│   │   └── Services/              # Serviços de domínio
│   ├── SpendWise.Application/      # Camada de Aplicação
│   │   ├── Commands/              # Comandos CQRS
│   │   ├── Queries/               # Consultas CQRS
│   │   ├── Handlers/              # Manipuladores
│   │   └── DTOs/                  # Objetos de transferência
│   ├── SpendWise.Infrastructure/   # Camada de Infraestrutura
│   │   ├── Data/                  # Contexto EF Core
│   │   ├── Repositories/          # Implementação de repositórios
│   │   └── Services/              # Serviços externos
│   └── SpendWise.API/             # Camada de Apresentação
│       ├── Controllers/           # Controladores Web API
│       ├── Middlewares/           # Middlewares customizados
│       └── Configuration/         # Configurações
└── tests/
    ├── SpendWise.Domain.Tests/    # Testes de domínio
    ├── SpendWise.Application.Tests/ # Testes de aplicação
    └── SpendWise.API.Tests/       # Testes de integração
```

### **Fluxo de Dados**

1. **Controller** recebe a requisição HTTP
2. **MediatR** roteia para o Handler apropriado
3. **Handler** executa a lógica de negócio
4. **Repository** persiste/recupera dados
5. **Response** é retornado ao cliente

### **Métricas de Qualidade**

- **Cobertura de Testes**: >90%
- **Complexidade Ciclomática**: <10
- **Duplicação de Código**: <3%
- **Debt Ratio**: <5%

### **Próximos Passos**

- [Clean Architecture](clean-architecture.md) - Detalhes da arquitetura
- [Domain Layer](domain.md) - Camada de domínio
- [Application Layer](application.md) - Camada de aplicação
- [Infrastructure Layer](infrastructure.md) - Camada de infraestrutura
- [API Layer](api.md) - Camada de apresentação

