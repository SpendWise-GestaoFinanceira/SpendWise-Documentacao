# API - Transações

## 💰 **Endpoints de Transações**

Esta seção documenta todos os endpoints relacionados ao gerenciamento de transações no sistema SpendWise.

---

## **Modelo de Dados**

### **Transaction**
```json
{
  "id": "string (uuid)",
  "descricao": "string",
  "valor": "decimal",
  "tipo": "receita | despesa",
  "data": "datetime",
  "categoriaId": "string (uuid)",
  "categoria": {
    "id": "string (uuid)",
    "nome": "string",
    "cor": "string (hex)"
  },
  "observacoes": "string",
  "tags": ["string"],
  "anexos": ["string"],
  "recorrente": "boolean",
  "recorrencia": {
    "tipo": "mensal | semanal | anual",
    "intervalo": "integer",
    "dataFim": "datetime"
  },
  "usuarioId": "string (uuid)",
  "dataCriacao": "datetime",
  "dataAtualizacao": "datetime"
}
```

### **TransactionSummary**
```json
{
  "totalReceitas": "decimal",
  "totalDespesas": "decimal",
  "saldoLiquido": "decimal",
  "totalTransacoes": "integer",
  "mediaTransacao": "decimal",
  "maiorReceita": "decimal",
  "maiorDespesa": "decimal"
}
```

---

## **GET /api/transacoes**

Lista todas as transações do usuário autenticado.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `tipo` (optional): `receita`, `despesa`, `todas` (default: `todas`)
- `categoriaId` (optional): UUID da categoria
- `dataInicio` (optional): Data início (YYYY-MM-DD)
- `dataFim` (optional): Data fim (YYYY-MM-DD)
- `descricao` (optional): Busca por descrição
- `valorMin` (optional): Valor mínimo
- `valorMax` (optional): Valor máximo
- `page` (optional): Página (default: 1)
- `limit` (optional): Itens por página (default: 50, max: 100)
- `orderBy` (optional): `data`, `valor`, `descricao` (default: `data`)
- `orderDirection` (optional): `asc`, `desc` (default: `desc`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": [
    {
      "id": "trans-123e4567-e89b-12d3-a456-426614174000",
      "descricao": "Supermercado Extra",
      "valor": 156.80,
      "tipo": "despesa",
      "data": "2024-01-20T18:30:00Z",
      "categoriaId": "cat-123e4567-e89b-12d3-a456-426614174000",
      "categoria": {
        "id": "cat-123e4567-e89b-12d3-a456-426614174000",
        "nome": "Alimentação",
        "cor": "#10b981"
      },
      "observacoes": "Compras da semana",
      "tags": ["mercado", "essencial"],
      "anexos": [],
      "recorrente": false,
      "dataCriacao": "2024-01-20T18:35:00Z",
      "dataAtualizacao": "2024-01-20T18:35:00Z"
    },
    {
      "id": "trans-456e7890-e89b-12d3-a456-426614174001",
      "descricao": "Salário Janeiro",
      "valor": 4500.00,
      "tipo": "receita",
      "data": "2024-01-01T00:00:00Z",
      "categoriaId": "cat-456e7890-e89b-12d3-a456-426614174001",
      "categoria": {
        "id": "cat-456e7890-e89b-12d3-a456-426614174001",
        "nome": "Salário",
        "cor": "#3b82f6"
      },
      "observacoes": null,
      "tags": ["salario", "mensal"],
      "anexos": [],
      "recorrente": true,
      "recorrencia": {
        "tipo": "mensal",
        "intervalo": 1,
        "dataFim": null
      },
      "dataCriacao": "2024-01-01T09:00:00Z",
      "dataAtualizacao": "2024-01-01T09:00:00Z"
    }
  ],
  "meta": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 147,
    "itemsPerPage": 50,
    "hasNextPage": true,
    "hasPreviousPage": false
  },
  "summary": {
    "totalReceitas": 5300.00,
    "totalDespesas": 2810.00,
    "saldoLiquido": 2490.00,
    "totalTransacoes": 47,
    "mediaTransacao": 174.47
  }
}
```

---

## 🔍 **GET /api/transacoes/{id}**

Obtém uma transação específica por ID.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da transação

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "trans-123e4567-e89b-12d3-a456-426614174000",
    "descricao": "Supermercado Extra",
    "valor": 156.80,
    "tipo": "despesa",
    "data": "2024-01-20T18:30:00Z",
    "categoriaId": "cat-123e4567-e89b-12d3-a456-426614174000",
    "categoria": {
      "id": "cat-123e4567-e89b-12d3-a456-426614174000",
      "nome": "Alimentação",
      "cor": "#10b981",
      "limite": 800.00,
      "gastoAtual": 520.00
    },
    "observacoes": "Compras da semana - frutas, verduras e proteínas",
    "tags": ["mercado", "essencial", "saudavel"],
    "anexos": [
      {
        "id": "anexo-123",
        "nome": "nota_fiscal.pdf",
        "url": "https://storage.spendwise.com/anexos/anexo-123.pdf",
        "tamanho": 245760,
        "tipo": "application/pdf"
      }
    ],
    "recorrente": false,
    "localizacao": {
      "latitude": -23.5505,
      "longitude": -46.6333,
      "endereco": "Av. Paulista, 1000 - São Paulo, SP"
    },
    "dataCriacao": "2024-01-20T18:35:00Z",
    "dataAtualizacao": "2024-01-20T18:35:00Z"
  }
}
```

