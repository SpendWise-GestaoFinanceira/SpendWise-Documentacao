# Testes do Frontend

## Visão Geral

O frontend do SpendWise implementa uma estratégia de testes em múltiplas camadas, garantindo qualidade e confiabilidade do código.

## Pirâmide de Testes

```
           /\
          /  \
         / E2E \          Playwright (Poucos)
        /--------\
       /          \
      / Integration \     Testing Library (Alguns)
     /--------------\
    /                \
   /   Unit Tests     \   Jest (Muitos)
  /--------------------\
```

## Testes Unitários (Jest)

### Configuração

**Arquivo**: `jest.config.js`

```javascript
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  dir: './',
})

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  collectCoverageFrom: [
    'app/**/*.{js,jsx,ts,tsx}',
    'components/**/*.{js,jsx,ts,tsx}',
    'hooks/**/*.{js,jsx,ts,tsx}',
    'lib/**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/.next/**',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
}

module.exports = createJestConfig(customJestConfig)
```

**Arquivo**: `jest.setup.js`

```javascript
import '@testing-library/jest-dom'
```

### Comandos

```bash
# Executar todos os testes
npm run test

# Executar em modo watch
npm run test:watch

# Gerar relatório de cobertura
npm run test:coverage
```

### Testes de Componentes

#### Componente Simples

```typescript
// __tests__/components/ui/button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '@/components/ui/button'

describe('Button', () => {
  it('renderiza com texto', () => {
    render(<Button>Clique aqui</Button>)
    expect(screen.getByText('Clique aqui')).toBeInTheDocument()
  })

  it('chama onClick quando clicado', async () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Clique</Button>)
    
    await userEvent.click(screen.getByText('Clique'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('aplica variante corretamente', () => {
    render(<Button variant="destructive">Excluir</Button>)
    const button = screen.getByText('Excluir')
    expect(button).toHaveClass('bg-destructive')
  })

  it('desabilita quando disabled', () => {
    render(<Button disabled>Desabilitado</Button>)
    expect(screen.getByText('Desabilitado')).toBeDisabled()
  })
})
```

#### Componente com Estado

```typescript
// __tests__/components/month-selector.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MonthSelector } from '@/components/month-selector'

describe('MonthSelector', () => {
  it('exibe mês selecionado', () => {
    render(
      <MonthSelector 
        value="2024-01" 
        onChange={() => {}} 
      />
    )
    expect(screen.getByText('Janeiro 2024')).toBeInTheDocument()
  })

  it('chama onChange ao navegar', async () => {
    const handleChange = jest.fn()
    render(
      <MonthSelector 
        value="2024-01" 
        onChange={handleChange} 
      />
    )
    
    await userEvent.click(screen.getByLabelText('Próximo mês'))
    expect(handleChange).toHaveBeenCalledWith('2024-02')
  })

  it('volta ao mês atual', async () => {
    const handleChange = jest.fn()
    const hoje = new Date()
    const mesAtual = `${hoje.getFullYear()}-${String(hoje.getMonth() + 1).padStart(2, '0')}`
    
    render(
      <MonthSelector 
        value="2024-01" 
        onChange={handleChange} 
      />
    )
    
    await userEvent.click(screen.getByText('Mês atual'))
    expect(handleChange).toHaveBeenCalledWith(mesAtual)
  })
})
```

#### Componente com Formulário

```typescript
// __tests__/components/nova-transacao-modal.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { NovaTransacaoModal } from '@/components/nova-transacao-modal'

describe('NovaTransacaoModal', () => {
  const mockOnSubmit = jest.fn()
  const mockOnClose = jest.fn()

  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('valida campos obrigatórios', async () => {
    render(
      <NovaTransacaoModal
        isOpen={true}
        onClose={mockOnClose}
        onSubmit={mockOnSubmit}
      />
    )

    await userEvent.click(screen.getByText('Salvar'))

    await waitFor(() => {
      expect(screen.getByText('Descrição é obrigatória')).toBeInTheDocument()
      expect(screen.getByText('Valor é obrigatório')).toBeInTheDocument()
    })

    expect(mockOnSubmit).not.toHaveBeenCalled()
  })

  it('submete formulário com dados válidos', async () => {
    render(
      <NovaTransacaoModal
        isOpen={true}
        onClose={mockOnClose}
        onSubmit={mockOnSubmit}
      />
    )

    await userEvent.type(
      screen.getByLabelText('Descrição'),
      'Compra de teste'
    )
    await userEvent.type(
      screen.getByLabelText('Valor'),
      '100.50'
    )
    await userEvent.click(screen.getByLabelText('Despesa'))

    await userEvent.click(screen.getByText('Salvar'))

    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        descricao: 'Compra de teste',
        valor: 100.50,
        tipo: 'despesa',
        data: expect.any(Date),
      })
    })
  })

  it('preenche com dados iniciais ao editar', () => {
    render(
      <NovaTransacaoModal
        isOpen={true}
        onClose={mockOnClose}
        onSubmit={mockOnSubmit}
        initialData={{
          descricao: 'Transação existente',
          valor: 50,
          tipo: 'receita',
        }}
      />
    )

    expect(screen.getByLabelText('Descrição')).toHaveValue('Transação existente')
    expect(screen.getByLabelText('Valor')).toHaveValue('50')
    expect(screen.getByLabelText('Receita')).toBeChecked()
  })
})
```

