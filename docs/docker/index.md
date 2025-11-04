# Docker & DevOps

## Visão Geral

O SpendWise utiliza Docker para containerização e GitHub Actions para CI/CD, garantindo ambientes consistentes e deploys automatizados.

---

## Estrutura de Containers

### Backend (ASP.NET Core)
```yaml
services:
  backend:
    image: spendwise-backend
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ConnectionStrings__DefaultConnection=...
    depends_on:
      - postgres
```

### Frontend (Next.js)
```yaml
services:
  frontend:
    image: spendwise-frontend
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:5000
```

### Banco de Dados (PostgreSQL)
```yaml
services:
  postgres:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=spendwise
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

---

## Comandos Docker

### Iniciar todos os serviços
```bash
docker-compose up -d
```

### Ver logs
```bash
# Todos os serviços
docker-compose logs -f

# Apenas backend
docker-compose logs -f backend

# Apenas frontend
docker-compose logs -f frontend
```

### Parar serviços
```bash
docker-compose down
```

### Rebuild completo
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

## CI/CD Pipeline

### Backend Pipeline
```yaml
name: Backend CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      - name: Restore dependencies
        run: dotnet restore
      - name: Build
        run: dotnet build --no-restore
      - name: Test
        run: dotnet test --no-build --verbosity normal
```

### Frontend Pipeline
```yaml
name: Frontend CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
```

---

## Ambientes

### Desenvolvimento
- **Backend:** `http://localhost:5000`
- **Frontend:** `http://localhost:3000`
- **Database:** `localhost:5432`

### Produção
- **Backend:** Deploy via Docker em servidor VPS ou cloud
- **Frontend:** Deploy no Vercel/Netlify
- **Database:** PostgreSQL gerenciado (AWS RDS, Supabase, etc.)

---

## Variáveis de Ambiente

### Backend (.env)
```env
ASPNETCORE_ENVIRONMENT=Development
ConnectionStrings__DefaultConnection=Host=postgres;Database=spendwise;Username=postgres;Password=postgres
JwtSettings__Secret=your-secret-key-here
JwtSettings__Issuer=SpendWise
JwtSettings__Audience=SpendWise
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

---

## Troubleshooting

### Container não inicia
```bash
# Ver logs detalhados
docker-compose logs backend

# Verificar status
docker-compose ps

# Rebuild do container
docker-compose build backend
docker-compose up -d backend
```

### Banco de dados não conecta
```bash
# Verificar se PostgreSQL está rodando
docker-compose ps postgres

# Acessar shell do PostgreSQL
docker-compose exec postgres psql -U postgres -d spendwise

# Verificar conexão
docker-compose exec backend dotnet ef database update
```

### Porta já em uso
```bash
# Verificar processos usando a porta
netstat -ano | findstr :5000

# Parar todos os containers
docker-compose down

# Iniciar novamente
docker-compose up -d
```

---

## Próximos Passos

- [Guia de Setup](../guides/setup.md) - Como configurar o ambiente local
- [Backend](../backend/index.md) - Documentação do backend
- [Frontend](../frontend/index.md) - Documentação do frontend
