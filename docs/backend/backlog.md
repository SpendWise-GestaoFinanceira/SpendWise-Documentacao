# Product Backlog - Backend

Este documento contém o backlog completo do backend do SpendWise, organizado por Epics e User Stories.

## Resumo Geral

| Epic | Histórias | Pontos | Status |
|------|-----------|--------|--------|
| Epic 1: Autenticação | 5 | 28 | DONE |
| Epic 2: Categorias | 2 | 21 | DONE |
| Epic 3: Transações | 3 | 29 | DONE |
| Epic 4: Orçamento | 2 | 13 | DONE |
| Epic 5: Fechamento | 2 | 18 | DONE |
| Epic 6: Relatórios | 5 | 34 | DONE |
| Epic 7: Metas | 4 | 26 | DONE |
| Epic 8: Infraestrutura | 13 | 144 | DONE |
| **TOTAL** | **36** | **313** | **DONE** |

## Epic 1: Autenticação e Gerenciamento de Usuários

### SW-001: Cadastro de Usuário
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como um novo usuário, quero me cadastrar no sistema para poder gerenciar minhas finanças pessoais.

**Critérios de Aceitação:**
- Usuário pode se cadastrar com nome, email e senha
- Email deve ser único no sistema
- Senha deve ter mínimo 6 caracteres
- Sistema valida formato de email
- Senha é armazenada com hash seguro
- Retorna erro se email já existir
- Retorna token JWT após cadastro bem-sucedido

**Implementação:**
- Endpoint: `POST /api/auth/register`
- Command: `RegisterUserCommand`
- Handler: `RegisterUserCommandHandler`
- Validator: `RegisterUserCommandValidator`
- Entity: `Usuario`

---

### SW-002: Login de Usuário
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 5

**História:** Como um usuário cadastrado, quero fazer login no sistema para acessar minhas informações financeiras.

**Critérios de Aceitação:**
- Usuário pode fazer login com email e senha
- Sistema valida credenciais
- Retorna token JWT válido por 7 dias
- Token contém ID e email do usuário
- Retorna erro 401 se credenciais inválidas

**Implementação:**
- Endpoint: `POST /api/auth/login`
- Command: `LoginCommand`
- Handler: `LoginCommandHandler`
- Service: `JwtService`

---

### SW-003: Logout de Usuário
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 2

**História:** Como um usuário autenticado, quero fazer logout do sistema para encerrar minha sessão com segurança.

**Implementação:**
- Endpoint: `POST /api/auth/logout`
- Tipo: Operação client-side

---

### SW-004: Recuperação de Senha
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como um usuário que esqueceu a senha, quero solicitar recuperação de senha para poder acessar minha conta novamente.

**Critérios de Aceitação:**
- Usuário pode solicitar recuperação informando email
- Sistema gera token seguro de 32 bytes
- Token é válido por 30 minutos
- Email é enviado com link de redefinição
- Usuário pode redefinir senha com token válido
- Token é invalidado após uso

**Implementação:**
- Endpoints: `POST /api/auth/forgot-password`, `POST /api/auth/reset-password`
- Commands: `ForgotPasswordCommand`, `ResetPasswordCommand`
- Service: `IEmailService` (MockEmailService em dev, Brevo em prod)

---

### SW-005: Perfil de Usuário
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero visualizar e editar meu perfil para manter minhas informações atualizadas.

**Critérios de Aceitação:**
- Usuário pode visualizar seu perfil
- Usuário pode editar nome
- Usuário pode ativar/desativar notificações
- Sistema valida dados antes de salvar

**Implementação:**
- Endpoints: `GET /api/usuarios/perfil`, `PUT /api/usuarios/perfil`
- Query: `GetUserProfileQuery`
- Command: `UpdateUserProfileCommand`

---

## Epic 2: Gestão de Categorias

### SW-010: CRUD de Categorias
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 13

**História:** Como um usuário autenticado, quero gerenciar categorias de gastos para organizar minhas transações financeiras.

**Critérios de Aceitação:**
- Usuário pode criar categoria com nome, tipo e cor
- Tipo pode ser ESSENCIAL ou SUPERFLUO
- Usuário pode listar todas suas categorias
- Usuário pode editar categoria existente
- Usuário pode excluir categoria sem transações
- Sistema impede exclusão de categoria com transações

**Implementação:**
- Endpoints: GET, POST, PUT, DELETE `/api/categorias`
- Commands: `CreateCategoriaCommand`, `UpdateCategoriaCommand`, `DeleteCategoriaCommand`
- Queries: `GetCategoriasQuery`, `GetCategoriaByIdQuery`
- Entity: `Categoria`

---

### SW-011: Limite Financeiro por Categoria
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero definir limite mensal para cada categoria para controlar meus gastos por área.

**Critérios de Aceitação:**
- Usuário pode definir limite mensal opcional para categoria
- Sistema calcula gasto atual da categoria
- Sistema valida se nova despesa excede limite
- Sistema bloqueia transação se exceder limite
- Sistema permite transação se atingir limite exato

**Implementação:**
- Campos em Categoria: `LimiteDefinido`, `LimiteMensal`
- Validação em: `CreateTransacaoCommandHandler`

