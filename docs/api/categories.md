# API - Categorias

## 🏷️ **Endpoints de Categorias**

Esta seção documenta todos os endpoints relacionados ao gerenciamento de categorias no sistema SpendWise.

---

## **Modelo de Dados**

### **Category**
```json
{
  "id": "string (uuid)",
  "nome": "string",
  "descricao": "string",
  "cor": "string (hex)",
  "icone": "string",
  "tipo": "receita | despesa",
  "limite": "decimal",
  "ativo": "boolean",
  "usuarioId": "string (uuid)",
  "dataCriacao": "datetime",
  "dataAtualizacao": "datetime"
}
```

### **CategoryWithStats**
```json
{
  "id": "string (uuid)",
  "nome": "string",
  "descricao": "string",
  "cor": "string (hex)",
  "icone": "string",
  "tipo": "receita | despesa",
  "limite": "decimal",
  "gastoAtual": "decimal",
  "percentualUsado": "decimal",
  "transacoesCount": "integer",
  "ativo": "boolean"
}
```

---

## **GET /api/categorias**

Lista todas as categorias do usuário autenticado.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `tipo` (optional): `receita`, `despesa`, `todas` (default: `todas`)
- `ativo` (optional): `true`, `false` (default: `true`)
- `incluirEstatisticas` (optional): `true`, `false` (default: `false`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": [
    {
      "id": "cat-123e4567-e89b-12d3-a456-426614174000",
      "nome": "Alimentação",
      "descricao": "Gastos com comida e bebida",
      "cor": "#10b981",
      "icone": "utensils",
      "tipo": "despesa",
      "limite": 800.00,
      "gastoAtual": 520.00,
      "percentualUsado": 65.0,
      "transacoesCount": 12,
      "ativo": true,
      "dataCriacao": "2024-01-15T10:30:00Z",
      "dataAtualizacao": "2024-01-20T14:45:00Z"
    },
    {
      "id": "cat-456e7890-e89b-12d3-a456-426614174001",
      "nome": "Salário",
      "descricao": "Renda mensal fixa",
      "cor": "#3b82f6",
      "icone": "briefcase",
      "tipo": "receita",
      "limite": null,
      "gastoAtual": 0.00,
      "percentualUsado": 0.0,
      "transacoesCount": 1,
      "ativo": true,
      "dataCriacao": "2024-01-15T10:30:00Z",
      "dataAtualizacao": "2024-01-15T10:30:00Z"
    }
  ],
  "meta": {
    "total": 8,
    "totalReceitas": 2,
    "totalDespesas": 6,
    "totalAtivas": 8
  }
}
```

---

## 🔍 **GET /api/categorias/{id}**

Obtém uma categoria específica por ID.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "cat-123e4567-e89b-12d3-a456-426614174000",
    "nome": "Alimentação",
    "descricao": "Gastos com comida e bebida",
    "cor": "#10b981",
    "icone": "utensils",
    "tipo": "despesa",
    "limite": 800.00,
    "gastoAtual": 520.00,
    "percentualUsado": 65.0,
    "transacoesCount": 12,
    "ativo": true,
    "transacoesRecentes": [
      {
        "id": "trans-123",
        "descricao": "Supermercado Extra",
        "valor": 156.80,
        "data": "2024-01-20T18:30:00Z"
      }
    ]
  }
}
```

### **Response 404 - Not Found**
```json
{
  "success": false,
  "error": {
    "code": "CATEGORY_NOT_FOUND",
    "message": "Categoria não encontrada"
  }
}
```

---

## ➕ **POST /api/categorias**

Cria uma nova categoria.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "nome": "Transporte",
  "descricao": "Gastos com locomoção",
  "cor": "#f59e0b",
  "icone": "car",
  "tipo": "despesa",
  "limite": 300.00
}
```

### **Response 201 - Created**
```json
{
  "success": true,
  "data": {
    "id": "cat-789e0123-e89b-12d3-a456-426614174002",
    "nome": "Transporte",
    "descricao": "Gastos com locomoção",
    "cor": "#f59e0b",
    "icone": "car",
    "tipo": "despesa",
    "limite": 300.00,
    "gastoAtual": 0.00,
    "percentualUsado": 0.0,
    "transacoesCount": 0,
    "ativo": true,
    "dataCriacao": "2024-01-21T09:15:00Z",
    "dataAtualizacao": "2024-01-21T09:15:00Z"
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
        "field": "nome",
        "message": "Nome é obrigatório"
      },
      {
        "field": "cor",
        "message": "Cor deve estar no formato hexadecimal (#RRGGBB)"
      }
    ]
  }
}
```

---

## ✏️ **PUT /api/categorias/{id}**

Atualiza uma categoria existente.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Request Body**
```json
{
  "nome": "Transporte Público",
  "descricao": "Gastos com ônibus, metrô e táxi",
  "cor": "#f59e0b",
  "icone": "bus",
  "limite": 350.00
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "cat-789e0123-e89b-12d3-a456-426614174002",
    "nome": "Transporte Público",
    "descricao": "Gastos com ônibus, metrô e táxi",
    "cor": "#f59e0b",
    "icone": "bus",
    "tipo": "despesa",
    "limite": 350.00,
    "gastoAtual": 180.00,
    "percentualUsado": 51.4,
    "transacoesCount": 5,
    "ativo": true,
    "dataAtualizacao": "2024-01-21T10:30:00Z"
  }
}
```

---

## 🗑️ **DELETE /api/categorias/{id}**

Exclui uma categoria (soft delete).

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Categoria excluída com sucesso"
}
```

