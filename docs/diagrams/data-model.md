# Modelo de Dados - SpendWise

## **Modelo Entidade-Relacionamento (MER)**

O SpendWise utiliza um modelo de dados robusto baseado em **Domain-Driven Design (DDD)** e princípios de **Clean Architecture**.

---

## **Diagrama Entidade-Relacionamento (DER)**

### **Visão Geral do Banco de Dados**

![Diagrama Entidade-Relacionamento](../assets/DER-SpendWise.png)

O diagrama acima mostra a estrutura física do banco de dados PostgreSQL, incluindo:

- **Tabelas** com tipos de dados específicos
- **Chaves primárias** e **estrangeiras**
- **Índices** para otimização de consultas
- **Constraints** para integridade referencial

---

## **Modelo Conceitual (MER)**

### **1. Objetivo**
Descrever o **modelo conceitual de dados** do sistema, evidenciando **entidades**, **atributos de negócio**, **relacionamentos**, **cardinalidades** e **regras**.

### **2. Convenções**
- **Cardinalidade**:
  - `1` = exatamente um
  - `0..*` = zero ou muitos
  - `1..*` = um ou muitos
- **Participação**:
  - **Total** = obrigatório no relacionamento
  - **Parcial** = opcional
- **Especialização/Generalização (EER)**: `Transação` especializa em `Receita` e `Despesa`

---

## **Entidades e Atributos**

### **3.1 Usuário**
- **Descrição**: Pessoa titular das informações financeiras
- **Atributos**: `identificador`, `nome`, `email`, `criadoEm`, `atualizadoEm`
- **Regras**: `email` é **único** no domínio

```sql
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **3.2 Categoria**
- **Descrição**: Classifica **despesas** segundo prioridade
- **Atributos**: `nome`, `limiteMensal`, `tipo` (*ESSENCIAL* | *SUPERFLUO*), `criadoEm`
- **Regras**: `nome` é **único por usuário**; `limiteMensal` é **≥ 0**

```sql
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    nome VARCHAR(50) NOT NULL,
    limite_mensal DECIMAL(10,2) CHECK (limite_mensal >= 0),
    tipo VARCHAR(20) CHECK (tipo IN ('ESSENCIAL', 'SUPERFLUO')),
    cor VARCHAR(7) DEFAULT '#10b981',
    icone VARCHAR(50) DEFAULT 'folder',
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, nome)
);
```

### **3.3 Transação (abstrata)**
- **Descrição**: Movimento financeiro atômico
- **Atributos**: `valor`, `data`, `descricao`, `criadoEm`
- **Regras**:
  - `valor` **> 0** (o sinal é dado pela especialização)
  - `data` **não pode ser futura**

```sql
CREATE TABLE transacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    categoria_id UUID REFERENCES categorias(id),
    descricao VARCHAR(200) NOT NULL,
    valor DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA')),
    data DATE NOT NULL CHECK (data <= CURRENT_DATE),
    observacoes TEXT,
    tags TEXT[],
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Regra: Despesa deve ter categoria, Receita não
    CONSTRAINT chk_categoria_despesa 
        CHECK ((tipo = 'DESPESA' AND categoria_id IS NOT NULL) 
               OR (tipo = 'RECEITA' AND categoria_id IS NULL))
);
```

### **3.4 Receita** *(especialização de Transação)*
- **Descrição**: Entrada de recursos
- **Atributos específicos**: `fonte`, `recorrente`
- **Regras**: **não possui categoria** (por regra de domínio)

### **3.5 Despesa** *(especialização de Transação)*
- **Descrição**: Saída de recursos
- **Regras**: **deve pertencer a uma Categoria** (participação total)

### **3.6 OrçamentoMensal**
- **Descrição**: Limite global de gasto por `anoMes` para um usuário
- **Atributos**: `anoMes`, `valor`, `criadoEm`
- **Regras**: **um por usuário por mês**; `valor` **≥ 0**

```sql
CREATE TABLE orcamentos_mensais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    ano_mes DATE NOT NULL, -- Primeiro dia do mês
    valor DECIMAL(10,2) NOT NULL CHECK (valor >= 0),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, ano_mes)
);
```

### **3.7 MetaFinanceira**
- **Descrição**: Objetivo de poupança/investimento
- **Atributos**: `descricao`, `valorAlvo`, `prazo`, `criadoEm`
- **Regras**: `valorAlvo` **> 0**; `prazo` **no futuro**

```sql
CREATE TABLE metas_financeiras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    descricao VARCHAR(200) NOT NULL,
    valor_alvo DECIMAL(10,2) NOT NULL CHECK (valor_alvo > 0),
    prazo DATE NOT NULL CHECK (prazo > CURRENT_DATE),
    valor_atual DECIMAL(10,2) DEFAULT 0,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **3.8 FechamentoMensal**
