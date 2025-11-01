# MER — Sistema de Finanças Pessoais

## 1. Objetivo
Descrever o **modelo conceitual de dados** do sistema, evidenciando **entidades**, **atributos de negócio**, **relacionamentos**, **cardinalidades** e **regras**. Este documento **não** define tipos físicos nem chaves técnicas (isso é assunto do DER).

## 2. Convenções
- **Cardinalidade**:
  - `1` = exatamente um;
  - `0..*` = zero ou muitos;
  - `1..*` = um ou muitos.
- **Participação**:
  - **Total** = obrigatório no relacionamento;
  - **Parcial** = opcional.
- **Especialização/Generalização (EER)**: `Transação` especializa em `Receita` e `Despesa`.

---

## 3. Entidades e Atributos (conceituais)

### 3.1 Usuário
- **Descrição**: pessoa titular das informações financeiras.
- **Atributos**: `identificador`, `nome`, `email`, `criadoEm`, `atualizadoEm`.
- **Notas**: `email` é **único** no domínio (regra conceitual).

### 3.2 Categoria
- **Descrição**: classifica **despesas** segundo prioridade.
- **Atributos**: `nome`, `limiteMensal`, `tipo` (*ESSENCIAL* | *SUPERFLUO*), `criadoEm`.
- **Notas**: `nome` é **único por usuário**; `limiteMensal` é **≥ 0**.

### 3.3 Transação (abstrata)
- **Descrição**: movimento financeiro atômico.
- **Atributos**: `valor`, `data`, `descricao`, `criadoEm`.
- **Notas**:
  - `valor` **> 0** (o sinal é dado pela especialização: receita +, despesa −).
  - `data` **não pode ser futura**.

### 3.4 Receita *(especialização de Transação)*
- **Descrição**: entrada de recursos.
- **Atributos específicos** (opcionais): `fonte`, `recorrente`.
- **Notas**: **não possui categoria** (por regra de domínio).

### 3.5 Despesa *(especialização de Transação)*
- **Descrição**: saída de recursos.
- **Atributos específicos** (opcionais): `essencial?` (derivado de `Categoria.tipo` se preferir manter apenas na Categoria).
- **Notas**: **deve pertencer a uma Categoria** (participação total).

### 3.6 OrçamentoMensal
- **Descrição**: limite global de gasto por `anoMes` para um usuário.
- **Atributos**: `anoMes`, `valor`, `criadoEm`.
- **Notas**: **um por usuário por mês** (unicidade conceitual); `valor` **≥ 0**.

### 3.7 MetaFinanceira
- **Descrição**: objetivo de poupança/investimento.
- **Atributos**: `descricao`, `valorAlvo`, `prazo`, `criadoEm`.
- **Notas**: `valorAlvo` **> 0**; `prazo` **no futuro** (regra conceitual).

### 3.8 FechamentoMensal
- **Descrição**: evento que **consolida** um mês (`anoMes`) e **bloqueia** alterações posteriores nas transações daquele período.
- **Atributos**: `anoMes`, `fechadoEm`.
- **Notas**: **um por usuário por mês** (unicidade conceitual).

---

## 4. Relacionamentos, Cardinalidades e Participação

1) **Usuário — Categoria**
   - **Leitura**: um **Usuário** *possui* **Categorias**.
   - **Cardinalidade**: `Usuário 1` — `Categoria 0..*`.
   - **Participação**: em `Categoria`, **parcial** (um usuário pode ainda não ter categorias).
   - **Regra**: `Categoria.nome` é **único por usuário**.

2) **Usuário — Transação**
   - **Leitura**: um **Usuário** *realiza* **Transações**.
   - **Cardinalidade**: `Usuário 1` — `Transação 0..*`.
   - **Participação**: em `Transação`, **parcial**.

3) **Categoria — Despesa**
   - **Leitura**: uma **Categoria** *classifica* **Despesas**.
   - **Cardinalidade**: `Categoria 1` — `Despesa 0..*`.
   - **Participação**: em `Despesa`, **total** (toda despesa tem categoria).
   - **Observação**: **Receitas não se relacionam a Categoria**.

4) **Usuário — OrçamentoMensal**
   - **Leitura**: um **Usuário** *define* **Orçamentos Mensais**.
   - **Cardinalidade**: `Usuário 1` — `OrçamentoMensal 0..*`.
   - **Regra**: **no máximo 1 por `anoMes`** (unicidade conceitual).

5) **Usuário — MetaFinanceira**
   - **Leitura**: um **Usuário** *estabelece* **Metas Financeiras**.
   - **Cardinalidade**: `Usuário 1` — `MetaFinanceira 0..*`.

6) **Usuário — FechamentoMensal**
   - **Leitura**: um **Usuário** *executa* **Fechamentos Mensais**.
   - **Cardinalidade**: `Usuário 1` — `FechamentoMensal 0..*`.
   - **Regra**: **no máximo 1 por `anoMes`**; após o fechamento, **transações do mês ficam imutáveis**.

7) **Transação — Especializações (EER)**
   - **Leitura**: **Transação** é generalização de **Receita** e **Despesa**.
   - **Disjunção**: **disjunta** (uma transação é **ou** receita **ou** despesa).
   - **Cobertura**: **total** (toda transação pertence a uma das especializações).

---

## 5. Regras de Negócio (conceituais)

- **R1**. `Usuario.email` é **único** no domínio.
- **R2**. `Categoria.nome` é **único dentro do mesmo usuário**.
- **R3**. *Despesa* **deve** possuir uma *Categoria* (participação total); *Receita* **não** possui categoria.
- **R4**. `Transacao.valor` **> 0**; `Transacao.data` **não pode ser futura**.
- **R5**. `OrcamentoMensal`: **um por usuário por mês**; `valor` **≥ 0**.
- **R6**. `FechamentoMensal`: **um por usuário por mês**; após fechar um mês, **não se alteram** transações daquele `anoMes`.
- **R7**. `MetaFinanceira`: `valorAlvo` **> 0**; `prazo` **futuro** (no nível conceitual; validação operacional).

---

## 6. Observações de Design (do conceitual para o lógico)
- **Categoria obrigatória só para Despesa**: expressa conceitualmente na EER; no DER vira **restrição** (ex.: `CHECK` que permite `categoria_id` apenas quando `tipo = DESPESA`).
- **Orçamento/Fechamento por mês**: conceitualmente `anoMes`; no físico costuma virar um `DATE` representando o **1º dia do mês** para facilitar agregações.
- **Especialização** `Transação → Receita|Despesa`: no físico pode ser mapeada como **uma tabela com coluna `tipo`** (Single Table Inheritance) **ou** tabelas separadas (TPT). Conceitualmente, permanece a generalização.

---

## 7. Exemplos de Consultas (apoio à compreensão)
- “Saldo por mês do usuário” → somatório de **Receitas** menos **Despesas** por `anoMes`.
- “Gasto por categoria no mês” → soma de **Despesas** agrupadas por `Categoria`.
- “Alertas” → quando `Categoria.limiteMensal` é atingido/ultrapassado; quando `OrcamentoMensal.valor` é excedido.

---

## 8. Glossário
- **anoMes**: período no formato mês/ano (conceitual); no físico pode ser `DATE` (1º dia do mês).
- **participação total**: a entidade **não existe** no contexto sem o relacionamento (ex.: *Despesa* sem *Categoria* não é válida).
- **disjunção**: uma instância participa de **uma única** especialização.
