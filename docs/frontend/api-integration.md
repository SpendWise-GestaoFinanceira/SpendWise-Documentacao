# Integração com API

## Visão Geral

O frontend do SpendWise se comunica com o backend .NET através de uma API RESTful. A integração é feita utilizando fetch API nativo do JavaScript com abstrações customizadas para facilitar o uso.

## Configuração Base

### Variáveis de Ambiente

```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:5000/api
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here
```

### Cliente HTTP

**Localização**: `lib/api/client.ts`

```typescript
import { getSession } from 'next-auth/react'

export async function apiClient<T = any>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const session = await getSession()
  
  const url = `${process.env.NEXT_PUBLIC_API_URL}${endpoint}`
  
  const config: RequestInit = {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(session?.accessToken && {
        Authorization: `Bearer ${session.accessToken}`,
      }),
      ...options?.headers,
    },
  }
  
  const response = await fetch(url, config)
  
  if (!response.ok) {
    const error = await response.json().catch(() => ({}))
    throw new Error(error.message || `HTTP Error: ${response.status}`)
  }
  
  // Retorna vazio para 204 No Content
  if (response.status === 204) {
    return {} as T
  }
  
  return response.json()
}
```

## Autenticação

### NextAuth Configuration

**Localização**: `app/api/auth/[...nextauth]/route.ts`

```typescript
import NextAuth, { NextAuthOptions } from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Senha', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          return null
        }

        try {
          const response = await fetch(
            `${process.env.NEXT_PUBLIC_API_URL}/auth/login`,
            {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({
                email: credentials.email,
                senha: credentials.password,
              }),
            }
          )

          if (!response.ok) {
            return null
          }

          const data = await response.json()

          return {
            id: data.usuario.id,
            email: data.usuario.email,
            name: data.usuario.nome,
            accessToken: data.token,
          }
        } catch (error) {
          console.error('Erro no login:', error)
          return null
        }
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
      if (session.user) {
        session.user.id = token.id as string
        session.accessToken = token.accessToken as string
      }
      return session
    },
  },
  pages: {
    signIn: '/login',
    error: '/login',
  },
  session: {
    strategy: 'jwt',
    maxAge: 30 * 24 * 60 * 60, // 30 dias
  },
}

const handler = NextAuth(authOptions)
export { handler as GET, handler as POST }
```

### Hook de Autenticação

**Localização**: `hooks/use-auth.ts`

```typescript
import { useSession, signIn, signOut } from 'next-auth/react'
import { useRouter } from 'next/navigation'

export function useAuth() {
  const { data: session, status } = useSession()
  const router = useRouter()

  const login = async (email: string, password: string) => {
    const result = await signIn('credentials', {
      email,
      password,
      redirect: false,
    })

    if (result?.error) {
      throw new Error('Credenciais inválidas')
    }

    router.push('/dashboard')
  }

  const logout = async () => {
    await signOut({ redirect: false })
    router.push('/login')
  }

  return {
    user: session?.user,
    accessToken: session?.accessToken,
    isAuthenticated: status === 'authenticated',
    isLoading: status === 'loading',
    login,
    logout,
  }
}
```

## Endpoints da API

### Autenticação

#### POST /auth/register

Registrar novo usuário.

```typescript
interface RegisterData {
  nome: string
  email: string
  senha: string
  confirmarSenha: string
}

export async function register(data: RegisterData) {
  return apiClient('/auth/register', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
```

#### POST /auth/login

Fazer login (usado internamente pelo NextAuth).

```typescript
interface LoginData {
  email: string
  senha: string
}

interface LoginResponse {
  token: string
  usuario: {
    id: string
    nome: string
    email: string
  }
}
```

#### POST /auth/forgot-password

Solicitar recuperação de senha.

```typescript
export async function forgotPassword(email: string) {
  return apiClient('/auth/forgot-password', {
    method: 'POST',
    body: JSON.stringify({ email }),
  })
}
```

#### POST /auth/reset-password

Redefinir senha com token.

```typescript
interface ResetPasswordData {
  email: string
  token: string
  novaSenha: string
  confirmarNovaSenha: string
}

export async function resetPassword(data: ResetPasswordData) {
  return apiClient('/auth/reset-password', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
```

### Usuários

#### GET /usuarios/perfil

Obter perfil do usuário autenticado.

```typescript
interface Usuario {
  id: string
  nome: string
  email: string
  notificacoesAtivas: boolean
}

export async function getProfile(): Promise<Usuario> {
  return apiClient('/usuarios/perfil')
}
```

#### PUT /usuarios/perfil

Atualizar perfil do usuário.

```typescript
interface UpdateProfileData {
  nome: string
  notificacoesAtivas: boolean
}

export async function updateProfile(data: UpdateProfileData) {
  return apiClient('/usuarios/perfil', {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}
```

### Categorias

#### GET /categorias

Listar todas as categorias do usuário.

```typescript
interface Categoria {
  id: string
  nome: string
  tipo: 'Essencial' | 'Superfluo'
  limiteDefinido: boolean
  limiteMensal: number
  gastoAtual: number
  cor: string
}

export async function getCategorias(): Promise<Categoria[]> {
  return apiClient('/categorias')
}
```