---

## ➕ **POST /api/transacoes**

Cria uma nova transação.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "descricao": "Almoço Restaurante",
  "valor": 45.00,
  "tipo": "despesa",
  "data": "2024-01-21T12:30:00Z",
  "categoriaId": "cat-123e4567-e89b-12d3-a456-426614174000",
  "observacoes": "Almoço de negócios",
  "tags": ["restaurante", "trabalho"],
  "recorrente": false
}
```

### **Response 201 - Created**
```json
{
  "success": true,
  "data": {
    "id": "trans-789e0123-e89b-12d3-a456-426614174002",
    "descricao": "Almoço Restaurante",
    "valor": 45.00,
    "tipo": "despesa",
    "data": "2024-01-21T12:30:00Z",
    "categoriaId": "cat-123e4567-e89b-12d3-a456-426614174000",
    "categoria": {
      "id": "cat-123e4567-e89b-12d3-a456-426614174000",
      "nome": "Alimentação",
      "cor": "#10b981"
    },
    "observacoes": "Almoço de negócios",
    "tags": ["restaurante", "trabalho"],
    "anexos": [],
    "recorrente": false,
    "dataCriacao": "2024-01-21T12:35:00Z",
    "dataAtualizacao": "2024-01-21T12:35:00Z"
  }
}
```

### **Response 400 - Bad Request**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Dados inválidos",
    "details": [
      {
        "field": "descricao",
        "message": "Descrição é obrigatória"
      },
      {
        "field": "valor",
        "message": "Valor deve ser maior que zero"
      },
      {
        "field": "categoriaId",
        "message": "Categoria não encontrada"
      }
    ]
  }
}
```

---

## ✏️ **PUT /api/transacoes/{id}**

Atualiza uma transação existente.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da transação

### **Request Body**
```json
{
  "descricao": "Almoço Restaurante Italiano",
  "valor": 52.00,
  "observacoes": "Almoço de negócios - cliente importante",
  "tags": ["restaurante", "trabalho", "italiano"]
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "trans-789e0123-e89b-12d3-a456-426614174002",
    "descricao": "Almoço Restaurante Italiano",
    "valor": 52.00,
    "tipo": "despesa",
    "data": "2024-01-21T12:30:00Z",
    "categoriaId": "cat-123e4567-e89b-12d3-a456-426614174000",
    "categoria": {
      "id": "cat-123e4567-e89b-12d3-a456-426614174000",
      "nome": "Alimentação",
      "cor": "#10b981"
    },
    "observacoes": "Almoço de negócios - cliente importante",
    "tags": ["restaurante", "trabalho", "italiano"],
    "anexos": [],
    "recorrente": false,
    "dataAtualizacao": "2024-01-21T15:20:00Z"
  }
}
```

---

## 🗑️ **DELETE /api/transacoes/{id}**

Exclui uma transação.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da transação

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Transação excluída com sucesso"
}
```

---

## **GET /api/transacoes/resumo**

Obtém resumo das transações por período.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `dia`, `semana`, `mes`, `ano` (default: `mes`)
- `dataInicio` (optional): Data início (YYYY-MM-DD)
- `dataFim` (optional): Data fim (YYYY-MM-DD)
- `categoriaId` (optional): UUID da categoria

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "mes",
    "dataInicio": "2024-01-01",
    "dataFim": "2024-01-31",
    "resumo": {
      "totalReceitas": 5300.00,
      "totalDespesas": 2810.00,
      "saldoLiquido": 2490.00,
      "totalTransacoes": 47,
      "mediaTransacao": 174.47,
      "maiorReceita": 4500.00,
      "maiorDespesa": 350.90,
      "diasComTransacoes": 18
    },
    "evolucaoDiaria": [
      {
        "data": "2024-01-01",
        "receitas": 4500.00,
        "despesas": 0.00,
        "saldo": 4500.00,
        "transacoes": 1
      },
      {
        "data": "2024-01-02",
        "receitas": 0.00,
        "despesas": 156.80,
        "saldo": -156.80,
        "transacoes": 1
      }
    ],
    "porCategoria": [
      {
        "categoria": {
          "id": "cat-123",
          "nome": "Alimentação",
          "cor": "#10b981"
        },
        "valor": 850.00,
        "percentual": 30.2,
        "transacoes": 15
      }
    ]
  }
}
```

---

## **GET /api/transacoes/estatisticas**