---

## Epic 3: Gestão de Transações

### SW-020: Registro de Receitas e Despesas
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 13

**História:** Como um usuário autenticado, quero registrar minhas receitas e despesas para acompanhar meu fluxo financeiro.

**Critérios de Aceitação:**
- Usuário pode criar transação do tipo RECEITA ou DESPESA
- Transação deve ter descrição, valor e data
- Valor deve ser positivo
- Data não pode ser futura
- Despesa deve ter categoria obrigatória
- Receita pode ter categoria opcional
- Sistema valida limite de categoria para despesas

**Implementação:**
- Endpoint: `POST /api/transacoes`
- Command: `CreateTransacaoCommand`
- Entity: `Transacao`
- Enum: `TipoTransacao`

---

### SW-021: Listagem de Transações com Filtros
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero listar minhas transações com filtros para encontrar transações específicas facilmente.

**Critérios de Aceitação:**
- Usuário pode listar todas suas transações
- Usuário pode filtrar por mês, ano, tipo e categoria
- Resultados são ordenados por data (mais recente primeiro)

**Implementação:**
- Endpoint: `GET /api/transacoes?mes=1&ano=2024&tipo=Despesa&categoriaId=123`
- Query: `GetTransacoesQuery`

---

### SW-022: Edição e Exclusão de Transações
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero editar e excluir transações para corrigir erros ou remover registros indevidos.

**Critérios de Aceitação:**
- Usuário pode editar transação existente
- Usuário pode alterar todos os campos
- Sistema valida novos dados antes de salvar
- Usuário pode excluir transação
- Sistema impede edição/exclusão de transação de outro usuário

**Implementação:**
- Endpoints: `PUT /api/transacoes/{id}`, `DELETE /api/transacoes/{id}`
- Commands: `UpdateTransacaoCommand`, `DeleteTransacaoCommand`

---

## Epic 4: Orçamento Mensal

### SW-030: Definição de Orçamento Mensal
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero definir um orçamento mensal para controlar meus gastos totais do mês.

**Critérios de Aceitação:**
- Usuário pode criar orçamento para mês/ano específico
- Orçamento tem valor limite total
- Usuário pode ter apenas um orçamento por mês/ano
- Sistema valida se já existe orçamento para o período

**Implementação:**
- Endpoint: `POST /api/orcamentos-mensais`
- Command: `CreateOrcamentoMensalCommand`
- Entity: `OrcamentoMensal`

---

### SW-031: Acompanhamento de Gastos vs Orçamento
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero acompanhar meus gastos em relação ao orçamento para saber se estou dentro do planejado.

**Critérios de Aceitação:**
- Usuário pode visualizar orçamento de mês/ano específico
- Sistema calcula total de despesas do período
- Sistema calcula saldo restante
- Sistema calcula percentual utilizado

**Implementação:**
- Endpoints: `GET /api/orcamentos-mensais`, `GET /api/orcamentos-mensais/{ano}/{mes}`
- Queries: `GetOrcamentosMensaisQuery`, `GetOrcamentoMensalByPeriodoQuery`

---

## Epic 5: Fechamento Mensal

### SW-040: Fechamento Automático do Mês
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 13

**História:** Como um usuário autenticado, quero fechar o mês atual para consolidar minhas finanças do período.

**Critérios de Aceitação:**
- Usuário pode fechar mês/ano específico
- Sistema consolida todas transações do período
- Sistema calcula total de receitas
- Sistema calcula total de despesas
- Sistema calcula saldo final (receitas - despesas)
- Sistema impede fechar mês já fechado
- Data de fechamento é registrada automaticamente

**Implementação:**
- Endpoint: `POST /api/fechamento-mensal`
- Command: `CreateFechamentoMensalCommand`
- Handler: `CreateFechamentoMensalCommandHandler`
- Entity: `FechamentoMensal`

---

### SW-041: Histórico de Fechamentos
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero visualizar histórico de fechamentos para acompanhar a evolução das minhas finanças.

**Critérios de Aceitação:**
- Usuário pode listar todos fechamentos realizados
- Lista é ordenada por data (mais recente primeiro)
- Cada fechamento mostra mês, ano, receitas, despesas e saldo
- Usuário pode visualizar detalhes de fechamento específico
- Sistema retorna apenas fechamentos do usuário autenticado

**Implementação:**
- Endpoints: `GET /api/fechamento-mensal`, `GET /api/fechamento-mensal/{id}`
- Queries: `GetFechamentosMensaisQuery`, `GetFechamentoMensalByIdQuery`

---

## Epic 6: Relatórios e Análises

### SW-050: Relatório por Categoria
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero ver relatório de gastos por categoria para identificar onde gasto mais.

**Implementação:**
- Endpoint: `GET /api/transacoes/relatorio-categoria?mes=1&ano=2024`
- Query: `GetRelatorioPorCategoriaQuery`

---

### SW-051: Evolução Mensal
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero ver evolução mensal das minhas finanças para identificar tendências ao longo do tempo.

**Implementação:**
- Endpoint: `GET /api/transacoes/evolucao-mensal?ano=2024`
- Query: `GetEvolucaoMensalQuery`

