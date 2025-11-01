# Arquitetura do Frontend

## Visão Geral

O frontend do SpendWise é construído com Next.js 13 utilizando o App Router, seguindo as melhores práticas de desenvolvimento moderno com TypeScript, React Server Components e Client Components.

## Stack Tecnológica

### Core

- **Next.js 13.5.6**: Framework React com App Router
- **React 18.2.0**: Biblioteca UI com Server Components
- **TypeScript 5.3.3**: Tipagem estática
- **Tailwind CSS 3.4.0**: Framework CSS utility-first

### UI e Componentes

- **shadcn/ui**: Biblioteca de componentes baseada em Radix UI
- **Radix UI**: Componentes acessíveis e não estilizados
- **Lucide React**: Ícones SVG
- **Recharts 2.8.0**: Gráficos e visualizações
- **Sonner**: Sistema de notificações toast

### Formulários e Validação

- **React Hook Form 7.47.0**: Gerenciamento de formulários
- **Zod 3.22.4**: Validação de schemas
- **@hookform/resolvers**: Integração Zod + React Hook Form

### Autenticação

- **NextAuth.js 4.24.11**: Autenticação e sessões
- **JWT**: Tokens de autenticação

### Testes

- **Jest 30.2.0**: Testes unitários
- **Testing Library**: Testes de componentes React
- **Playwright 1.56.1**: Testes end-to-end

### Qualidade de Código

- **ESLint 8.56.0**: Linting
- **Prettier 3.1.1**: Formatação de código
- **Husky 8.0.3**: Git hooks
- **lint-staged 15.2.0**: Linting em staged files

## Estrutura de Diretórios

```
MateusOrlando-TPPE-2025.2-Frontend/
├── app/                          # App Router do Next.js
│   ├── (app)/                   # Grupo de rotas autenticadas
│   │   ├── categorias/          # Gestão de categorias
│   │   ├── dashboard/           # Dashboard principal
│   │   ├── fechamento/          # Fechamento mensal
│   │   ├── orcamento/           # Gestão de orçamento
│   │   ├── perfil/              # Perfil do usuário
│   │   ├── relatorios/          # Relatórios e análises
│   │   ├── transacoes/          # Gestão de transações
│   │   └── layout.tsx           # Layout com sidebar
│   ├── (auth)/                  # Grupo de rotas de autenticação
│   │   ├── login/               # Página de login
│   │   ├── register/            # Página de registro
│   │   ├── esqueci-senha/       # Recuperação de senha
│   │   ├── redefinir-senha/     # Redefinição de senha
│   │   └── layout.tsx           # Layout de autenticação
│   ├── api/                     # API Routes
│   │   └── auth/                # Endpoints NextAuth
│   ├── demo/                    # Modo demonstração
│   ├── layout.tsx               # Layout raiz
│   └── page.tsx                 # Landing page
├── components/                   # Componentes React
│   ├── ui/                      # Componentes shadcn/ui
│   ├── charts/                  # Componentes de gráficos
│   ├── categories/              # Componentes de categorias
│   ├── transactions/            # Componentes de transações
│   ├── budget/                  # Componentes de orçamento
│   ├── closure/                 # Componentes de fechamento
│   ├── reports/                 # Componentes de relatórios
│   └── auth/                    # Componentes de autenticação
├── hooks/                        # Custom React Hooks
│   ├── use-auth.ts              # Hook de autenticação
│   ├── use-categorias.ts        # Hook de categorias
│   ├── use-transacoes.ts        # Hook de transações
│   ├── use-orcamento.ts         # Hook de orçamento
│   └── use-toast.ts             # Hook de notificações
├── lib/                          # Utilitários e configurações
│   ├── api/                     # Cliente API
│   ├── contexts/                # React Contexts
│   ├── types/                   # Definições de tipos
│   └── utils/                   # Funções utilitárias
├── contexts/                     # Contextos globais
│   └── NotificationsContext.tsx # Contexto de notificações
├── providers/                    # Providers React
├── e2e/                         # Testes end-to-end
│   ├── auth/                    # Testes de autenticação
│   ├── transacoes/              # Testes de transações
│   ├── fechamento/              # Testes de fechamento
│   └── setup/                   # Setup dos testes
├── __tests__/                   # Testes unitários
├── public/                      # Arquivos estáticos
├── styles/                      # Estilos globais
└── types/                       # Tipos TypeScript globais
```

## Padrões Arquiteturais

### App Router (Next.js 13+)

O projeto utiliza o novo App Router do Next.js, que oferece:

- **Layouts Aninhados**: Compartilhamento de UI entre rotas
- **Server Components**: Renderização no servidor por padrão
- **Streaming**: Carregamento progressivo de UI
- **Route Groups**: Organização lógica sem afetar URLs

### Grupos de Rotas

#### (app) - Área Autenticada

Rotas que requerem autenticação, compartilham layout com sidebar e header.

```typescript
// app/(app)/layout.tsx
export default function AppLayout({ children }) {
  return (
    <div className="flex h-screen">
      <AppSidebar />
      <main className="flex-1">
        <AppHeader />
        {children}
      </main>
    </div>
  )
}
```

#### (auth) - Área de Autenticação

Rotas públicas de autenticação com layout centralizado.

```typescript
// app/(auth)/layout.tsx
export default function AuthLayout({ children }) {
  return (
    <div className="flex min-h-screen items-center justify-center">
      {children}
    </div>
  )
}
```

### Server vs Client Components

#### Server Components (Padrão)

- Busca de dados no servidor
- Acesso direto a recursos backend
- Redução do bundle JavaScript
- Melhor SEO

```typescript
// app/(app)/dashboard/page.tsx
export default async function DashboardPage() {
  // Busca dados no servidor
  const data = await fetchDashboardData()
  
  return <DashboardView data={data} />
}
```