- **Descrição**: Evento que **consolida** um mês e **bloqueia** alterações
- **Atributos**: `anoMes`, `fechadoEm`
- **Regras**: **um por usuário por mês**

```sql
CREATE TABLE fechamentos_mensais (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL REFERENCES usuarios(id),
    ano_mes DATE NOT NULL, -- Primeiro dia do mês
    total_receitas DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_despesas DECIMAL(10,2) NOT NULL DEFAULT 0,
    saldo_liquido DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_transacoes INTEGER NOT NULL DEFAULT 0,
    fechado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, ano_mes)
);
```

---

## **Relacionamentos e Cardinalidades**

### **1. Usuário — Categoria**
- **Leitura**: Um **Usuário** *possui* **Categorias**
- **Cardinalidade**: `Usuário 1` — `Categoria 0..*`
- **Participação**: Em `Categoria`, **parcial**
- **Regra**: `Categoria.nome` é **único por usuário**

### **2. Usuário — Transação**
- **Leitura**: Um **Usuário** *realiza* **Transações**
- **Cardinalidade**: `Usuário 1` — `Transação 0..*`
- **Participação**: Em `Transação`, **parcial**

### **3. Categoria — Despesa**
- **Leitura**: Uma **Categoria** *classifica* **Despesas**
- **Cardinalidade**: `Categoria 1` — `Despesa 0..*`
- **Participação**: Em `Despesa`, **total**
- **Observação**: **Receitas não se relacionam a Categoria**

### **4. Usuário — OrçamentoMensal**
- **Leitura**: Um **Usuário** *define* **Orçamentos Mensais**
- **Cardinalidade**: `Usuário 1` — `OrçamentoMensal 0..*`
- **Regra**: **No máximo 1 por `anoMes`**

### **5. Usuário — MetaFinanceira**
- **Leitura**: Um **Usuário** *estabelece* **Metas Financeiras**
- **Cardinalidade**: `Usuário 1` — `MetaFinanceira 0..*`

### **6. Usuário — FechamentoMensal**
- **Leitura**: Um **Usuário** *executa* **Fechamentos Mensais**
- **Cardinalidade**: `Usuário 1` — `FechamentoMensal 0..*`
- **Regra**: **No máximo 1 por `anoMes`**; após fechamento, transações ficam **imutáveis**

---

## **Regras de Negócio**

### **Regras de Integridade**
- **R1**. `Usuario.email` é **único** no domínio
- **R2**. `Categoria.nome` é **único dentro do mesmo usuário**
- **R3**. *Despesa* **deve** possuir uma *Categoria*; *Receita* **não** possui categoria
- **R4**. `Transacao.valor` **> 0**; `Transacao.data` **não pode ser futura**
- **R5**. `OrcamentoMensal`: **um por usuário por mês**; `valor` **≥ 0**
- **R6**. `FechamentoMensal`: **um por usuário por mês**; após fechar, **não se alteram** transações
- **R7**. `MetaFinanceira`: `valorAlvo` **> 0**; `prazo` **futuro**

### **Regras de Domínio**
```sql
-- Trigger para impedir alteração de transações em mês fechado
CREATE OR REPLACE FUNCTION check_mes_fechado()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM fechamentos_mensais 
        WHERE usuario_id = NEW.usuario_id 
        AND ano_mes = DATE_TRUNC('month', NEW.data)
    ) THEN
        RAISE EXCEPTION 'Não é possível alterar transações de mês fechado';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_mes_fechado
    BEFORE INSERT OR UPDATE ON transacoes
    FOR EACH ROW EXECUTE FUNCTION check_mes_fechado();
```