Obtém estatísticas avançadas das transações.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)
- `compararPeriodoAnterior` (optional): `true`, `false` (default: `true`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "mensal",
    "estatisticas": {
      "totalReceitas": 5300.00,
      "totalDespesas": 2810.00,
      "saldoLiquido": 2490.00,
      "taxaEconomia": 47.0,
      "mediaDiaria": 90.65,
      "tendencia": "positiva",
      "volatilidade": "baixa"
    },
    "comparacao": {
      "periodoAnterior": {
        "totalReceitas": 4800.00,
        "totalDespesas": 2650.00,
        "saldoLiquido": 2150.00
      },
      "variacao": {
        "receitas": {
          "valor": 500.00,
          "percentual": 10.42
        },
        "despesas": {
          "valor": 160.00,
          "percentual": 6.04
        },
        "saldo": {
          "valor": 340.00,
          "percentual": 15.81
        }
      }
    },
    "padroes": {
      "diaSemanaComMaisGastos": "sexta",
      "horarioComMaisGastos": "18:00-20:00",
      "categoriaComMaiorCrescimento": "Alimentação",
      "mediaPorTransacao": 59.79
    }
  }
}
```

---

## 🔄 **POST /api/transacoes/recorrentes**

Cria uma transação recorrente.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "descricao": "Salário Mensal",
  "valor": 4500.00,
  "tipo": "receita",
  "categoriaId": "cat-456e7890-e89b-12d3-a456-426614174001",
  "dataInicio": "2024-01-01",
  "recorrencia": {
    "tipo": "mensal",
    "intervalo": 1,
    "diaDoMes": 1,
    "dataFim": null
  },
  "observacoes": "Salário fixo mensal"
}
```

### **Response 201 - Created**
```json
{
  "success": true,
  "data": {
    "id": "recorrente-123e4567-e89b-12d3-a456-426614174000",
    "descricao": "Salário Mensal",
    "valor": 4500.00,
    "tipo": "receita",
    "categoriaId": "cat-456e7890-e89b-12d3-a456-426614174001",
    "dataInicio": "2024-01-01",
    "recorrencia": {
      "tipo": "mensal",
      "intervalo": 1,
      "diaDoMes": 1,
      "dataFim": null
    },
    "proximasOcorrencias": [
      "2024-02-01",
      "2024-03-01",
      "2024-04-01"
    ],
    "ativo": true
  }
}
```

---

## 📤 **POST /api/transacoes/importar**

Importa transações de arquivo CSV/Excel.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

### **Request Body (Form Data)**
- `arquivo`: Arquivo CSV/Excel
- `mapeamento`: JSON com mapeamento das colunas
- `ignorarDuplicatas`: boolean (default: true)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "totalLinhas": 150,
    "transacoesImportadas": 142,
    "transacoesIgnoradas": 8,
    "erros": [
      {
        "linha": 15,
        "erro": "Categoria não encontrada: 'Categoria Inexistente'"
      }
    ]
  }
}
```

---

## 📥 **GET /api/transacoes/exportar**

Exporta transações para CSV/Excel.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `formato` (optional): `csv`, `xlsx` (default: `csv`)
- `dataInicio` (optional): Data início (YYYY-MM-DD)
- `dataFim` (optional): Data fim (YYYY-MM-DD)
- `categorias` (optional): IDs das categorias separados por vírgula

### **Response 200 - Success**
```
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="transacoes_2024-01.csv"

Data,Descrição,Valor,Tipo,Categoria,Observações
2024-01-20,Supermercado Extra,156.80,despesa,Alimentação,Compras da semana
2024-01-19,Freelance Design,800.00,receita,Trabalho,Projeto cliente X
```

---

## 📝 **Códigos de Erro**

| Código | Descrição |
|--------|-----------|
| `TRANSACTION_NOT_FOUND` | Transação não encontrada |
| `CATEGORY_NOT_FOUND` | Categoria não encontrada |
| `INVALID_DATE_RANGE` | Intervalo de datas inválido |
| `INVALID_AMOUNT` | Valor da transação inválido |
| `DUPLICATE_TRANSACTION` | Transação duplicada |
| `IMPORT_FAILED` | Falha na importação |
| `EXPORT_FAILED` | Falha na exportação |

---

## 🧪 **Exemplos de Uso**

### **cURL - Criar Transação**
```bash
curl -X POST "https://api.spendwise.com/api/transacoes" \
  -H "Authorization: Bearer seu_token_aqui" \
  -H "Content-Type: application/json" \
  -d '{
    "descricao": "Uber para trabalho",
    "valor": 25.50,
    "tipo": "despesa",
    "data": "2024-01-21T08:30:00Z",
    "categoriaId": "cat-transporte-123",
    "tags": ["transporte", "trabalho"]
  }'
```

### **JavaScript - Listar Transações**
```javascript
const response = await fetch('/api/transacoes?page=1&limit=20&orderBy=data', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const { data: transacoes, meta, summary } = await response.json();
```

### **Python - Obter Resumo**
```python
import requests
from datetime import datetime, timedelta

# Últimos 30 dias
data_fim = datetime.now()
data_inicio = data_fim - timedelta(days=30)

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://api.spendwise.com/api/transacoes/resumo',
    headers=headers,
    params={
        'dataInicio': data_inicio.strftime('%Y-%m-%d'),
        'dataFim': data_fim.strftime('%Y-%m-%d')
    }
)

resumo = response.json()
```

