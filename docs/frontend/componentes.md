# Componentes do Frontend

## Visão Geral

O SpendWise utiliza uma arquitetura de componentes modular baseada em shadcn/ui e Radix UI, garantindo acessibilidade, reutilização e manutenibilidade.

## Estrutura de Componentes

### Hierarquia

```
components/
├── ui/                    # Componentes base (shadcn/ui)
├── charts/                # Componentes de visualização
├── categories/            # Componentes de categorias
├── transactions/          # Componentes de transações
├── budget/                # Componentes de orçamento
├── closure/               # Componentes de fechamento
├── reports/               # Componentes de relatórios
└── auth/                  # Componentes de autenticação
```

## Componentes Base (UI)

### Button

Componente de botão com variantes e tamanhos.

```typescript
import { Button } from '@/components/ui/button'

<Button variant="default" size="md">
  Clique aqui
</Button>

// Variantes: default, destructive, outline, secondary, ghost, link
// Tamanhos: default, sm, lg, icon
```

### Input

Campo de entrada de texto com suporte a validação.

```typescript
import { Input } from '@/components/ui/input'

<Input
  type="email"
  placeholder="seu@email.com"
  {...register('email')}
/>
```

### Dialog

Modal para exibição de conteúdo sobreposto.

```typescript
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'

<Dialog>
  <DialogTrigger asChild>
    <Button>Abrir Modal</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Título do Modal</DialogTitle>
    </DialogHeader>
    <p>Conteúdo do modal</p>
  </DialogContent>
</Dialog>
```

### Select

Componente de seleção dropdown.

```typescript
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'

<Select onValueChange={setValue}>
  <SelectTrigger>
    <SelectValue placeholder="Selecione..." />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="opcao1">Opção 1</SelectItem>
    <SelectItem value="opcao2">Opção 2</SelectItem>
  </SelectContent>
</Select>
```

### Toast

Sistema de notificações temporárias.

```typescript
import { useToast } from '@/hooks/use-toast'

const { toast } = useToast()

toast({
  title: "Sucesso!",
  description: "Operação realizada com sucesso.",
  variant: "default", // default, destructive
})
```

### Card

Container para agrupamento de conteúdo.

```typescript
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'

<Card>
  <CardHeader>
    <CardTitle>Título</CardTitle>
    <CardDescription>Descrição</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Conteúdo do card</p>
  </CardContent>
</Card>
```

## Componentes de Layout

### AppSidebar

Barra lateral de navegação da área autenticada.

**Localização**: `components/app-sidebar.tsx`

**Funcionalidades**:
- Navegação entre páginas
- Indicador de página ativa
- Suporte a modo colapsado
- Responsivo (drawer em mobile)

```typescript
<AppSidebar>
  <SidebarNav items={navItems} />
</AppSidebar>
```

**Itens de Navegação**:
- Dashboard
- Transações
- Categorias
- Orçamento
- Relatórios
- Fechamento
- Perfil

### AppHeader

Cabeçalho da aplicação com informações do usuário.

**Localização**: `components/app-header.tsx`

**Funcionalidades**:
- Exibição do nome do usuário
- Dropdown de notificações
- Toggle de tema (claro/escuro)
- Menu de usuário (perfil, logout)

```typescript
<AppHeader>
  <NotificationsDropdown />
  <ThemeToggle />
  <UserMenu />
</AppHeader>
```

### DemoSidebar

Sidebar específica para o modo demonstração.

**Localização**: `components/demo-sidebar.tsx`

**Diferenças**:
- Sem autenticação necessária
- Dados mockados
- Banner de modo demo

## Componentes de Gráficos

### DailyEvolutionChart

Gráfico de linha mostrando evolução diária de receitas e despesas.

**Localização**: `components/charts/daily-evolution-chart.tsx`

**Props**:
```typescript
interface DailyEvolutionChartProps {
  selectedMonth: string // formato: "YYYY-MM"
}
```

**Tecnologia**: Recharts (LineChart)

**Dados Exibidos**:
- Receitas diárias (linha verde)
- Despesas diárias (linha vermelha)
- Saldo acumulado (linha azul)

