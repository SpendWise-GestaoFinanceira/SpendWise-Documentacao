# Guia de Setup Local

## **Configuração do Ambiente de Desenvolvimento**

Este guia irá te ajudar a configurar o ambiente completo do SpendWise em sua máquina local.

### **📋 Pré-requisitos**

#### **Software Necessário**
- **Node.js 18+** - [Download](https://nodejs.org/)
- **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download)
- **PostgreSQL 15+** - [Download](https://www.postgresql.org/download/)
- **Docker Desktop** (opcional) - [Download](https://www.docker.com/products/docker-desktop/)
- **Git** - [Download](https://git-scm.com/)

#### **Ferramentas Recomendadas**
- **Visual Studio Code** - [Download](https://code.visualstudio.com/)
- **pgAdmin** - [Download](https://www.pgadmin.org/)
- **Postman** - [Download](https://www.postman.com/)

---

## 🗂️ **Clonando os Repositórios**

```bash
# Criar diretório do projeto
mkdir SpendWise
cd SpendWise

# Clonar backend
git clone https://github.com/MateusOrlando/SpendWise-Backend.git backend
cd backend

# Clonar frontend
git clone https://github.com/MateusOrlando/SpendWise-Frontend.git frontend
cd frontend

# Clonar documentação
git clone https://github.com/MateusOrlando/SpendWise-Docs.git docs
cd docs
```

---

## **Configuração do Banco de Dados**

### **1. Instalação do PostgreSQL**

=== "Windows"
    ```powershell
    # Via Chocolatey
    choco install postgresql
    
    # Via Scoop
    scoop install postgresql
    ```

=== "macOS"
    ```bash
    # Via Homebrew
    brew install postgresql
    brew services start postgresql
    ```

=== "Linux (Ubuntu/Debian)"
    ```bash
    sudo apt update
    sudo apt install postgresql postgresql-contrib
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    ```

### **2. Criação do Banco**

```sql
-- Conectar como superuser
psql -U postgres

-- Criar usuário
CREATE USER spendwise_user WITH PASSWORD 'spendwise_pass';

-- Criar banco de dados
CREATE DATABASE spendwise_db OWNER spendwise_user;

-- Conceder privilégios
GRANT ALL PRIVILEGES ON DATABASE spendwise_db TO spendwise_user;

-- Sair
\q
```

---

## ⚙️ **Configuração do Backend**

### **1. Navegar para o diretório**
```bash
cd backend/src/SpendWise.API
```

### **2. Instalar dependências**
```bash
dotnet restore
```

### **3. Configurar variáveis de ambiente**

Criar arquivo `appsettings.Development.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=spendwise_db;Username=spendwise_user;Password=spendwise_pass"
  },
  "JwtSettings": {
    "SecretKey": "sua-chave-secreta-super-segura-aqui-com-pelo-menos-32-caracteres",
    "Issuer": "SpendWise.API",
    "Audience": "SpendWise.Frontend",
    "ExpiryMinutes": 60
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

### **4. Executar migrations**
```bash
dotnet ef database update
```

### **5. Executar o backend**
```bash
dotnet run
```

O backend estará disponível em: `https://localhost:5001`

---

## 🎨 **Configuração do Frontend**

### **1. Navegar para o diretório**
```bash
cd frontend
```

### **2. Instalar dependências**
```bash
npm install
# ou
pnpm install
# ou
yarn install
```

### **3. Configurar variáveis de ambiente**

Criar arquivo `.env.local`:

```env
# API Configuration
NEXT_PUBLIC_API_URL=https://localhost:5001/api
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=sua-chave-secreta-nextauth-aqui

# App Configuration
NEXT_PUBLIC_APP_NAME=SpendWise
NEXT_PUBLIC_APP_VERSION=1.0.0

# Database URL (para NextAuth)
DATABASE_URL=postgresql://spendwise_user:spendwise_pass@localhost:5432/spendwise_db
```

### **4. Executar o frontend**
```bash
npm run dev
# ou
pnpm dev
# ou
yarn dev
```

O frontend estará disponível em: `http://localhost:3000`

---

## **Configuração da Documentação**

### **1. Navegar para o diretório**
```bash
cd docs
```

### **2. Instalar dependências Python**
```bash
pip install -r requirements.txt
```

### **3. Executar o MkDocs**
```bash
mkdocs serve
```

A documentação estará disponível em: `http://localhost:8000`

---

## 🐳 **Configuração com Docker (Alternativa)**

### **1. Usando Docker Compose**
```bash
# Na raiz do projeto
docker-compose up -d
```

### **2. Verificar containers**
```bash
docker-compose ps
```

### **3. Logs dos containers**
```bash
docker-compose logs -f
```

---

## ✅ **Verificação da Instalação**

### **1. Testar Backend**
```bash
curl https://localhost:5001/api/health
```

### **2. Testar Frontend**
Abrir `http://localhost:3000` no navegador

### **3. Testar Documentação**
Abrir `http://localhost:8000` no navegador

---

## **Troubleshooting**

### **Problemas Comuns**

#### **Backend não inicia**
```bash
# Verificar se o PostgreSQL está rodando
sudo systemctl status postgresql

# Verificar conexão com banco
psql -h localhost -U spendwise_user -d spendwise_db
```

#### **Frontend não conecta com Backend**
- Verificar se o backend está rodando na porta 5001
- Verificar variáveis de ambiente no `.env.local`
- Verificar CORS no backend

#### **Erro de certificado HTTPS**
```bash
# Confiar no certificado de desenvolvimento
dotnet dev-certs https --trust
```

#### **Erro de porta em uso**
```bash
# Verificar processos usando a porta
netstat -tulpn | grep :3000
netstat -tulpn | grep :5001

# Matar processo se necessário
kill -9 <PID>
```

---

## **Próximos Passos**

Após a configuração bem-sucedida:

1. ✅ **Explorar a aplicação** - Navegue pelas funcionalidades
2. ✅ **Ler a documentação** - Entenda a arquitetura
3. ✅ **Executar testes** - Garanta que tudo funciona
4. ✅ **Contribuir** - Veja o [guia de contribuição](contributing.md)

---

## 📞 **Suporte**

Se encontrar problemas:

- 📖 Consulte o [Troubleshooting](troubleshooting.md)
- 🐛 Abra uma [issue no GitHub](https://github.com/MateusOrlando/SpendWise/issues)
- 💬 Entre em contato: mateus.orlando@unb.br

