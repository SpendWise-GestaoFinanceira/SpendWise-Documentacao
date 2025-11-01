# Guia de Contribuição

## **Como Contribuir com o SpendWise**

Obrigado pelo interesse em contribuir com o SpendWise! Este guia irá te ajudar a começar.

---

## **Primeiros Passos**

### **1. Fork e Clone**
```bash
# Fork o repositório no GitHub
# Clone seu fork
git clone https://github.com/SEU_USUARIO/SpendWise.git
cd SpendWise

# Adicione o repositório original como upstream
git remote add upstream https://github.com/MateusOrlando/SpendWise.git
```

### **2. Configurar Ambiente**
Siga o [Guia de Setup](setup.md) para configurar o ambiente local.

### **3. Criar Branch**
```bash
# Sempre crie uma branch para suas mudanças
git checkout -b feature/nome-da-funcionalidade
# ou
git checkout -b fix/nome-do-bug
```

---

## 📝 **Padrões de Código**

### **Backend (.NET)**

#### **Naming Conventions**
```csharp
// ✅ Correto
public class TransactionService
{
    private readonly ITransactionRepository _repository;
    
    public async Task<TransactionDto> CreateTransactionAsync(
        CreateTransactionCommand command)
    {
        // Implementation
    }
}

// ❌ Incorreto
public class transactionservice
{
    private ITransactionRepository repo;
    
    public TransactionDto CreateTransaction(CreateTransactionCommand cmd)
    {
        // Implementation
    }
}
```

#### **SOLID Principles**
```csharp
// ✅ Single Responsibility
public class EmailService
{
    public Task SendEmailAsync(string to, string subject, string body) { }
}

public class UserNotificationService
{
    private readonly IEmailService _emailService;
    
    public Task NotifyUserAsync(User user, string message) { }
}

// ❌ Multiple Responsibilities
public class UserService
{
    public Task CreateUserAsync(User user) { }
    public Task SendWelcomeEmailAsync(User user) { } // Should be separate
    public Task LogUserActionAsync(string action) { } // Should be separate
}
```

### **Frontend (Next.js/React)**

#### **Component Structure**
```typescript
// ✅ Correto
interface TransactionCardProps {
  transaction: Transaction;
  onEdit: (id: string) => void;
  onDelete: (id: string) => void;
}

export const TransactionCard: React.FC<TransactionCardProps> = ({
  transaction,
  onEdit,
  onDelete
}) => {
  return (
    <div className="transaction-card">
      {/* Component content */}
    </div>
  );
};

// ❌ Incorreto
export const TransactionCard = (props: any) => {
  return (
    <div>
      {/* Component content */}
    </div>
  );
};
```

#### **Hooks Customizados**
```typescript
// ✅ Correto
export const useTransactions = (userId: string) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const fetchTransactions = useCallback(async () => {
    setLoading(true);
    try {
      const data = await api.getTransactions(userId);
      setTransactions(data);
      setError(null);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [userId]);
  
  return { transactions, loading, error, fetchTransactions };
};
```

---

## 🧪 **Testes**

### **Cobertura Mínima**
- **Domain Layer**: 100%
- **Application Layer**: 95%+
- **Infrastructure Layer**: 80%+
- **Presentation Layer**: 70%+

### **Estrutura de Testes**
```csharp
// Arrange - Act - Assert pattern
[Fact]
public async Task CreateTransaction_WithValidData_ShouldReturnSuccess()
{
    // Arrange
    var command = new CreateTransactionCommand("Test", 100m, "Expense", categoryId, DateTime.Now);
    var handler = new CreateTransactionCommandHandler(_repository, _mapper);
    
    // Act
    var result = await handler.Handle(command, CancellationToken.None);
    
    // Assert
    result.Should().NotBeNull();
    result.Description.Should().Be("Test");
    result.Amount.Should().Be(100m);
}
```

