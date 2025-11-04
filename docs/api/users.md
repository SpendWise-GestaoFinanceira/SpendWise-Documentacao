# API - Usuários

##  **Endpoints de Usuários**

Esta seção documenta todos os endpoints relacionados ao gerenciamento de usuários no sistema SpendWise.

---

## **Modelo de Dados**

### **User**
```json
{
  "id": "string (uuid)",
  "nome": "string",
  "email": "string",
  "telefone": "string",
  "rendaMensal": "decimal",
  "dataCriacao": "datetime",
  "dataAtualizacao": "datetime",
  "ativo": "boolean"
}
```

### **UserProfile**
```json
{
  "id": "string (uuid)",
  "nome": "string",
  "email": "string",
  "telefone": "string",
  "rendaMensal": "decimal",
  "configuracoes": {
    "tema": "string",
    "moeda": "string",
    "formatoData": "string",
    "notificacoes": {
      "email": "boolean",
      "push": "boolean",
      "relatorioMensal": "boolean"
    }
  }
}
```

---

##  **GET /api/usuarios/profile**

Obtém o perfil do usuário autenticado.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nome": "João Silva",
    "email": "joao.silva@email.com",
    "telefone": "(11) 99999-9999",
    "rendaMensal": 5000.00,
    "configuracoes": {
      "tema": "system",
      "moeda": "BRL",
      "formatoData": "DD/MM/YYYY",
      "notificacoes": {
        "email": true,
        "push": false,
        "relatorioMensal": true
      }
    },
    "dataCriacao": "2024-01-15T10:30:00Z",
    "dataAtualizacao": "2024-01-20T14:45:00Z"
  }
}
```

### **Response 401 - Unauthorized**
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Token de acesso inválido ou expirado"
  }
}
```

---

##  **PUT /api/usuarios/profile**

Atualiza o perfil do usuário autenticado.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "nome": "João Silva Santos",
  "telefone": "(11) 88888-8888",
  "rendaMensal": 5500.00
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nome": "João Silva Santos",
    "email": "joao.silva@email.com",
    "telefone": "(11) 88888-8888",
    "rendaMensal": 5500.00,
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
        "field": "rendaMensal",
        "message": "Renda mensal deve ser maior que zero"
      }
    ]
  }
}
```

---

##  **PUT /api/usuarios/configuracoes**

Atualiza as configurações do usuário.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "tema": "dark",
  "moeda": "BRL",
  "formatoData": "DD/MM/YYYY",
  "inicioSemana": "segunda",
  "notificacoes": {
    "email": true,
    "push": true,
    "relatorioMensal": true,
    "alertasLimite": true
  }
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "tema": "dark",
    "moeda": "BRL",
    "formatoData": "DD/MM/YYYY",
    "inicioSemana": "segunda",
    "notificacoes": {
      "email": true,
      "push": true,
      "relatorioMensal": true,
      "alertasLimite": true
    },
    "dataAtualizacao": "2024-01-21T10:30:00Z"
  }
}
```

---

##  **PUT /api/usuarios/senha**

Altera a senha do usuário.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "senhaAtual": "senhaAtual123",
  "novaSenha": "novaSenha456",
  "confirmarSenha": "novaSenha456"
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso"
}
```

### **Response 400 - Bad Request**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_PASSWORD",
    "message": "Senha atual incorreta"
  }
}
```

---

## **GET /api/usuarios/estatisticas**

Obtém estatísticas do usuário.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "mensal",
    "totalTransacoes": 47,
    "totalCategorias": 8,
    "totalReceitas": 5300.00,
    "totalDespesas": 2810.00,
    "saldoAtual": 2490.00,
    "metaEconomia": {
      "valor": 1000.00,
      "progresso": 149.0,
      "atingida": true
    },
    "categoriasMaisGastas": [
      {
        "nome": "Alimentação",
        "valor": 850.00,
        "percentual": 30.2
      },
      {
        "nome": "Transporte",
        "valor": 680.00,
        "percentual": 24.2
      }
    ]
  }
}
```

---

##  **DELETE /api/usuarios/conta**

Exclui a conta do usuário (soft delete).

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "senha": "senhaConfirmacao123",
  "confirmacao": "EXCLUIR CONTA"
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "message": "Conta excluída com sucesso. Você tem 30 dias para recuperá-la."
}
```

### **Response 400 - Bad Request**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CONFIRMATION",
    "message": "Confirmação inválida. Digite 'EXCLUIR CONTA' para confirmar."
  }
}
```

---

##  **GET /api/usuarios/exportar**

Exporta todos os dados do usuário.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `formato` (optional): `json`, `csv`, `xlsx` (default: `json`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "usuario": { /* dados do usuário */ },
    "transacoes": [ /* todas as transações */ ],
    "categorias": [ /* todas as categorias */ ],
    "orcamentos": [ /* todos os orçamentos */ ],
    "fechamentos": [ /* todos os fechamentos */ ],
    "dataExportacao": "2024-01-21T15:30:00Z"
  }
}
```

---

##  **Códigos de Erro**

| Código | Descrição |
|--------|-----------|
| `UNAUTHORIZED` | Token inválido ou expirado |
| `VALIDATION_ERROR` | Dados de entrada inválidos |
| `USER_NOT_FOUND` | Usuário não encontrado |
| `INVALID_PASSWORD` | Senha atual incorreta |
| `INVALID_CONFIRMATION` | Confirmação de exclusão inválida |
| `EXPORT_FAILED` | Falha na exportação de dados |

---

##  **Exemplos de Uso**

### **cURL - Obter Perfil**
```bash
curl -X GET "https://api.spendwise.com/api/usuarios/profile" \
  -H "Authorization: Bearer seu_token_aqui" \
  -H "Content-Type: application/json"
```

### **JavaScript - Atualizar Perfil**
```javascript
const response = await fetch('/api/usuarios/profile', {
  method: 'PUT',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    nome: 'João Silva Santos',
    telefone: '(11) 88888-8888',
    rendaMensal: 5500.00
  })
});

const data = await response.json();
```

### **Python - Obter Estatísticas**
```python
import requests

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://api.spendwise.com/api/usuarios/estatisticas',
    headers=headers,
    params={'periodo': 'mensal'}
)

data = response.json()
```

