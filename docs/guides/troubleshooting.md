# Troubleshooting

## **Guia de Resolução de Problemas**

Este guia ajuda a resolver os problemas mais comuns encontrados durante o desenvolvimento e uso do SpendWise.

---

## **Problemas de Inicialização**

### **Backend não inicia**

#### **Erro: "Connection string not found"**
```bash
# Verificar se o arquivo appsettings.Development.json existe
ls src/SpendWise.API/appsettings.Development.json

# Criar o arquivo se não existir
cp src/SpendWise.API/appsettings.json src/SpendWise.API/appsettings.Development.json
```

**Solução:**
1. Verificar se o PostgreSQL está rodando
2. Confirmar as credenciais no connection string
3. Testar conexão manualmente

#### **Erro: "Database does not exist"**
```bash
# Verificar se o banco existe
psql -U postgres -l | grep spendwise

# Criar o banco se necessário
psql -U postgres -c "CREATE DATABASE spendwise_db;"

# Executar migrations
dotnet ef database update
```

#### **Erro: "Port 5001 already in use"**
```bash
# Verificar processo usando a porta
netstat -tulpn | grep :5001

# Matar processo se necessário (Linux/Mac)
kill -9 <PID>

# Windows
taskkill /PID <PID> /F

# Ou usar porta alternativa
dotnet run --urls="https://localhost:5002"
```

---

##  **Problemas do Frontend**

### **Frontend não conecta com Backend**

#### **Erro: "Network Error" ou "CORS Error"**
```javascript
// Verificar variáveis de ambiente
console.log(process.env.NEXT_PUBLIC_API_URL);

// Deve retornar: https://localhost:5001/api
```

**Solução:**
1. Verificar se o backend está rodando
2. Confirmar URL da API no `.env.local`
3. Verificar configuração CORS no backend

#### **Erro: "Module not found"**
```bash
# Limpar cache do Node
rm -rf node_modules package-lock.json
npm install

# Ou com pnpm
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

#### **Erro de hidratação do Next.js**
```bash
# Limpar cache do Next.js
rm -rf .next
npm run build
npm run dev
```

---

## **Problemas de Banco de Dados**

### **PostgreSQL não inicia**

#### **Linux/Mac**
```bash
# Verificar status
sudo systemctl status postgresql

# Iniciar serviço
sudo systemctl start postgresql

# Habilitar inicialização automática
sudo systemctl enable postgresql
```

#### **Windows**
```powershell
# Verificar serviços
Get-Service -Name postgresql*

# Iniciar serviço
Start-Service postgresql-x64-15
```

### **Erro de conexão com banco**

#### **"Connection refused"**
```bash
# Verificar se PostgreSQL está ouvindo na porta correta
sudo netstat -tulpn | grep :5432

# Verificar configuração do PostgreSQL
sudo nano /etc/postgresql/15/main/postgresql.conf

# Procurar por:
listen_addresses = 'localhost'
port = 5432
```

#### **"Authentication failed"**
```bash
# Resetar senha do usuário postgres
sudo -u postgres psql
\password postgres

# Verificar configuração de autenticação
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Deve conter:
local   all             postgres                                peer
local   all             all                                     md5
```

---

##  **Problemas com Docker**

### **Container não inicia**

#### **Erro: "Port already in use"**
```bash
# Verificar containers rodando
docker ps

# Parar containers conflitantes
docker stop <container_id>

# Usar portas alternativas
docker run -p 3001:3000 spendwise-frontend
```

#### **Erro: "No space left on device"**
```bash
# Limpar imagens não utilizadas
docker system prune -a

# Verificar espaço em disco
df -h

# Limpar volumes órfãos
docker volume prune
```

### **Build falha**

#### **Erro de dependências**
```bash
# Rebuild sem cache
docker build --no-cache -t spendwise-backend .

# Verificar Dockerfile
cat Dockerfile

# Verificar .dockerignore
cat .dockerignore
```

---

##  **Problemas de Autenticação**

### **JWT Token inválido**

#### **Erro: "Invalid token"**
```javascript
// Verificar se o token não expirou
const payload = JSON.parse(atob(token.split('.')[1]));
console.log('Expira em:', new Date(payload.exp * 1000));

// Verificar se o token está sendo enviado corretamente
console.log('Authorization header:', `Bearer ${token}`);
```

**Solução:**
1. Verificar se a chave secreta é a mesma no backend e frontend
2. Confirmar se o token não expirou
3. Verificar formato do header Authorization

#### **Erro: "User not found"**
```bash
# Verificar se o usuário existe no banco
psql -U spendwise_user -d spendwise_db -c "SELECT * FROM usuarios WHERE email = 'user@example.com';"
```

---

## **Problemas de Performance**

### **Consultas lentas**

#### **Identificar queries problemáticas**
```sql
-- Habilitar log de queries lentas (PostgreSQL)
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

