# Frontend - SpendWise

## Visão Geral

O frontend do SpendWise é uma aplicação web moderna construída com Next.js 13, React 18 e TypeScript, oferecendo uma experiência de usuário fluida e responsiva para gerenciamento de finanças pessoais.

## Stack Tecnológica

### Core
- **Next.js 13.5.6**: Framework React com App Router
- **React 18.2.0**: Biblioteca UI com Server Components
- **TypeScript 5.3.3**: Tipagem estática
- **Tailwind CSS 3.4.0**: Framework CSS utility-first

### UI e Componentes
- **shadcn/ui**: Biblioteca de componentes baseada em Radix UI
- **Radix UI**: Componentes acessíveis e não estilizados
- **Lucide React 0.427.0**: Ícones SVG
- **Recharts 2.8.0**: Gráficos e visualizações
- **Sonner 1.4.41**: Sistema de notificações toast

### Formulários e Validação
- **React Hook Form 7.47.0**: Gerenciamento de formulários
- **Zod 3.22.4**: Validação de schemas
- **@hookform/resolvers 3.10.0**: Integração Zod + React Hook Form

### Autenticação
- **NextAuth.js 4.24.11**: Autenticação e sessões
- **JWT**: Tokens de autenticação

### Testes
- **Jest 30.2.0**: Testes unitários
- **Testing Library 16.3.0**: Testes de componentes React
- **Playwright 1.56.1**: Testes end-to-end

### Qualidade de Código
- **ESLint 8.56.0**: Linting
- **Prettier 3.1.1**: Formatação de código
- **Husky 8.0.3**: Git hooks
- **lint-staged 15.2.0**: Linting em staged files

## Funcionalidades Principais

### 1. Dashboard
- Visão geral das finanças mensais
- KPIs: Total de receitas, despesas, saldo e economia
- Gráficos de evolução diária
- Gráfico de distribuição por categoria
- Alertas de orçamento em tempo real
- Últimas transações

### 2. Gestão de Transações
- Criar, editar e excluir transações
- Tipos: Receita e Despesa
- Associação com categorias
- Filtros por tipo, categoria e período
- Busca por descrição
- Validação de limites de orçamento
- Confirmação ao atingir limite exato

### 3. Categorias
- Criar categorias personalizadas
- Tipos: Essencial e Supérfluo
- Definir limites mensais opcionais
- Seletor de cores personalizado
- Acompanhar gastos vs limite
- Indicadores visuais de status (verde/amarelo/vermelho)
- Editar e excluir categorias

### 4. Orçamento
- Visão geral do orçamento mensal
- Progresso por categoria
- Alertas de limite (70%, 90%, 100%)
- Gráfico de gastos semanais
- Comparação com mês anterior
- Definir e ajustar limites

### 5. Relatórios
- Relatórios por categoria
- Evolução mensal
- Comparação anual
- Gráficos interativos
- Tabelas detalhadas
- Exportação em PDF e Excel

### 6. Fechamento Mensal
- Fechar mês atual
- Histórico de fechamentos
- Reabrir meses fechados
- Visualizar detalhes de cada fechamento
- Exportar relatórios em PDF
- Validação de dados antes do fechamento

### 7. Perfil do Usuário
- Editar nome
- Gerenciar notificações
- Configurações de privacidade
- Tema claro/escuro

### 8. Autenticação
- Login com email e senha
- Registro de novo usuário
- Recuperação de senha
- Redefinição de senha com token
- Sessão persistente (30 dias)

### 9. Modo Demonstração
- Acesso sem autenticação
- Dados mockados
- Todas as funcionalidades disponíveis
- Banner indicativo de modo demo

## Arquitetura

### Estrutura de Diretórios

```
MateusOrlando-TPPE-2025.2-Frontend/
 app/                          # App Router do Next.js
    (app)/                   # Grupo de rotas autenticadas
       categorias/          # Gestão de categorias
       dashboard/           # Dashboard principal
       fechamento/          # Fechamento mensal
       orcamento/           # Gestão de orçamento
       perfil/              # Perfil do usuário
       relatorios/          # Relatórios e análises
       transacoes/          # Gestão de transações
       layout.tsx           # Layout com sidebar
    (auth)/                  # Grupo de rotas de autenticação
       login/               # Página de login
       register/            # Página de registro
       esqueci-senha/       # Recuperação de senha
       redefinir-senha/     # Redefinição de senha
       layout.tsx           # Layout de autenticação
    api/                     # API Routes
       auth/                # Endpoints NextAuth
    demo/                    # Modo demonstração
    layout.tsx               # Layout raiz
    page.tsx                 # Landing page
 components/                   # Componentes React
    ui/                      # Componentes shadcn/ui
    charts/                  # Componentes de gráficos
    categories/              # Componentes de categorias
    transactions/            # Componentes de transações
    budget/                  # Componentes de orçamento
    closure/                 # Componentes de fechamento
    reports/                 # Componentes de relatórios
    auth/                    # Componentes de autenticação
 hooks/                        # Custom React Hooks
 lib/                          # Utilitários e configurações
 contexts/                     # Contextos globais
 e2e/                         # Testes end-to-end
 __tests__/                   # Testes unitários
 public/                      # Arquivos estáticos
 styles/                      # Estilos globais
```

### Padrões Arquiteturais

#### App Router (Next.js 13+)
- Layouts aninhados
- Server Components por padrão
- Client Components quando necessário
- Streaming e Suspense
- Route Groups para organização