### CategoryDonutChart

Gráfico de rosca mostrando distribuição de gastos por categoria.

**Localização**: `components/charts/category-donut-chart.tsx`

**Props**:
```typescript
interface CategoryDonutChartProps {
  selectedMonth: string
}
```

**Tecnologia**: Recharts (PieChart)

**Funcionalidades**:
- Cores dinâmicas por categoria
- Tooltip com valores e percentuais
- Legenda interativa

### MonthlyComparisonChart

Gráfico de barras comparando meses.

**Localização**: `components/charts/monthly-comparison-chart.tsx`

**Tecnologia**: Recharts (BarChart)

**Dados**:
- Receitas mensais
- Despesas mensais
- Comparação ano anterior

### YearlyComparisonChart

Gráfico de linha comparando anos.

**Localização**: `components/charts/yearly-comparison-chart.tsx`

**Dados**:
- Evolução anual
- Comparação multi-anos
- Tendências

## Componentes de Transações

### NovaTransacaoModal

Modal para criação/edição de transações.

**Localização**: `components/nova-transacao-modal.tsx`

**Props**:
```typescript
interface NovaTransacaoModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit?: (data: any) => void
  initialData?: {
    descricao: string
    valor: number
    tipo: 'receita' | 'despesa'
    categoriaId?: string
  }
}
```

**Funcionalidades**:
- Validação de formulário (React Hook Form + Zod)
- Seleção de categoria
- Tipo (receita/despesa)
- Data da transação
- Validação de limite de orçamento
- Confirmação ao atingir limite exato

**Validações**:
```typescript
const schema = z.object({
  descricao: z.string().min(3, "Mínimo 3 caracteres"),
  valor: z.number().positive("Valor deve ser positivo"),
  tipo: z.enum(['receita', 'despesa']),
  categoriaId: z.string().optional(),
  data: z.date(),
})
```

**Regra de Negócio - Limite de Orçamento**:
1. **Bloqueia** se `novoTotal > limite`: Mostra toast vermelho, não permite salvar
2. **Avisa** se `novoTotal === limite`: Mostra confirmação, permite continuar
3. **Permite** se `novoTotal < limite`: Salva direto

### TransactionsToolbar

Barra de ferramentas para filtros e ações em transações.

**Localização**: `components/transactions/transactions-toolbar.tsx`

**Funcionalidades**:
- Filtro por tipo (receita/despesa/todas)
- Filtro por categoria
- Filtro por período
- Busca por descrição
- Botão de nova transação

### RecentTransactions

Lista de transações recentes.

**Localização**: `components/recent-transactions.tsx`

**Props**:
```typescript
interface RecentTransactionsProps {
  limit?: number // padrão: 5
}
```

**Exibição**:
- Descrição da transação
- Valor (verde para receita, vermelho para despesa)
- Categoria
- Data relativa ("há 2 dias")

## Componentes de Categorias

### NovaCategoriaModal

Modal para criação/edição de categorias.

**Localização**: `components/nova-categoria-modal.tsx`

**Props**:
```typescript
interface NovaCategoriaModalProps {
  isOpen: boolean
  onClose: () => void
  onSubmit?: (data: any) => void
}
```

**Campos**:
- Nome da categoria
- Tipo (essencial/supérfluo)
- Limite mensal (opcional)
- Cor (seletor de cores)

### CategoriesGrid

Grid de cards exibindo categorias.

**Localização**: `components/categories/categories-grid.tsx`

**Funcionalidades**:
- Exibição em grid responsivo
- Progresso de gasto vs limite
- Indicador visual de status
- Ações (editar, excluir)

**Status**:
- Verde: < 70% do limite
- Amarelo: 70-90% do limite
- Vermelho: > 90% do limite

### EditCategoryDialog

Dialog para edição de categoria existente.

**Localização**: `components/categories/edit-category-dialog.tsx`

**Funcionalidades**:
- Edição de nome
- Alteração de tipo
- Ajuste de limite
- Mudança de cor