### **Testes Frontend**
```typescript
// React Testing Library
import { render, screen, fireEvent } from '@testing-library/react';
import { TransactionCard } from './TransactionCard';

describe('TransactionCard', () => {
  it('should display transaction information', () => {
    const mockTransaction = {
      id: '1',
      description: 'Test Transaction',
      amount: 100,
      type: 'expense'
    };
    
    render(<TransactionCard transaction={mockTransaction} />);
    
    expect(screen.getByText('Test Transaction')).toBeInTheDocument();
    expect(screen.getByText('R$ 100,00')).toBeInTheDocument();
  });
});
```

---

## **Processo de Contribuição**

### **1. Issues**
Antes de começar a trabalhar:
- Verifique se já existe uma issue relacionada
- Se não existir, crie uma nova issue descrevendo:
  - **Problema**: O que está acontecendo
  - **Solução proposta**: Como você pretende resolver
  - **Alternativas**: Outras abordagens consideradas

### **2. Pull Requests**

#### **Checklist antes do PR**
- [ ] Código segue os padrões estabelecidos
- [ ] Testes foram adicionados/atualizados
- [ ] Documentação foi atualizada
- [ ] Build está passando
- [ ] Não há conflitos com a branch main

#### **Template de PR**
```markdown
## Descrição
Breve descrição das mudanças realizadas.

## Tipo de mudança
- [ ] Bug fix
- [ ] Nova funcionalidade
- [ ] Breaking change
- [ ] Documentação

## Como testar
1. Passos para testar as mudanças
2. Cenários de teste específicos

## Screenshots (se aplicável)
Adicione screenshots para mudanças na UI.

## Checklist
- [ ] Código segue os padrões do projeto
- [ ] Testes foram adicionados
- [ ] Documentação foi atualizada
```

### **3. Code Review**

#### **O que procuramos**
- **Funcionalidade**: O código faz o que deveria fazer?
- **Legibilidade**: O código é claro e autodocumentado?
- **Performance**: Há gargalos ou otimizações possíveis?
- **Segurança**: Há vulnerabilidades de segurança?
- **Testes**: Os testes cobrem os cenários importantes?

#### **Como dar feedback**
```markdown
// ✅ Feedback construtivo
"Considere usar um repository pattern aqui para melhorar a testabilidade. 
Exemplo: `await _repository.GetByIdAsync(id)`"

// ❌ Feedback não construtivo
"Este código está ruim"
```

---

## **Arquitetura e Design**