#### POST /categorias

Criar nova categoria.

```typescript
interface CreateCategoriaData {
  nome: string
  tipo: 'Essencial' | 'Superfluo'
  limiteDefinido: boolean
  limiteMensal?: number
  cor: string
}

export async function createCategoria(data: CreateCategoriaData) {
  return apiClient('/categorias', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
```

#### PUT /categorias/{id}

Atualizar categoria existente.

```typescript
export async function updateCategoria(
  id: string,
  data: Partial<CreateCategoriaData>
) {
  return apiClient(`/categorias/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}
```

#### DELETE /categorias/{id}

Excluir categoria.

```typescript
export async function deleteCategoria(id: string) {
  return apiClient(`/categorias/${id}`, {
    method: 'DELETE',
  })
}
```

### Transações

#### GET /transacoes

Listar transações com filtros.

```typescript
interface Transacao {
  id: string
  descricao: string
  valor: number
  tipo: 'Receita' | 'Despesa'
  data: string
  categoria?: string
  categoriaId?: string
}

interface GetTransacoesParams {
  mes?: number
  ano?: number
  tipo?: 'Receita' | 'Despesa'
  categoriaId?: string
}

export async function getTransacoes(
  params?: GetTransacoesParams
): Promise<Transacao[]> {
  const queryString = new URLSearchParams(
    params as Record<string, string>
  ).toString()
  
  return apiClient(`/transacoes?${queryString}`)
}
```

#### POST /transacoes

Criar nova transação.

```typescript
interface CreateTransacaoData {
  descricao: string
  valor: number
  tipo: 'Receita' | 'Despesa'
  data: string // ISO 8601
  categoriaId?: string
}

export async function createTransacao(data: CreateTransacaoData) {
  return apiClient('/transacoes', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
```

#### PUT /transacoes/{id}

Atualizar transação existente.

```typescript
export async function updateTransacao(
  id: string,
  data: Partial<CreateTransacaoData>
) {
  return apiClient(`/transacoes/${id}`, {
    method: 'PUT',
    body: JSON.stringify(data),
  })
}
```

#### DELETE /transacoes/{id}

Excluir transação.

```typescript
export async function deleteTransacao(id: string) {
  return apiClient(`/transacoes/${id}`, {
    method: 'DELETE',
  })
}
```

### Orçamento

#### GET /orcamento

Obter resumo do orçamento mensal.

```typescript
interface OrcamentoResumo {
  mes: number
  ano: number
  totalReceitas: number
  totalDespesas: number
  saldo: number
  categorias: {
    id: string
    nome: string
    limite: number
    gasto: number
    percentual: number
  }[]
}

export async function getOrcamento(
  mes: number,
  ano: number
): Promise<OrcamentoResumo> {
  return apiClient(`/orcamento?mes=${mes}&ano=${ano}`)
}
```

### Fechamento

#### GET /fechamento

Listar fechamentos mensais.

```typescript
interface Fechamento {
  id: string
  mes: number
  ano: number
  totalReceitas: number
  totalDespesas: number
  saldoFinal: number
  dataFechamento: string
  status: 'Aberto' | 'Fechado'
}

export async function getFechamentos(): Promise<Fechamento[]> {
  return apiClient('/fechamento')
}
```

#### POST /fechamento

Fechar mês atual.

```typescript
interface FecharMesData {
  mes: number
  ano: number
}

export async function fecharMes(data: FecharMesData) {
  return apiClient('/fechamento', {
    method: 'POST',
    body: JSON.stringify(data),
  })
}
```

#### PUT /fechamento/{id}/reabrir

Reabrir mês fechado.

```typescript
export async function reabrirMes(id: string) {
  return apiClient(`/fechamento/${id}/reabrir`, {
    method: 'PUT',
  })
}
```

### Relatórios

#### GET /relatorios/categoria

Relatório de gastos por categoria.

```typescript
interface RelatorioPorCategoria {
  categoriaId: string
  categoriaNome: string
  totalGasto: number
  percentual: number
  transacoes: number
}

export async function getRelatorioPorCategoria(
  mes: number,
  ano: number
): Promise<RelatorioPorCategoria[]> {
  return apiClient(`/relatorios/categoria?mes=${mes}&ano=${ano}`)
}
```

#### GET /relatorios/mensal

Relatório de evolução mensal.

```typescript
interface RelatorioMensal {
  mes: number
  ano: number
  receitas: number
  despesas: number
  saldo: number
}

export async function getRelatorioMensal(
  ano: number
): Promise<RelatorioMensal[]> {
  return apiClient(`/relatorios/mensal?ano=${ano}`)
}
```

## Custom Hooks

### useTransacoes

**Localização**: `hooks/use-transacoes.ts`

```typescript
import { useState, useEffect } from 'react'
import { getTransacoes, createTransacao, deleteTransacao } from '@/lib/api'

export function useTransacoes(mes?: number, ano?: number) {
  const [transacoes, setTransacoes] = useState<Transacao[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    loadTransacoes()
  }, [mes, ano])

  const loadTransacoes = async () => {
    try {
      setLoading(true)
      const data = await getTransacoes({ mes, ano })
      setTransacoes(data)
      setError(null)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const criar = async (data: CreateTransacaoData) => {
    const nova = await createTransacao(data)
    setTransacoes([...transacoes, nova])
    return nova
  }

  const excluir = async (id: string) => {
    await deleteTransacao(id)
    setTransacoes(transacoes.filter(t => t.id !== id))
  }

  return {
    transacoes,
    loading,
    error,
    criar,
    excluir,
    reload: loadTransacoes,
  }
}
```

### useCategorias

**Localização**: `hooks/use-categorias.ts`

```typescript
import { useState, useEffect } from 'react'
import { getCategorias, createCategoria, deleteCategoria } from '@/lib/api'

export function useCategorias() {
  const [categorias, setCategorias] = useState<Categoria[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCategorias()
  }, [])

  const loadCategorias = async () => {
    try {
      setLoading(true)
      const data = await getCategorias()
      setCategorias(data)
    } finally {
      setLoading(false)
    }
  }

  const criar = async (data: CreateCategoriaData) => {
    const nova = await createCategoria(data)
    setCategorias([...categorias, nova])
    return nova
  }

  const excluir = async (id: string) => {
    await deleteCategoria(id)
    setCategorias(categorias.filter(c => c.id !== id))
  }

  return {
    categorias,
    loading,
    criar,
    excluir,
    reload: loadCategorias,
  }
}
```

### useOrcamento

**Localização**: `hooks/use-orcamento.ts`

```typescript
import { useState, useEffect } from 'react'
import { getOrcamento } from '@/lib/api'

export function useOrcamento(mes: number, ano: number) {
  const [orcamento, setOrcamento] = useState<OrcamentoResumo | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadOrcamento()
  }, [mes, ano])

  const loadOrcamento = async () => {
    try {
      setLoading(true)
      const data = await getOrcamento(mes, ano)
      setOrcamento(data)
    } finally {
      setLoading(false)
    }
  }

  return {
    orcamento,
    loading,
    reload: loadOrcamento,
  }
}
```

## Tratamento de Erros

### Error Handling Global

```typescript
// lib/api/client.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public data?: any
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  try {
    const response = await fetch(url, config)
    
    if (!response.ok) {
      const error = await response.json().catch(() => ({}))
      throw new ApiError(
        error.message || 'Erro na requisição',
        response.status,
        error
      )
    }
    
    return response.json()
  } catch (error) {
    if (error instanceof ApiError) {
      throw error
    }
    throw new ApiError('Erro de conexão', 0)
  }
}
```

### Error Boundary

```typescript
// components/error-boundary.tsx
'use client'