## Componentes de Orçamento

### BudgetOverview

Visão geral do orçamento mensal.

**Localização**: `components/budget/budget-overview.tsx`

**Exibição**:
- Total de receitas
- Total de despesas
- Saldo disponível
- Progresso geral (barra)

### WeeklySpendingChart

Gráfico de gastos semanais.

**Localização**: `components/budget/weekly-spending-chart.tsx`

**Tecnologia**: Recharts (BarChart)

**Dados**:
- Gastos por dia da semana
- Média diária
- Comparação com semana anterior

## Componentes de Fechamento

### MonthlyClosureCard

Card de fechamento mensal.

**Localização**: `components/closure/monthly-closure-card.tsx`

**Props**:
```typescript
interface MonthlyClosureCardProps {
  month: string
  year: number
  totalIncome: number
  totalExpenses: number
  balance: number
  status: 'open' | 'closed'
}
```

**Ações**:
- Fechar mês (se aberto)
- Reabrir mês (se fechado)
- Visualizar detalhes
- Exportar PDF

### ClosureHistory

Lista histórica de fechamentos.

**Localização**: `components/closure/closure-history.tsx`

**Exibição**:
- Meses fechados
- Saldos finais
- Data de fechamento
- Status

## Componentes de Relatórios

### ReportsByCategory

Relatório de gastos por categoria.

**Localização**: `components/reports/reports-by-category.tsx`

**Visualizações**:
- Tabela detalhada
- Gráfico de pizza
- Comparação com mês anterior

### ReportsByMonth

Relatório de evolução mensal.

**Localização**: `components/reports/reports-by-month.tsx`

**Visualizações**:
- Gráfico de linha temporal
- Tabela comparativa
- Indicadores de tendência

### YearComparison

Comparação anual de finanças.

**Localização**: `components/reports/year-comparison.tsx`

**Dados**:
- Receitas anuais
- Despesas anuais
- Economia anual
- Comparação com anos anteriores

### ReportsToolbar

Barra de ferramentas para relatórios.

**Localização**: `components/reports/reports-toolbar.tsx`

**Funcionalidades**:
- Seleção de período
- Filtros de categoria
- Exportação (PDF, Excel)
- Impressão

## Componentes de Autenticação

### LoginForm

Formulário de login.

**Localização**: `app/(auth)/login/page.tsx`

**Campos**:
- Email
- Senha
- Lembrar-me (checkbox)

**Validações**:
- Email válido
- Senha mínimo 6 caracteres

**Links**:
- Esqueci minha senha
- Criar conta

### RegisterForm

Formulário de registro.

**Localização**: `app/(auth)/register/page.tsx`

**Campos**:
- Nome completo
- Email
- Senha
- Confirmar senha

**Validações**:
- Nome mínimo 3 caracteres
- Email único
- Senha mínimo 6 caracteres
- Senhas devem coincidir

### ForgotPasswordForm

Formulário de recuperação de senha.

**Localização**: `app/(auth)/esqueci-senha/page.tsx`

**Fluxo**:
1. Usuário informa email
2. Backend envia token por email
3. Usuário acessa link de redefinição
4. Define nova senha

### ResetPasswordForm

Formulário de redefinição de senha.

**Localização**: `app/(auth)/redefinir-senha/page.tsx`

**Campos**:
- Nova senha
- Confirmar nova senha

**Validações**:
- Senha mínimo 6 caracteres
- Senhas devem coincidir
- Token válido (30 minutos)

## Componentes Utilitários

### MonthSelector

Seletor de mês para filtros.

**Localização**: `components/month-selector.tsx`

**Props**:
```typescript
interface MonthSelectorProps {
  value: string // "YYYY-MM"
  onChange: (value: string) => void
}
```

**Funcionalidades**:
- Navegação entre meses
- Botão "Mês atual"
- Formato localizado

### NotificationsDropdown

Dropdown de notificações.

**Localização**: `components/notifications-dropdown.tsx`

**Funcionalidades**:
- Badge com contador de não lidas
- Lista de notificações
- Marcar como lida
- Limpar todas