### Testes de Hooks

```typescript
// __tests__/hooks/use-transacoes.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { useTransacoes } from '@/hooks/use-transacoes'
import * as api from '@/lib/api/client'

jest.mock('@/lib/api/client')

describe('useTransacoes', () => {
  const mockTransacoes = [
    {
      id: '1',
      descricao: 'Teste 1',
      valor: 100,
      tipo: 'Receita',
      data: '2024-01-01',
    },
    {
      id: '2',
      descricao: 'Teste 2',
      valor: 50,
      tipo: 'Despesa',
      data: '2024-01-02',
    },
  ]

  beforeEach(() => {
    jest.clearAllMocks()
    ;(api.apiClient as jest.Mock).mockResolvedValue(mockTransacoes)
  })

  it('carrega transações na montagem', async () => {
    const { result } = renderHook(() => useTransacoes())

    expect(result.current.loading).toBe(true)

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.transacoes).toEqual(mockTransacoes)
  })

  it('cria nova transação', async () => {
    const novaTransacao = {
      id: '3',
      descricao: 'Nova',
      valor: 200,
      tipo: 'Receita',
      data: '2024-01-03',
    }

    ;(api.apiClient as jest.Mock)
      .mockResolvedValueOnce(mockTransacoes)
      .mockResolvedValueOnce(novaTransacao)

    const { result } = renderHook(() => useTransacoes())

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    await result.current.criar({
      descricao: 'Nova',
      valor: 200,
      tipo: 'Receita',
      data: '2024-01-03',
    })

    expect(result.current.transacoes).toHaveLength(3)
    expect(result.current.transacoes[2]).toEqual(novaTransacao)
  })

  it('exclui transação', async () => {
    ;(api.apiClient as jest.Mock)
      .mockResolvedValueOnce(mockTransacoes)
      .mockResolvedValueOnce({})

    const { result } = renderHook(() => useTransacoes())

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    await result.current.excluir('1')

    expect(result.current.transacoes).toHaveLength(1)
    expect(result.current.transacoes[0].id).toBe('2')
  })

  it('trata erro ao carregar', async () => {
    const erro = new Error('Erro de rede')
    ;(api.apiClient as jest.Mock).mockRejectedValue(erro)

    const { result } = renderHook(() => useTransacoes())

    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })

    expect(result.current.error).toBe('Erro de rede')
  })
})
```

### Testes de Utilidades

```typescript
// __tests__/lib/utils.test.ts
import { cn, formatCurrency, formatDate } from '@/lib/utils'

describe('Utils', () => {
  describe('cn', () => {
    it('combina classes', () => {
      expect(cn('class1', 'class2')).toBe('class1 class2')
    })

    it('remove classes duplicadas', () => {
      expect(cn('class1', 'class1')).toBe('class1')
    })

    it('ignora valores falsy', () => {
      expect(cn('class1', false, null, undefined, 'class2')).toBe('class1 class2')
    })
  })

  describe('formatCurrency', () => {
    it('formata valor positivo', () => {
      expect(formatCurrency(1234.56)).toBe('R$ 1.234,56')
    })

    it('formata valor negativo', () => {
      expect(formatCurrency(-1234.56)).toBe('-R$ 1.234,56')
    })

    it('formata zero', () => {
      expect(formatCurrency(0)).toBe('R$ 0,00')
    })
  })

  describe('formatDate', () => {
    it('formata data', () => {
      const date = new Date('2024-01-15')
      expect(formatDate(date)).toBe('15/01/2024')
    })

    it('formata data relativa', () => {
      const hoje = new Date()
      expect(formatDate(hoje, { relative: true })).toBe('hoje')
    })
  })
})
```

## Testes de Integração (Testing Library)

### Teste de Fluxo Completo

