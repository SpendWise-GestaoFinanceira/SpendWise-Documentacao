# API - Autenticação

##  **Visão Geral**

A API de autenticação do SpendWise utiliza JWT (JSON Web Tokens) para autenticação stateless, garantindo segurança e escalabilidade.

## **Base URL**

```
Development: http://localhost:5000/api
Production: https://api.spendwise.com/api
```

## **Endpoints**

### **POST /auth/login**

Autentica um usuário e retorna um token JWT.

#### **Request**

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "usuario@exemplo.com",
  "senha": "senha123"
}
```

#### **Response**

**200 OK**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "nome": "João Silva",
      "email": "usuario@exemplo.com",
      "rendaMensal": 5000.00,
      "isAtivo": true,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z"
    }
  },
  "success": true
}
```

**400 Bad Request**
```json
{
  "data": null,
  "success": false,
  "message": "Email ou senha inválidos"
}
```

#### **Exemplo cURL**

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "senha": "senha123"
  }'
```

---

### **POST /auth/register**

Registra um novo usuário no sistema.

#### **Request**

```http
POST /api/auth/register
Content-Type: application/json

{
  "nome": "João Silva",
  "email": "usuario@exemplo.com",
  "senha": "senha123",
  "rendaMensal": 5000.00
}
```

#### **Response**

**201 Created**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "nome": "João Silva",
      "email": "usuario@exemplo.com",
      "rendaMensal": 5000.00,
      "isAtivo": true,
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T00:00:00Z"
    }
  },
  "success": true
}
```

**400 Bad Request**
```json
{
  "data": null,
  "success": false,
  "message": "Email já está em uso"
}
```

#### **Exemplo cURL**

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "usuario@exemplo.com",
    "senha": "senha123",
    "rendaMensal": 5000.00
  }'
```

---

### **GET /usuarios/profile**

Retorna os dados do usuário autenticado.

#### **Headers**

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### **Response**

**200 OK**
```json
{
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nome": "João Silva",
    "email": "usuario@exemplo.com",
    "rendaMensal": 5000.00,
    "isAtivo": true,
    "createdAt": "2025-01-01T00:00:00Z",
    "updatedAt": "2025-01-01T00:00:00Z"
  },
  "success": true
}
```

**401 Unauthorized**
```json
{
  "data": null,
  "success": false,
  "message": "Token inválido ou expirado"
}
```

#### **Exemplo cURL**

```bash
curl -X GET http://localhost:5000/api/usuarios/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

##  **Autenticação**

### **JWT Token**

O sistema utiliza JWT para autenticação. O token deve ser incluído no header `Authorization` de todas as requisições autenticadas.

#### **Header Format**
```http
Authorization: Bearer <token>
```

#### **Token Structure**
```json
{
  "sub": "123e4567-e89b-12d3-a456-426614174000",
  "email": "usuario@exemplo.com",
  "nome": "João Silva",
  "iat": 1640995200,
  "exp": 1641081600,
  "iss": "SpendWise",
  "aud": "SpendWise"
}
```

#### **Claims**
- `sub`: ID do usuário
- `email`: Email do usuário
- `nome`: Nome do usuário
- `iat`: Timestamp de criação
- `exp`: Timestamp de expiração
- `iss`: Emissor do token
- `aud`: Audiência do token

### **Expiração**

- **Access Token**: 24 horas
- **Refresh Token**: 7 dias (quando implementado)

##  **Segurança**

### **Validações**

#### **Email**
- Formato válido de email
- Único no sistema
- Case-insensitive

#### **Senha**
- Mínimo 6 caracteres
- Hash com BCrypt
- Não armazenada em texto plano

#### **Nome**
- Obrigatório
- Máximo 100 caracteres
- Apenas letras e espaços

### **Rate Limiting**

- **Login**: 5 tentativas por minuto por IP
- **Register**: 3 tentativas por minuto por IP
- **API**: 100 requisições por minuto por usuário

##  **Códigos de Status**

| Código | Descrição |
|--------|-----------|
| 200 | Sucesso |
| 201 | Criado com sucesso |
| 400 | Requisição inválida |
| 401 | Não autorizado |
| 403 | Acesso negado |
| 404 | Não encontrado |
| 500 | Erro interno do servidor |

##  **Exemplos de Uso**

### **JavaScript/TypeScript**

```typescript
// Login
const login = async (email: string, senha: string) => {
  const response = await fetch('/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, senha }),
  });
  
  const data = await response.json();
  
  if (data.success) {
    localStorage.setItem('token', data.data.token);
    return data.data.user;
  }
  
  throw new Error(data.message);
};

// Requisição autenticada
const getProfile = async () => {
  const token = localStorage.getItem('token');
  
  const response = await fetch('/api/usuarios/profile', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  const data = await response.json();
  return data.data;
};
```

### **Python**

```python
import requests

# Login
def login(email, senha):
    response = requests.post(
        'http://localhost:5000/api/auth/login',
        json={'email': email, 'senha': senha}
    )
    
    data = response.json()
    
    if data['success']:
        return data['data']['token']
    
    raise Exception(data['message'])

# Requisição autenticada
def get_profile(token):
    headers = {'Authorization': f'Bearer {token}'}
    response = requests.get(
        'http://localhost:5000/api/usuarios/profile',
        headers=headers
    )
    
    data = response.json()
    return data['data']
```

### **cURL**

```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com","senha":"senha123"}' \
  | jq -r '.data.token')

# Usar token
curl -X GET http://localhost:5000/api/usuarios/profile \
  -H "Authorization: Bearer $TOKEN"
```

##  **Tratamento de Erros**

### **Erros Comuns**

#### **Email já em uso**
```json
{
  "data": null,
  "success": false,
  "message": "Email já está em uso"
}
```

#### **Credenciais inválidas**
```json
{
  "data": null,
  "success": false,
  "message": "Email ou senha inválidos"
}
```

#### **Token expirado**
```json
{
  "data": null,
  "success": false,
  "message": "Token expirado"
}
```

#### **Token inválido**
```json
{
  "data": null,
  "success": false,
  "message": "Token inválido"
}
```

## **Próximos Passos**

1. **[Usuários](users.md)** - Gestão de usuários
2. **[Categorias](categories.md)** - Gestão de categorias
3. **[Transações](transactions.md)** - Gestão de transações
4. **[Relatórios](reports.md)** - Relatórios e análises

---

##  **Suporte**

Para problemas ou dúvidas:

1. Verificar logs da aplicação
2. Consultar documentação da API
3. Abrir issue no repositório
4. Contatar equipe de desenvolvimento

