# Diagramas do Sistema

## Visao Geral

Esta secao contem os diagramas conceituais e logicos do sistema SpendWise, incluindo modelos de dados, diagramas de classes e arquitetura.

## Diagramas Disponiveis

### 1. Modelo Entidade-Relacionamento (MER)

O MER descreve o modelo conceitual de dados do sistema, evidenciando entidades, atributos de negocio, relacionamentos, cardinalidades e regras.

**Documento:** [MER-SpendWise.md](MER-SpendWise.md)

**Principais Entidades:**
- Usuario
- Categoria
- Transacao (Receita e Despesa)
- OrcamentoMensal
- MetaFinanceira
- FechamentoMensal

### 2. Diagrama Entidade-Relacionamento (DER)

O DER representa a estrutura fisica do banco de dados PostgreSQL, incluindo tabelas, colunas, tipos de dados, chaves primarias e estrangeiras.

![DER SpendWise](DER-SpendWise.png)

**Principais Tabelas:**
- `usuarios` - Dados dos usuarios
- `categorias` - Categorias de gastos
- `transacoes` - Receitas e despesas
- `orcamentos_mensais` - Orcamentos por mes
- `metas_financeiras` - Objetivos financeiros
- `fechamentos_mensais` - Consolidacao mensal

### 3. Diagrama de Classes

O diagrama de classes representa a estrutura orientada a objetos do backend, mostrando as entidades do dominio e seus relacionamentos.

![Diagrama de Classes SpendWise](DiagramaDeClasse-SpendWise.png)

**Camadas Representadas:**
- **Domain Layer**: Entidades, Value Objects, Enums
- **Application Layer**: Commands, Queries, Handlers
- **Infrastructure Layer**: Repositorios, DbContext
- **API Layer**: Controllers

## Relacionamentos Principais

### Usuario e Entidades

```
Usuario (1) -----> (0..*) Categoria
Usuario (1) -----> (0..*) Transacao
Usuario (1) -----> (0..*) OrcamentoMensal
Usuario (1) -----> (0..*) MetaFinanceira
Usuario (1) -----> (0..*) FechamentoMensal
```

### Categoria e Transacao

```
Categoria (1) -----> (0..*) Despesa
Receita (nao possui categoria)
```

### Especializacao de Transacao

```
Transacao (abstrata)
    |
    +--- Receita
    |
    +--- Despesa
```

## Regras de Negocio

### R1: Email Unico
`Usuario.email` e unico no dominio.

### R2: Categoria Unica por Usuario
`Categoria.nome` e unico dentro do mesmo usuario.

### R3: Categoria Obrigatoria para Despesa
Despesa deve possuir uma Categoria (participacao total). Receita nao possui categoria.

### R4: Validacoes de Transacao
- `Transacao.valor` > 0
- `Transacao.data` nao pode ser futura

### R5: Orcamento Mensal Unico
Um orcamento por usuario por mes. `valor` >= 0.

### R6: Fechamento Mensal
Um fechamento por usuario por mes. Apos fechar, transacoes do mes ficam imutaveis.

### R7: Meta Financeira
- `valorAlvo` > 0
- `prazo` deve ser data futura

## Cardinalidades

| Relacionamento | Cardinalidade | Participacao |
|----------------|---------------|--------------|
| Usuario - Categoria | 1:N | Parcial |
| Usuario - Transacao | 1:N | Parcial |
| Categoria - Despesa | 1:N | Total (Despesa) |
| Usuario - OrcamentoMensal | 1:N | Parcial |
| Usuario - MetaFinanceira | 1:N | Parcial |
| Usuario - FechamentoMensal | 1:N | Parcial |

## Tipos de Dados Conceituais

### TipoTransacao (Enum)
- `RECEITA` - Entrada de recursos
- `DESPESA` - Saida de recursos

### TipoCategoria (Enum)
- `ESSENCIAL` - Gastos essenciais (moradia, alimentacao, saude)
- `SUPERFLUO` - Gastos nao essenciais (entretenimento, lazer)