```typescript
// __tests__/integration/transacoes-flow.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { TransacoesPage } from '@/app/(app)/transacoes/page'
import * as api from '@/lib/api/client'

jest.mock('@/lib/api/client')
jest.mock('next-auth/react', () => ({
  useSession: () => ({ data: { user: { id: '1' } }, status: 'authenticated' }),
}))

describe('Fluxo de Transações', () => {
  beforeEach(() => {
    ;(api.apiClient as jest.Mock).mockResolvedValue([])
  })

  it('cria, edita e exclui transação', async () => {
    const mockTransacao = {
      id: '1',
      descricao: 'Compra teste',
      valor: 100,
      tipo: 'Despesa',
      data: '2024-01-01',
    }

    ;(api.apiClient as jest.Mock)
      .mockResolvedValueOnce([]) // GET inicial
      .mockResolvedValueOnce(mockTransacao) // POST criar
      .mockResolvedValueOnce({ ...mockTransacao, descricao: 'Editada' }) // PUT editar
      .mockResolvedValueOnce({}) // DELETE excluir

    render(<TransacoesPage />)

    // Aguardar carregamento
    await waitFor(() => {
      expect(screen.queryByText('Carregando...')).not.toBeInTheDocument()
    })

    // Criar transação
    await userEvent.click(screen.getByText('Nova Transação'))
    await userEvent.type(screen.getByLabelText('Descrição'), 'Compra teste')
    await userEvent.type(screen.getByLabelText('Valor'), '100')
    await userEvent.click(screen.getByText('Salvar'))

    await waitFor(() => {
      expect(screen.getByText('Compra teste')).toBeInTheDocument()
    })

    // Editar transação
    await userEvent.click(screen.getByLabelText('Editar'))
    await userEvent.clear(screen.getByLabelText('Descrição'))
    await userEvent.type(screen.getByLabelText('Descrição'), 'Editada')
    await userEvent.click(screen.getByText('Salvar'))

    await waitFor(() => {
      expect(screen.getByText('Editada')).toBeInTheDocument()
    })

    // Excluir transação
    await userEvent.click(screen.getByLabelText('Excluir'))
    await userEvent.click(screen.getByText('Confirmar'))

    await waitFor(() => {
      expect(screen.queryByText('Editada')).not.toBeInTheDocument()
    })
  })
})
```

## Testes End-to-End (Playwright)

### Configuração

**Arquivo**: `playwright.config.ts`

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'setup',
      testMatch: /.*\.setup\.ts/,
    },
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### Comandos

```bash
# Executar testes E2E
npm run test:e2e

# Executar com UI
npm run test:e2e:ui

# Executar em modo debug
npm run test:e2e:debug

# Ver relatório
npm run test:e2e:report
```

### Setup de Autenticação

```typescript
// e2e/setup/auth.setup.ts
import { test as setup } from '@playwright/test'

setup('criar usuário de teste', async ({ request }) => {
  try {
    await request.post(`${process.env.API_URL}/auth/register`, {
      data: {
        nome: 'Ana Silva',
        email: 'ana@teste.com',
        senha: 'Senha@123',
        confirmarSenha: 'Senha@123',
      },
    })
  } catch (error) {
    console.warn('Usuário já existe ou erro ao criar:', error)
  }
})
```

### Helper de Login

```typescript
// e2e/helpers/auth.helper.ts
import { Page } from '@playwright/test'

export async function doLogin(page: Page) {
  await page.goto('/login')
  await page.fill('#email', 'ana@teste.com')
  await page.fill('#password', 'Senha@123')
  await page.click('button[type="submit"]:has-text("Entrar")')
  await page.waitForLoadState('networkidle')
  await page.waitForURL('/dashboard', { timeout: 15000 })
}
```

### Testes de Autenticação

```typescript
// e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Login', () => {
  test('deve fazer login com sucesso', async ({ page }) => {
    await page.goto('/login')
    await page.fill('#email', 'ana@teste.com')
    await page.fill('#password', 'Senha@123')
    await page.click('button[type="submit"]:has-text("Entrar")')

    await expect(page).toHaveURL('/dashboard', { timeout: 10000 })
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible()
  })

  test('deve exibir erro com credenciais inválidas', async ({ page }) => {
    await page.goto('/login')
    await page.fill('#email', 'invalido@teste.com')
    await page.fill('#password', 'senhaerrada')
    await page.click('button[type="submit"]:has-text("Entrar")')

    await expect(page.getByText(/credenciais inválidas/i)).toBeVisible()
  })

  test('deve validar campos obrigatórios', async ({ page }) => {
    await page.goto('/login')
    await page.click('button[type="submit"]:has-text("Entrar")')

    await expect(page.getByText(/email é obrigatório/i)).toBeVisible()
    await expect(page.getByText(/senha é obrigatória/i)).toBeVisible()
  })
})
```

### Testes de Transações