#### Client Components

- Interatividade (useState, useEffect)
- Event handlers
- Browser APIs
- Context providers

```typescript
'use client'

import { useState } from 'react'

export function InteractiveComponent() {
  const [count, setCount] = useState(0)
  
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

## Gerenciamento de Estado

### Estado Local

- **useState**: Estado de componente
- **useReducer**: Estado complexo

### Estado Global

- **React Context**: Notificações, tema
- **NextAuth Session**: Dados do usuário autenticado

### Estado do Servidor

- **React Query (futuro)**: Cache e sincronização
- **SWR (alternativa)**: Stale-while-revalidate

## Integração com API

### Cliente HTTP

```typescript
// lib/api/client.ts
import { getSession } from 'next-auth/react'

export async function apiClient(
  endpoint: string,
  options?: RequestInit
) {
  const session = await getSession()
  
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL}${endpoint}`,
    {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${session?.accessToken}`,
        ...options?.headers,
      },
    }
  )
  
  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`)
  }
  
  return response.json()
}
```

### Custom Hooks

```typescript
// hooks/use-transacoes.ts
export function useTransacoes() {
  const [transacoes, setTransacoes] = useState<Transacao[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    apiClient('/transacoes')
      .then(setTransacoes)
      .finally(() => setLoading(false))
  }, [])
  
  const criar = async (data: NovaTransacao) => {
    const nova = await apiClient('/transacoes', {
      method: 'POST',
      body: JSON.stringify(data),
    })
    setTransacoes([...transacoes, nova])
  }
  
  return { transacoes, loading, criar }
}
```

## Autenticação

### NextAuth.js

Configuração centralizada em `app/api/auth/[...nextauth]/route.ts`:

```typescript
export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      credentials: {
        email: { type: 'email' },
        password: { type: 'password' },
      },
      async authorize(credentials) {
        const response = await fetch(
          `${process.env.NEXT_PUBLIC_API_URL}/auth/login`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(credentials),
          }
        )
        
        if (response.ok) {
          return await response.json()
        }
        return null
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.accessToken = user.accessToken
        token.id = user.id
      }
      return token
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken
      session.user.id = token.id
      return session
    },
  },
  pages: {
    signIn: '/login',
    error: '/login',
  },
}
```

### Middleware de Proteção

```typescript
// middleware.ts
import { withAuth } from 'next-auth/middleware'

export default withAuth({
  callbacks: {
    authorized: ({ token }) => !!token,
  },
})

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/transacoes/:path*',
    '/categorias/:path*',
    '/orcamento/:path*',
    '/relatorios/:path*',
    '/fechamento/:path*',
    '/perfil/:path*',
  ],
}
```

## Estilização

### Tailwind CSS

Configuração customizada com tema do SpendWise:

```javascript
// tailwind.config.js
module.exports = {
  darkMode: ['class'],
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        border: 'hsl(var(--border))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        // ... mais cores
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}
```

### CSS Modules (Opcional)

Para estilos específicos de componente:

```css
/* components/Button.module.css */
.button {
  @apply px-4 py-2 rounded-lg;
}

.button--primary {
  @apply bg-primary text-primary-foreground;
}
```

## Performance

### Otimizações Implementadas

1. **Code Splitting Automático**: Next.js divide o código por rota
2. **Image Optimization**: Componente `next/image` otimiza imagens
3. **Font Optimization**: Fonte Geist carregada otimizada
4. **Bundle Analysis**: Análise de tamanho do bundle

### Lazy Loading

```typescript
import dynamic from 'next/dynamic'

const HeavyComponent = dynamic(
  () => import('./HeavyComponent'),
  { loading: () => <Skeleton /> }
)
```

### Memoization

```typescript
import { memo, useMemo, useCallback } from 'react'

export const ExpensiveComponent = memo(({ data }) => {
  const processed = useMemo(
    () => processData(data),
    [data]
  )
  
  const handleClick = useCallback(() => {
    // handler
  }, [])
  
  return <div>{processed}</div>
})
```

## Acessibilidade

### Princípios WCAG

- **Semântica HTML**: Tags apropriadas
- **ARIA Labels**: Atributos de acessibilidade
- **Navegação por Teclado**: Todos os elementos interativos
- **Contraste de Cores**: Ratio mínimo 4.5:1

### Radix UI

Todos os componentes shadcn/ui são baseados em Radix UI, que fornece:

- Suporte completo a teclado
- Gerenciamento de foco
- ARIA attributes automáticos
- Screen reader support

## Testes

### Estratégia de Testes

```
                    E2E Tests (Playwright)
                           ↑
                    Integration Tests
                           ↑
                     Unit Tests (Jest)
```

### Testes Unitários

```typescript
// __tests__/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from '@/components/ui/button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
})
```

### Testes E2E

```typescript
// e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test'

test('deve fazer login com sucesso', async ({ page }) => {
  await page.goto('/login')
  await page.fill('#email', 'user@test.com')
  await page.fill('#password', 'password')
  await page.click('button[type="submit"]')
  
  await expect(page).toHaveURL('/dashboard')
})
```

## Build e Deploy

### Build de Produção

```bash
npm run build
```

Gera:
- Páginas estáticas (SSG)
- Funções serverless (SSR)
- Assets otimizados

### Docker

```dockerfile
FROM node:18-alpine AS base

# Dependencies
FROM base AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Builder
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Runner
FROM base AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
```

### Variáveis de Ambiente

```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key
```

## Próximos Passos

1. **Implementar React Query**: Melhor gerenciamento de cache
2. **PWA**: Service workers e offline support
3. **Internacionalização**: Suporte multi-idioma
4. **Analytics**: Tracking de eventos
5. **Error Boundary**: Tratamento global de erros