### **Response 400 - Bad Request**
```json
{
  "success": false,
  "error": {
    "code": "CATEGORY_HAS_TRANSACTIONS",
    "message": "Não é possível excluir categoria com transações associadas"
  }
}
```

---

## **GET /api/categorias/{id}/estatisticas**

Obtém estatísticas detalhadas de uma categoria.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)
- `ano` (optional): Ano específico (default: ano atual)
- `mes` (optional): Mês específico (1-12, usado apenas com periodo=mensal)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "categoria": {
      "id": "cat-123e4567-e89b-12d3-a456-426614174000",
      "nome": "Alimentação",
      "limite": 800.00
    },
    "periodo": "mensal",
    "estatisticas": {
      "totalGasto": 520.00,
      "percentualLimite": 65.0,
      "mediaTransacao": 43.33,
      "totalTransacoes": 12,
      "maiorTransacao": 156.80,
      "menorTransacao": 15.50,
      "tendencia": "crescente",
      "comparacaoMesAnterior": {
        "valor": 480.00,
        "variacao": 8.33,
        "percentual": 8.33
      }
    },
    "evolucaoMensal": [
      {
        "mes": "2024-01",
        "valor": 520.00,
        "transacoes": 12
      },
      {
        "mes": "2023-12",
        "valor": 480.00,
        "transacoes": 10
      }
    ],
    "transacoesPorDia": [
      {
        "data": "2024-01-20",
        "valor": 156.80,
        "transacoes": 1
      },
      {
        "data": "2024-01-19",
        "valor": 89.50,
        "transacoes": 2
      }
    ]
  }
}
```

---

## 🔄 **POST /api/categorias/{id}/ativar**

Ativa uma categoria desativada.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Categoria ativada com sucesso"
}
```

---

## ⏸️ **POST /api/categorias/{id}/desativar**

Desativa uma categoria.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Path Parameters**
- `id`: UUID da categoria

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Categoria desativada com sucesso"
}
```

---

## **GET /api/categorias/ranking**

Obtém ranking das categorias por gasto.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)
- `tipo` (optional): `receita`, `despesa` (default: `despesa`)
- `limite` (optional): Número de categorias (default: 10)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "mensal",
    "tipo": "despesa",
    "ranking": [
      {
        "posicao": 1,
        "categoria": {
          "id": "cat-123",
          "nome": "Alimentação",
          "cor": "#10b981"
        },
        "valor": 850.00,
        "percentualTotal": 30.2,
        "transacoes": 15
      },
      {
        "posicao": 2,
        "categoria": {
          "id": "cat-456",
          "nome": "Transporte",
          "cor": "#f59e0b"
        },
        "valor": 680.00,
        "percentualTotal": 24.2,
        "transacoes": 8
      }
    ],
    "totalGeral": 2810.00
  }
}
```

---

## 📝 **Códigos de Erro**

| Código | Descrição |
|--------|-----------|
| `CATEGORY_NOT_FOUND` | Categoria não encontrada |
| `CATEGORY_HAS_TRANSACTIONS` | Categoria possui transações associadas |
| `DUPLICATE_CATEGORY_NAME` | Nome da categoria já existe |
| `INVALID_COLOR_FORMAT` | Formato de cor inválido |
| `INVALID_LIMIT_VALUE` | Valor de limite inválido |

---

## 🧪 **Exemplos de Uso**

### **cURL - Criar Categoria**
```bash
curl -X POST "https://api.spendwise.com/api/categorias" \
  -H "Authorization: Bearer seu_token_aqui" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Lazer",
    "descricao": "Entretenimento e diversão",
    "cor": "#8b5cf6",
    "icone": "gamepad",
    "tipo": "despesa",
    "limite": 400.00
  }'
```

### **JavaScript - Listar Categorias**
```javascript
const response = await fetch('/api/categorias?incluirEstatisticas=true', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const { data: categorias } = await response.json();
```

### **Python - Obter Estatísticas**
```python
import requests

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

response = requests.get(
    f'https://api.spendwise.com/api/categorias/{categoria_id}/estatisticas',
    headers=headers,
    params={'periodo': 'mensal'}
)

data = response.json()
```