---

### SW-060: Exportação para CSV
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero exportar minhas transações para CSV para analisar em outras ferramentas.

**Implementação:**
- Endpoint: `GET /api/transacoes/export-csv?mes=1&ano=2024`
- Query: `ExportTransacoesToCsvQuery`

---

### SW-061: Importação de CSV
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero importar transações de arquivo CSV para migrar dados de outras ferramentas.

**Implementação:**
- Endpoint: `POST /api/transacoes/import-csv`
- Command: `ImportTransacoesFromCsvCommand`

---

### SW-062: Comparativo entre Meses
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero comparar dois meses diferentes para identificar variações nos meus gastos.

**Implementação:**
- Endpoint: `GET /api/transacoes/comparativo-meses?mes1=1&ano1=2024&mes2=12&ano2=2023`
- Query: `GetComparativoMesesQuery`

---

## Epic 7: Metas Financeiras

### SW-070: Criação de Metas
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero criar metas financeiras para planejar objetivos de longo prazo.

**Implementação:**
- Endpoint: `POST /api/metas`
- Command: `CreateMetaCommand`
- Entity: `Meta`

---

### SW-071: Acompanhamento de Progresso
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 8

**História:** Como um usuário autenticado, quero acompanhar progresso das minhas metas para saber quanto falta para alcançar.

**Implementação:**
- Endpoints: `GET /api/metas`, `GET /api/metas/{id}`, `PATCH /api/metas/{id}/progresso`
- Queries: `GetMetasQuery`, `GetMetaByIdQuery`
- Command: `UpdateMetaProgressoCommand`

---

### SW-072: Edição e Exclusão de Metas
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero editar e excluir metas para ajustar meus objetivos conforme necessário.

**Implementação:**
- Endpoints: `PUT /api/metas/{id}`, `DELETE /api/metas/{id}`
- Commands: `UpdateMetaCommand`, `DeleteMetaCommand`

---

### SW-073: Estatísticas de Metas
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 5

**História:** Como um usuário autenticado, quero ver estatísticas gerais das minhas metas para ter visão consolidada dos meus objetivos.

**Implementação:**
- Endpoints: `GET /api/metas/estatisticas`, `GET /api/metas/vencidas`, `GET /api/metas/alcancadas`
- Queries: `GetMetasEstatisticasQuery`, `GetMetasVencidasQuery`, `GetMetasAlcancadasQuery`

---

## Epic 8: Infraestrutura e Qualidade

### SW-080: Clean Architecture
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 21

**História:** Como desenvolvedor, quero implementar Clean Architecture para ter código organizado e manutenível.

---

### SW-081: CQRS com MediatR
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 13

**História:** Como desenvolvedor, quero implementar CQRS com MediatR para separar comandos de consultas.

---

### SW-082: Entity Framework Core
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 13

**História:** Como desenvolvedor, quero usar Entity Framework Core para persistência de dados.

---

### SW-083: Repository Pattern
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como desenvolvedor, quero implementar Repository Pattern para abstrair acesso a dados.

---

### SW-084: Autenticação JWT
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como desenvolvedor, quero implementar autenticação JWT para proteger endpoints.

---

### SW-085: Validações com FluentValidation
**Status:** DONE | **Prioridade:** MUST HAVE | **Pontos:** 8

**História:** Como desenvolvedor, quero usar FluentValidation para validar dados de entrada.

---

### SW-086: Logging com Serilog
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como desenvolvedor, quero implementar logging estruturado para rastrear operações.

---

### SW-087: Health Checks
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como DevOps, quero health checks para monitorar saúde da aplicação.

---

### SW-088: Docker e Docker Compose
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como DevOps, quero containerizar a aplicação para facilitar deploy.

---

### SW-089: Serviço de Email
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 8

**História:** Como desenvolvedor, quero serviço de email para enviar notificações.

---

### SW-090: Testes Unitários
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 21

**História:** Como desenvolvedor, quero testes unitários para garantir qualidade do código.

---

### SW-091: Documentação da API
**Status:** DONE | **Prioridade:** SHOULD HAVE | **Pontos:** 5

**História:** Como desenvolvedor frontend, quero documentação da API para integrar corretamente.

---

### SW-092: CI/CD com GitHub Actions
**Status:** DONE | **Prioridade:** COULD HAVE | **Pontos:** 13

**História:** Como DevOps, quero pipeline CI/CD para automatizar build e testes.

---

## Tecnologias Utilizadas

**Backend:**
- ASP.NET Core 9.0
- Entity Framework Core
- PostgreSQL
- MediatR
- FluentValidation
- AutoMapper
- Serilog
- JWT Authentication

**DevOps:**
- Docker
- Docker Compose
- GitHub Actions

**Testes:**
- xUnit
- Moq
- FluentAssertions

## Padrões Implementados

- Clean Architecture
- CQRS (Command Query Responsibility Segregation)
- Repository Pattern
- Unit of Work
- Domain-Driven Design (DDD)
- Value Objects
- Rich Domain Model
- Dependency Injection
- Pipeline Behaviors