**Tipos de Notificação**:
- Alerta de limite (categoria próxima do limite)
- Limite atingido
- Fechamento mensal disponível

### ThemeToggle

Toggle de tema claro/escuro.

**Localização**: `components/theme-toggle.tsx`

**Tecnologia**: next-themes

**Estados**:
- Light
- Dark
- System (automático)

### ConfirmDeleteModal

Modal de confirmação de exclusão.

**Localização**: `components/confirm-delete-modal.tsx`

**Props**:
```typescript
interface ConfirmDeleteModalProps {
  isOpen: boolean
  onClose: () => void
  onConfirm: () => void
  title: string
  description: string
}
```

**Uso**:
```typescript
<ConfirmDeleteModal
  isOpen={showDelete}
  onClose={() => setShowDelete(false)}
  onConfirm={handleDelete}
  title="Excluir transação?"
  description="Esta ação não pode ser desfeita."
/>
```

## Padrões de Composição

### Compound Components

Componentes que trabalham juntos:

```typescript
<Card>
  <CardHeader>
    <CardTitle>Título</CardTitle>
  </CardHeader>
  <CardContent>Conteúdo</CardContent>
</Card>
```

### Render Props

Componentes que recebem função como children:

```typescript
<DataFetcher url="/api/data">
  {({ data, loading }) => (
    loading ? <Spinner /> : <DataView data={data} />
  )}
</DataFetcher>
```

### Higher-Order Components

Componentes que envolvem outros:

```typescript
export const withAuth = (Component) => {
  return (props) => {
    const { data: session } = useSession()
    
    if (!session) {
      return <Redirect to="/login" />
    }
    
    return <Component {...props} />
  }
}
```

## Boas Práticas

### Nomenclatura

- **PascalCase**: Componentes (`Button`, `UserCard`)
- **camelCase**: Props, funções (`onClick`, `isOpen`)
- **kebab-case**: Arquivos CSS (`button.module.css`)

### Props

```typescript
// Definir interface para props
interface ButtonProps {
  children: React.ReactNode
  variant?: 'default' | 'outline'
  onClick?: () => void
}

// Usar destructuring
export function Button({ 
  children, 
  variant = 'default',
  onClick 
}: ButtonProps) {
  return (
    <button onClick={onClick}>
      {children}
    </button>
  )
}
```

### Composição vs Herança

Preferir composição:

```typescript
// BOM
<Card>
  <CardHeader>
    <CardTitle>Título</CardTitle>
  </CardHeader>
</Card>

// EVITAR
class ExtendedCard extends Card {
  // ...
}
```

### Performance

```typescript
// Memoização de componentes
export const ExpensiveComponent = memo(({ data }) => {
  return <div>{processData(data)}</div>
})

// Memoização de valores
const processedData = useMemo(
  () => processData(data),
  [data]
)

// Memoização de callbacks
const handleClick = useCallback(() => {
  doSomething()
}, [])
```

## Testes de Componentes

### Teste Unitário

```typescript
import { render, screen } from '@testing-library/react'
import { Button } from './button'

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
  
  it('calls onClick when clicked', () => {
    const onClick = jest.fn()
    render(<Button onClick={onClick}>Click</Button>)
    
    screen.getByText('Click').click()
    expect(onClick).toHaveBeenCalledTimes(1)
  })
})
```

### Teste de Integração

```typescript
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { NovaTransacaoModal } from './nova-transacao-modal'

describe('NovaTransacaoModal', () => {
  it('submits form with valid data', async () => {
    const onSubmit = jest.fn()
    render(
      <NovaTransacaoModal 
        isOpen={true} 
        onClose={() => {}}
        onSubmit={onSubmit}
      />
    )
    
    await userEvent.type(
      screen.getByLabelText('Descrição'),
      'Compra de teste'
    )
    await userEvent.type(
      screen.getByLabelText('Valor'),
      '100'
    )
    
    await userEvent.click(screen.getByText('Salvar'))
    
    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        descricao: 'Compra de teste',
        valor: 100,
      })
    })
  })
})
```