import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="p-4 text-center">
          <h2>Algo deu errado</h2>
          <button onClick={() => this.setState({ hasError: false })}>
            Tentar novamente
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
```

## Cache e Otimização

### React Query (Futuro)

Planejado para melhor gerenciamento de cache:

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

export function useTransacoes() {
  const queryClient = useQueryClient()

  const { data, isLoading } = useQuery({
    queryKey: ['transacoes'],
    queryFn: getTransacoes,
    staleTime: 5 * 60 * 1000, // 5 minutos
  })

  const createMutation = useMutation({
    mutationFn: createTransacao,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['transacoes'] })
    },
  })

  return {
    transacoes: data,
    loading: isLoading,
    criar: createMutation.mutate,
  }
}
```

### SWR (Alternativa)

```typescript
import useSWR from 'swr'

export function useTransacoes() {
  const { data, error, mutate } = useSWR(
    '/transacoes',
    getTransacoes,
    {
      revalidateOnFocus: false,
      dedupingInterval: 2000,
    }
  )

  return {
    transacoes: data,
    loading: !error && !data,
    error,
    reload: mutate,
  }
}
```

## Testes de Integração

### Mock de API

```typescript
// __tests__/mocks/api.ts
import { rest } from 'msw'

export const handlers = [
  rest.get('/api/transacoes', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json([
        {
          id: '1',
          descricao: 'Teste',
          valor: 100,
          tipo: 'Receita',
          data: '2024-01-01',
        },
      ])
    )
  }),
  
  rest.post('/api/transacoes', (req, res, ctx) => {
    return res(
      ctx.status(201),
      ctx.json({
        id: '2',
        ...req.body,
      })
    )
  }),
]
```

### Teste de Hook

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { useTransacoes } from '@/hooks/use-transacoes'

describe('useTransacoes', () => {
  it('carrega transações', async () => {
    const { result } = renderHook(() => useTransacoes())

    expect(result.current.loading).toBe(true)

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.transacoes).toHaveLength(1)
  })
})
```

## Boas Práticas

1. **Sempre use o cliente HTTP customizado** para requisições autenticadas
2. **Trate erros adequadamente** em todos os níveis
3. **Use TypeScript** para tipar requests e responses
4. **Implemente loading states** para melhor UX
5. **Cache dados** quando apropriado
6. **Valide dados** antes de enviar ao backend
7. **Use custom hooks** para reutilização de lógica
8. **Teste integrações** com mocks