### StatusMeta (Enum)
- `ATIVA` - Meta em andamento
- `ALCANCADA` - Meta atingida
- `VENCIDA` - Prazo expirado sem atingir objetivo

## Indices e Otimizacoes

### Indices Principais

**usuarios:**
- PK: `id`
- UNIQUE: `email`

**categorias:**
- PK: `id`
- FK: `usuario_id`
- INDEX: `(usuario_id, nome)` - Busca por usuario e nome

**transacoes:**
- PK: `id`
- FK: `usuario_id`, `categoria_id`
- INDEX: `(usuario_id, data)` - Busca por periodo
- INDEX: `(usuario_id, tipo)` - Filtro por tipo

**orcamentos_mensais:**
- PK: `id`
- FK: `usuario_id`
- UNIQUE: `(usuario_id, mes, ano)` - Um por mes

**metas_financeiras:**
- PK: `id`
- FK: `usuario_id`
- INDEX: `(usuario_id, status)` - Filtro por status

**fechamentos_mensais:**
- PK: `id`
- FK: `usuario_id`
- UNIQUE: `(usuario_id, mes, ano)` - Um por mes

## Consultas Comuns

### Saldo por Mes
```sql
SELECT 
    EXTRACT(YEAR FROM data) as ano,
    EXTRACT(MONTH FROM data) as mes,
    SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE 0 END) as receitas,
    SUM(CASE WHEN tipo = 'DESPESA' THEN valor ELSE 0 END) as despesas,
    SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE -valor END) as saldo
FROM transacoes
WHERE usuario_id = ?
GROUP BY ano, mes
ORDER BY ano DESC, mes DESC;
```

### Gasto por Categoria no Mes
```sql
SELECT 
    c.nome,
    c.limite_mensal,
    SUM(t.valor) as gasto_atual,
    (SUM(t.valor) / c.limite_mensal * 100) as percentual
FROM transacoes t
JOIN categorias c ON t.categoria_id = c.id
WHERE t.usuario_id = ?
  AND t.tipo = 'DESPESA'
  AND EXTRACT(YEAR FROM t.data) = ?
  AND EXTRACT(MONTH FROM t.data) = ?
GROUP BY c.id, c.nome, c.limite_mensal;
```

### Progresso de Metas
```sql
SELECT 
    nome,
    valor_objetivo,
    valor_atual,
    (valor_atual / valor_objetivo * 100) as percentual_progresso,
    (valor_objetivo - valor_atual) as valor_restante,
    (prazo - CURRENT_DATE) as dias_restantes,
    status
FROM metas_financeiras
WHERE usuario_id = ?
  AND status = 'ATIVA'
ORDER BY prazo ASC;
```

## Evolucao do Modelo

### Versao 1.0 (MVP)
- Entidades basicas: Usuario, Categoria, Transacao
- Relacionamentos fundamentais
- Regras de negocio essenciais

### Versao 1.1 (Atual)
- Adicao de OrcamentoMensal
- Adicao de FechamentoMensal
- Adicao de MetaFinanceira
- Especializacao de Transacao (Receita/Despesa)
- Validacoes aprimoradas

### Versao Futura (Planejado)
- Notificacoes (alertas de limite)
- Anexos (comprovantes de transacoes)
- Compartilhamento (orcamento familiar)
- Recorrencia (transacoes automaticas)

## Referencias

- [MER Completo](MER-SpendWise.md) - Modelo Entidade-Relacionamento detalhado
- [Backend Architecture](../backend/clean-architecture.md) - Arquitetura do backend
- [Domain Layer](../backend/domain.md) - Camada de dominio
- [Database Schema](../backend/infrastructure.md#database) - Schema do banco de dados

## Ferramentas Utilizadas

- **Modelagem Conceitual**: Draw.io, Lucidchart
- **Banco de Dados**: PostgreSQL 15
- **ORM**: Entity Framework Core 8
- **Migrations**: EF Core Migrations