### **Princípios de Design**
1. **KISS** (Keep It Simple, Stupid)
2. **DRY** (Don't Repeat Yourself)
3. **YAGNI** (You Aren't Gonna Need It)
4. **SOLID** Principles

### **Padrões Utilizados**
- **Repository Pattern** para acesso a dados
- **CQRS** para separação de comandos e consultas
- **Mediator Pattern** para desacoplamento
- **Factory Pattern** para criação de objetos complexos
- **Observer Pattern** para eventos de domínio

### **Clean Architecture Layers**
```
┌─────────────────────────────────────┐
│           Presentation              │ ← Controllers, Views
├─────────────────────────────────────┤
│           Application               │ ← Use Cases, DTOs
├─────────────────────────────────────┤
│             Domain                  │ ← Entities, Value Objects
├─────────────────────────────────────┤
│          Infrastructure             │ ← Database, External APIs
└─────────────────────────────────────┘
```

---

## **Documentação**

### **Código Autodocumentado**
```csharp
// ✅ Bom
public async Task<BudgetStatus> CalculateBudgetStatusAsync(
    CategoryId categoryId, 
    Month month)
{
    var transactions = await GetTransactionsByCategoryAndMonthAsync(categoryId, month);
    var totalSpent = transactions.Sum(t => t.Amount);
    var budget = await GetBudgetForCategoryAsync(categoryId);
    
    return totalSpent > budget.Limit 
        ? BudgetStatus.Exceeded 
        : BudgetStatus.OnTrack;
}

// ❌ Ruim
public async Task<int> CalcBS(Guid cId, int m)
{
    // Calculate budget status
    var t = await GetT(cId, m);
    var s = t.Sum(x => x.A);
    var b = await GetB(cId);
    return s > b.L ? 1 : 0;
}
```

### **Comentários XML**
```csharp
/// <summary>
/// Calculates the budget status for a specific category and month.
/// </summary>
/// <param name="categoryId">The category identifier</param>
/// <param name="month">The month to calculate for</param>
/// <returns>The budget status indicating if the budget is exceeded or on track</returns>
/// <exception cref="CategoryNotFoundException">Thrown when the category is not found</exception>
public async Task<BudgetStatus> CalculateBudgetStatusAsync(
    CategoryId categoryId, 
    Month month)
```

---

## 🔄 **Workflow Git**

### **Commits Semânticos**
```bash
# Formato: tipo(escopo): descrição

# Tipos válidos:
feat: nova funcionalidade
fix: correção de bug
docs: documentação
style: formatação, ponto e vírgula, etc
refactor: refatoração de código
test: adição ou correção de testes
chore: tarefas de build, configuração, etc

# Exemplos:
git commit -m "feat(transactions): add transaction filtering by category"
git commit -m "fix(auth): resolve JWT token expiration issue"
git commit -m "docs(api): update transaction endpoints documentation"
```

### **Branch Strategy**
```
main
├── develop
│   ├── feature/user-authentication
│   ├── feature/transaction-crud
│   └── feature/budget-tracking
├── hotfix/critical-security-fix
└── release/v1.0.0
```

---

## **Áreas que Precisam de Contribuição**

### **Alta Prioridade**
- [ ] Implementação de testes E2E
- [ ] Melhorias de performance no frontend
- [ ] Documentação de APIs
- [ ] Implementação de cache Redis

### **Média Prioridade**
- [ ] Internacionalização (i18n)
- [ ] Tema dark/light
- [ ] Notificações push
- [ ] Exportação de relatórios

### **Baixa Prioridade**
- [ ] Integração com bancos
- [ ] App mobile
- [ ] Plugins de terceiros
- [ ] Análises avançadas com IA

---

## 🏆 **Reconhecimento**

### **Contribuidores**
Todos os contribuidores são reconhecidos no README e na documentação.

### **Tipos de Contribuição**
- 💻 **Código** - Implementação de funcionalidades
- 📖 **Documentação** - Melhorias na documentação
- 🐛 **Bug Reports** - Identificação de problemas
- 💡 **Ideias** - Sugestões de melhorias
- 🎨 **Design** - Melhorias na UI/UX
- 🧪 **Testes** - Adição de testes

---

## 📞 **Suporte**

### **Canais de Comunicação**
- 💬 **Discussions**: Para perguntas gerais
- 🐛 **Issues**: Para bugs e feature requests
- 📧 **Email**: mateus.orlando@unb.br (para questões sensíveis)

### **Horários de Resposta**
- **Issues críticas**: 24h
- **Pull Requests**: 48h
- **Perguntas gerais**: 72h

---

## **Código de Conduta**

### **Nossos Valores**
- **Respeito**: Tratamos todos com dignidade
- **Inclusão**: Valorizamos a diversidade
- **Colaboração**: Trabalhamos juntos
- **Excelência**: Buscamos sempre melhorar

### **Comportamentos Esperados**
- Usar linguagem acolhedora e inclusiva
- Respeitar diferentes pontos de vista
- Aceitar críticas construtivas
- Focar no que é melhor para a comunidade

### **Comportamentos Inaceitáveis**
- Linguagem ou imagens sexualizadas
- Comentários insultuosos ou depreciativos
- Assédio público ou privado
- Publicar informações privadas de outros

---

**Obrigado por contribuir com o SpendWise! 🚀**