```typescript
// e2e/transacoes/criar-transacao.spec.ts
import { test, expect } from '@playwright/test'
import { doLogin } from '../helpers/auth.helper'

test.describe('Criar Transação', () => {
  test.beforeEach(async ({ page }) => {
    await doLogin(page)
  })

  test('deve criar despesa com sucesso', async ({ page }) => {
    await page.goto('/transacoes')
    await page.click('button:has-text("Nova Transação")')

    await page.fill('input[name="descricao"]', 'Compra de teste E2E')
    await page.fill('input[name="valor"]', '150.50')
    await page.click('label:has-text("Despesa")')

    await page.click('button:has-text("Salvar")')

    await expect(page.getByText('Compra de teste E2E')).toBeVisible()
    await expect(page.getByText('R$ 150,50')).toBeVisible()
  })

  test('deve validar campos obrigatórios', async ({ page }) => {
    await page.goto('/transacoes')
    await page.click('button:has-text("Nova Transação")')
    await page.click('button:has-text("Salvar")')

    await expect(page.getByText(/descrição é obrigatória/i)).toBeVisible()
    await expect(page.getByText(/valor é obrigatório/i)).toBeVisible()
  })
})
```

### Testes de Fechamento

```typescript
// e2e/fechamento/fechar-mes.spec.ts
import { test, expect } from '@playwright/test'
import { doLogin } from '../helpers/auth.helper'

test.describe('Fechamento Mensal', () => {
  test.beforeEach(async ({ page }) => {
    await doLogin(page)
  })

  test('deve exibir página de fechamento corretamente', async ({ page }) => {
    await page.goto('/fechamento')

    await expect(page.getByRole('heading', { name: /fechamento mensal/i })).toBeVisible()
    await expect(page.getByText(/total de receitas/i)).toBeVisible()
    await expect(page.getByText(/total de despesas/i)).toBeVisible()
  })

  test('deve fechar mês com sucesso', async ({ page }) => {
    await page.goto('/fechamento')
    
    const mesAtual = new Date().toLocaleDateString('pt-BR', { 
      month: 'long', 
      year: 'numeric' 
    })

    await page.click(`button:has-text("Fechar ${mesAtual}")`)
    await page.click('button:has-text("Confirmar")')

    await expect(page.getByText(/mês fechado com sucesso/i)).toBeVisible()
  })
})
```

## Cobertura de Testes

### Métricas Alvo

- **Statements**: >= 70%
- **Branches**: >= 70%
- **Functions**: >= 70%
- **Lines**: >= 70%

### Visualizar Cobertura

```bash
npm run test:coverage
```

Relatório gerado em: `coverage/lcov-report/index.html`

### Áreas Críticas

Priorizar cobertura em:

1. **Lógica de Negócio**: Validações, cálculos
2. **Componentes Principais**: Formulários, modais
3. **Hooks Customizados**: useTransacoes, useCategorias
4. **Utilidades**: Formatação, validação
5. **Integração API**: Chamadas HTTP

## Mocks e Fixtures

### Mock de NextAuth

```typescript
// __tests__/mocks/next-auth.ts
jest.mock('next-auth/react', () => ({
  useSession: jest.fn(() => ({
    data: {
      user: {
        id: '1',
        name: 'Teste User',
        email: 'teste@example.com',
      },
      accessToken: 'mock-token',
    },
    status: 'authenticated',
  })),
  signIn: jest.fn(),
  signOut: jest.fn(),
}))
```

### Mock de API Client

```typescript
// __tests__/mocks/api-client.ts
jest.mock('@/lib/api/client', () => ({
  apiClient: jest.fn(),
}))
```

### Fixtures de Dados

```typescript
// __tests__/fixtures/transacoes.ts
export const mockTransacoes = [
  {
    id: '1',
    descricao: 'Salário',
    valor: 5000,
    tipo: 'Receita',
    data: '2024-01-01',
  },
  {
    id: '2',
    descricao: 'Aluguel',
    valor: 1500,
    tipo: 'Despesa',
    data: '2024-01-05',
    categoria: 'Moradia',
  },
]
```

## CI/CD

### GitHub Actions

```yaml
# .github/workflows/ci-cd.yml
test-unit:
  name: Unit Tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '18.x'
    - run: npm ci
    - run: npm run test:coverage
    - uses: codecov/codecov-action@v3
      with:
        files: ./coverage/lcov.info

test-e2e:
  name: E2E Tests
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
    - run: npm ci
    - run: npx playwright install --with-deps
    - run: npm run test:e2e
    - uses: actions/upload-artifact@v4
      if: always()
      with:
        name: playwright-report
        path: playwright-report/
```

## Boas Práticas

1. **Teste comportamento, não implementação**
2. **Use data-testid apenas quando necessário**
3. **Prefira queries por role e texto**
4. **Mantenha testes independentes**
5. **Limpe estado entre testes**
6. **Use mocks com moderação**
7. **Teste casos de erro**
8. **Mantenha testes rápidos**
9. **Documente testes complexos**
10. **Revise cobertura regularmente**