#### Componentes
- Componentes funcionais com hooks
- Composição sobre herança
- Props tipadas com TypeScript
- Acessibilidade (WCAG 2.1 AA)
- Memoization para performance

#### Estado
- Estado local: useState, useReducer
- Estado global: React Context
- Estado do servidor: NextAuth Session
- Custom hooks para lógica reutilizável

## Integração com Backend

### API Client
Cliente HTTP customizado (`lib/api/client.ts`) com:
- Autenticação automática via JWT
- Tratamento de erros padronizado
- Tipagem TypeScript completa
- Retry logic (planejado)

### Endpoints Principais
- `POST /auth/register` - Registrar usuário
- `POST /auth/login` - Login (NextAuth)
- `POST /auth/forgot-password` - Recuperar senha
- `POST /auth/reset-password` - Redefinir senha
- `GET /usuarios/perfil` - Obter perfil
- `PUT /usuarios/perfil` - Atualizar perfil
- `GET /categorias` - Listar categorias
- `POST /categorias` - Criar categoria
- `PUT /categorias/{id}` - Atualizar categoria
- `DELETE /categorias/{id}` - Excluir categoria
- `GET /transacoes` - Listar transações
- `POST /transacoes` - Criar transação
- `PUT /transacoes/{id}` - Atualizar transação
- `DELETE /transacoes/{id}` - Excluir transação
- `GET /orcamento` - Obter orçamento
- `GET /fechamento` - Listar fechamentos
- `POST /fechamento` - Fechar mês
- `PUT /fechamento/{id}/reabrir` - Reabrir mês
- `GET /relatorios/*` - Relatórios diversos

## Testes

### Estratégia de Testes
```
           E2E Tests (Playwright)
                 ↑
         Integration Tests
                 ↑
         Unit Tests (Jest)
```

### Cobertura Atual
- **Statements**: 70%+
- **Branches**: 70%+
- **Functions**: 70%+
- **Lines**: 70%+

### Tipos de Testes
- **Unitários**: Componentes, hooks, utilidades
- **Integração**: Fluxos completos, formulários
- **E2E**: Jornadas do usuário, autenticação

## Performance

### Otimizações Implementadas
- Code splitting automático por rota
- Image optimization (next/image)
- Font optimization (Geist)
- Lazy loading de componentes pesados
- Memoization (useMemo, useCallback, memo)
- Bundle analysis

### Métricas Alvo
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3.5s
- **Lighthouse Score**: > 90
- **Bundle Size**: < 300KB (gzipped)

## Acessibilidade

### Conformidade WCAG 2.1 Nível AA
- Semântica HTML adequada
- ARIA labels e roles (via Radix UI)
- Navegação completa por teclado
- Contraste de cores adequado (4.5:1)
- Screen reader support
- Focus management

### Ferramentas
- Radix UI (acessibilidade nativa)
- ESLint plugin jsx-a11y
- Lighthouse audits

## Responsividade

### Breakpoints Tailwind
- **sm**: 640px (Mobile landscape)
- **md**: 768px (Tablet)
- **lg**: 1024px (Desktop)
- **xl**: 1280px (Large desktop)
- **2xl**: 1536px (Extra large)

### Abordagem
- Mobile-first design
- Flexbox e Grid CSS
- Componentes adaptativos
- Sidebar responsiva (drawer em mobile)

## Deploy

### Build de Produção
```bash
npm run build
```

### Docker
```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Variáveis de Ambiente
```bash
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here
```

### CI/CD (GitHub Actions)
- Lint e type-check
- Testes unitários
- Build da aplicação
- Security audit
- Docker build e push
- Deploy (desabilitado)

## Desenvolvimento

### Setup Local
```bash
# Clonar repositório
git clone https://github.com/MateusOrlando-TPPE-2025-1/MateusOrlando-TPPE-2025.2-Frontend.git

# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp env.example .env.local

# Executar em desenvolvimento
npm run dev
```

### Scripts Disponíveis
- `dev`: Servidor de desenvolvimento (porta 3000)
- `build`: Build de produção
- `start`: Servidor de produção
- `lint`: Verificar código (ESLint)
- `lint:fix`: Corrigir problemas automaticamente
- `format`: Formatar código (Prettier)
- `format:check`: Verificar formatação
- `type-check`: Verificar tipos TypeScript
- `test`: Testes unitários
- `test:watch`: Testes em modo watch
- `test:coverage`: Testes com cobertura
- `test:e2e`: Testes end-to-end
- `test:e2e:ui`: Testes E2E com UI
- `test:e2e:debug`: Testes E2E em modo debug

## Documentação Adicional

- [Arquitetura Detalhada](arquitetura.md)
- [Componentes](componentes.md)
- [Integração com API](api-integration.md)
- [Testes](testes.md)
- [Product Backlog](backlog.md)

## Próximos Passos

1. **React Query**: Implementar para melhor gerenciamento de cache e sincronização
2. **PWA**: Adicionar service workers e suporte offline
3. **Internacionalização**: Suporte multi-idioma (pt-BR, en-US)
4. **Analytics**: Tracking de eventos e métricas de uso
5. **Error Boundary**: Tratamento global de erros
6. **Storybook**: Documentação visual de componentes
7. **Acessibilidade**: Auditoria completa e melhorias
8. **Performance**: Otimizações adicionais e lazy loading
9. **Testes**: Aumentar cobertura para 80%+
10. **Documentação**: Adicionar mais exemplos e guias