-- Verificar queries em execução
SELECT query, state, query_start 
FROM pg_stat_activity 
WHERE state = 'active';
```

#### **Otimizar consultas**
```sql
-- Analisar plano de execução
EXPLAIN ANALYZE SELECT * FROM transacoes WHERE usuario_id = 'uuid';

-- Criar índices necessários
CREATE INDEX idx_transacoes_usuario_data ON transacoes(usuario_id, data);
CREATE INDEX idx_transacoes_categoria ON transacoes(categoria_id);
```

### **Frontend lento**

#### **Analisar bundle size**
```bash
# Analisar tamanho do bundle
npm run build
npm run analyze

# Ou com webpack-bundle-analyzer
npx webpack-bundle-analyzer .next/static/chunks/*.js
```

#### **Otimizações**
```javascript
// Lazy loading de componentes
const LazyComponent = dynamic(() => import('./HeavyComponent'), {
  loading: () => <p>Carregando...</p>
});

// Memoização de componentes
const MemoizedComponent = React.memo(ExpensiveComponent);

// Otimização de imagens
import Image from 'next/image';
<Image src="/logo.png" width={200} height={100} alt="Logo" />
```

---

##  **Problemas de Testes**

### **Testes falhando**

#### **Erro: "Database connection failed"**
```bash
# Usar banco de teste separado
export ASPNETCORE_ENVIRONMENT=Test
dotnet test

# Ou configurar connection string de teste
export ConnectionStrings__DefaultConnection="Host=localhost;Database=spendwise_test;Username=test_user;Password=test_pass"
```

#### **Erro: "Module not found in tests"**
```javascript
// jest.config.js
module.exports = {
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
};
```

---

##  **Problemas de Deploy**

### **Deploy falha no Vercel**

#### **Erro de build**
```bash
# Verificar logs de build
vercel logs <deployment-url>

# Verificar variáveis de ambiente
vercel env ls

# Adicionar variável necessária
vercel env add NEXT_PUBLIC_API_URL
```

### **Deploy falha no Heroku**

#### **Erro de memória**
```bash
# Aumentar limite de memória
heroku config:set NODE_OPTIONS="--max-old-space-size=4096"

# Verificar logs
heroku logs --tail
```

---

##  **Ferramentas de Debug**

### **Backend (.NET)**

#### **Habilitar logs detalhados**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  }
}
```

#### **Debug com Visual Studio Code**
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Core Launch (web)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/src/SpendWise.API/bin/Debug/net8.0/SpendWise.API.dll",
      "args": [],
      "cwd": "${workspaceFolder}/src/SpendWise.API",
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  ]
}
```

### **Frontend (Next.js)**

#### **Debug com Chrome DevTools**
```javascript
// Adicionar debugger
debugger;

// Console logs estruturados
console.group('API Call');
console.log('URL:', url);
console.log('Method:', method);
console.log('Data:', data);
console.groupEnd();
```

#### **Debug com VS Code**
```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug server-side",
      "type": "node",
      "request": "attach",
      "port": 9229,
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

---

##  **Quando Buscar Ajuda**

### **Antes de abrir uma issue:**

1.  Verificar se o problema está neste guia
2.  Consultar a documentação oficial
3.  Verificar issues existentes no GitHub
4.  Reproduzir o problema em ambiente limpo

### **Informações para incluir:**

- **Sistema Operacional**: Windows/Linux/macOS + versão
- **Versões**: Node.js, .NET, PostgreSQL
- **Logs de erro**: Completos e não editados
- **Passos para reproduzir**: Detalhados
- **Comportamento esperado**: O que deveria acontecer

### **Canais de suporte:**

-  **Email**: mateus.orlando@unb.br
-  **GitHub Issues**: [Abrir issue](https://github.com/MateusOrlando/SpendWise/issues)
-  **Documentação**: [Docs online](https://mateusorlando.github.io/SpendWise-Docs)

---

##  **Dicas de Performance**

### **Desenvolvimento mais rápido**

```bash
# Hot reload mais rápido (Next.js)
npm run dev -- --turbo

# Build incremental (.NET)
dotnet build --no-restore

# Cache de dependências
npm ci --cache .npm
```

### **Monitoramento**

```bash
# Monitorar recursos do sistema
htop

# Monitorar logs em tempo real
tail -f logs/app.log

# Monitorar banco de dados
SELECT * FROM pg_stat_activity;
```

---

* **Dica**: Mantenha sempre suas dependências atualizadas e faça backups regulares do banco de dados antes de grandes mudanças.*