---

## **Índices para Performance**

```sql
-- Índices para otimização de consultas
CREATE INDEX idx_transacoes_usuario_data ON transacoes(usuario_id, data);
CREATE INDEX idx_transacoes_categoria ON transacoes(categoria_id);
CREATE INDEX idx_transacoes_tipo_data ON transacoes(tipo, data);
CREATE INDEX idx_categorias_usuario ON categorias(usuario_id);
CREATE INDEX idx_orcamentos_usuario_mes ON orcamentos_mensais(usuario_id, ano_mes);
CREATE INDEX idx_fechamentos_usuario_mes ON fechamentos_mensais(usuario_id, ano_mes);

-- Índice parcial para transações ativas
CREATE INDEX idx_transacoes_ativas ON transacoes(usuario_id, data) 
WHERE NOT EXISTS (
    SELECT 1 FROM fechamentos_mensais f 
    WHERE f.usuario_id = transacoes.usuario_id 
    AND f.ano_mes = DATE_TRUNC('month', transacoes.data)
);
```

---

## **Consultas Típicas**

### **Saldo por Mês**
```sql
SELECT 
    DATE_TRUNC('month', data) as mes,
    SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE 0 END) as receitas,
    SUM(CASE WHEN tipo = 'DESPESA' THEN valor ELSE 0 END) as despesas,
    SUM(CASE WHEN tipo = 'RECEITA' THEN valor ELSE -valor END) as saldo
FROM transacoes 
WHERE usuario_id = $1
GROUP BY DATE_TRUNC('month', data)
ORDER BY mes;
```

### **Gasto por Categoria no Mês**
```sql
SELECT 
    c.nome,
    c.limite_mensal,
    COALESCE(SUM(t.valor), 0) as gasto_atual,
    ROUND((COALESCE(SUM(t.valor), 0) / c.limite_mensal) * 100, 2) as percentual_usado
FROM categorias c
LEFT JOIN transacoes t ON c.id = t.categoria_id 
    AND t.tipo = 'DESPESA'
    AND DATE_TRUNC('month', t.data) = DATE_TRUNC('month', CURRENT_DATE)
WHERE c.usuario_id = $1 AND c.ativo = true
GROUP BY c.id, c.nome, c.limite_mensal
ORDER BY gasto_atual DESC;
```

### **Alertas de Limite**
```sql
SELECT 
    c.nome,
    c.limite_mensal,
    SUM(t.valor) as gasto_atual,
    ROUND((SUM(t.valor) / c.limite_mensal) * 100, 2) as percentual
FROM categorias c
JOIN transacoes t ON c.id = t.categoria_id
WHERE c.usuario_id = $1 
    AND t.tipo = 'DESPESA'
    AND DATE_TRUNC('month', t.data) = DATE_TRUNC('month', CURRENT_DATE)
    AND c.limite_mensal > 0
GROUP BY c.id, c.nome, c.limite_mensal
HAVING SUM(t.valor) >= (c.limite_mensal * 0.8) -- 80% do limite
ORDER BY percentual DESC;
```

---

## **Observações de Design**

### **Do Conceitual para o Físico**
- **Categoria obrigatória só para Despesa**: Implementada via `CHECK CONSTRAINT`
- **Orçamento/Fechamento por mês**: Usa `DATE` representando o 1º dia do mês
- **Especialização** `Transação → Receita|Despesa`: Implementada como **Single Table Inheritance** com coluna `tipo`

### **Padrões Utilizados**
- **UUID** como chave primária para melhor distribuição
- **Timestamps** automáticos para auditoria
- **Soft Delete** com coluna `ativo` quando aplicável
- **Check Constraints** para regras de domínio
- **Triggers** para regras complexas

---

## **Glossário**

- **anoMes**: Período no formato mês/ano; no físico é `DATE` (1º dia do mês)
- **Participação total**: A entidade **não existe** sem o relacionamento
- **Disjunção**: Uma instância participa de **uma única** especialização
- **Soft Delete**: Exclusão lógica mantendo dados físicos
- **Single Table Inheritance**: Uma tabela para hierarquia de classes

