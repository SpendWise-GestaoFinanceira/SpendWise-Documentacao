---
hide:
  - navigation
  - toc
---

<div class="hero" markdown>

# SpendWise

### Sistema de Gestão de Finanças Pessoais

Plataforma moderna e completa para controle financeiro pessoal, construída com Clean Architecture, DDD e as melhores práticas de desenvolvimento de software.

<div class="hero-buttons" markdown>
[Começar Agora](guides/setup.md){ .md-button .md-button--primary }
[Ver Documentação](overview/about.md){ .md-button }
</div>

</div>

---

<div class="grid cards" markdown>

-   **Visão Geral**

    ---

    Sistema completo de gestão financeira pessoal com arquitetura moderna e tecnologias emergentes.

    [Ver mais →](overview/about.md)

-   **Arquitetura**

    ---

    Clean Architecture, CQRS, DDD e padrões modernos de desenvolvimento.

    [Ver mais →](overview/architecture.md)

-   **Docker & DevOps**

    ---

    Containerização completa com Docker, CI/CD e deploy automatizado.

    [Ver mais →](docker/index.md)

-   **API Reference**

    ---

    Documentação completa da API REST com exemplos e endpoints.

    [Ver mais →](api/auth.md)

</div>

---

## Sobre o Projeto

O SpendWise é uma evolução moderna de um projeto Java simples, transformado em uma aplicação web completa utilizando as melhores práticas de desenvolvimento de software. O projeto demonstra a aplicação de conceitos avançados como Clean Architecture, Domain-Driven Design (DDD), CQRS e padrões modernos de desenvolvimento.

### **Transformação Realizada**

| Aspecto | Projeto Original (Java) | SpendWise (Moderno) |
|---------|------------------------|---------------------|
| **Arquitetura** | Monolítica simples | Clean Architecture |
| **Persistência** | Memória (temporário) | PostgreSQL + EF Core |
| **Interface** | Console | Web API + Frontend React |
| **Testes** | Nenhum | Unitários + Integração |
| **Validações** | Básicas | FluentValidation + Domain |
| **Padrões** | POO básica | CQRS + MediatR + DDD |
| **Deploy** | Manual | Docker + CI/CD |

---

## **Quick Start**

### **Desenvolvimento Local**

```bash
# 1. Clone o repositório
git clone https://github.com/MateusOrlando/SpendWise.git
cd SpendWise

# 2. Inicie o ambiente de desenvolvimento
./scripts/dev.sh

# 3. Acesse a aplicação
# Frontend: http://localhost:3000
# Backend: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

### **Produção**

```bash
# 1. Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações

# 2. Inicie o ambiente de produção
./scripts/prod.sh

# 3. Acesse a aplicação
# Aplicação: http://localhost
```

---

## **Tecnologias Utilizadas**

### **Backend**
- **ASP.NET Core 8** - Framework web moderno
- **Entity Framework Core** - ORM para .NET
- **PostgreSQL** - Banco de dados relacional
- **MediatR** - Padrão mediator para CQRS
- **FluentValidation** - Validações robustas
- **AutoMapper** - Mapeamento de objetos
- **Serilog** - Logs estruturados

### **Frontend**
- **Next.js 14** - Framework React com App Router
- **TypeScript** - Tipagem estática
- **Tailwind CSS** - Framework CSS utilitário
- **Radix UI** - Componentes acessíveis
- **React Hook Form** - Gerenciamento de formulários
- **Recharts** - Gráficos e visualizações

### **DevOps**
- **Docker** - Containerização
- **Docker Compose** - Orquestração de containers
- **GitHub Actions** - CI/CD
- **Nginx** - Reverse proxy

---

## **Documentação**

Esta documentação está organizada em seções que cobrem todos os aspectos do projeto:

- **[Visão Geral](overview/about.md)** - Introdução e conceitos gerais
- **[Backend](backend/index.md)** - Arquitetura e implementação do backend
- **[Frontend](frontend/index.md)** - Interface e integração
- **[Docker & DevOps](docker/index.md)** - Containerização e deploy
- **[API Reference](api/auth.md)** - Documentação completa da API
- **[Guias](guides/setup.md)** - Tutoriais e guias práticos

---

## **Contribuição**

Este projeto foi desenvolvido como parte do curso de **Técnicas de Programação em Plataformas Emergentes** da **UNB**.

### **Desenvolvedor**
- **Nome**: Mateus Orlando
- **Curso**: TPPE - UNB
- **Período**: 2025.2

### **Objetivos Acadêmicos**
- Aplicação de Clean Architecture
- Implementação de DDD e CQRS
- Uso de tecnologias emergentes
- Práticas modernas de DevOps
- Documentação técnica completa

---

## **Licença**

Este projeto é desenvolvido para fins acadêmicos como parte do curso de Técnicas de Programação em Plataformas Emergentes da Universidade de Brasília.

---

<div class="grid cards" markdown>

-   :material-book:{ .lg .middle } **Começar Aqui**

    ---

    Acesse a documentação completa para entender todos os aspectos do projeto.

    [:octicons-arrow-right-24: Documentação](overview/about.md)

-   :material-code-braces:{ .lg .middle } **Código Fonte**

    ---

    Explore o código fonte no GitHub e contribua com o projeto.

    [:octicons-arrow-right-24: GitHub](https://github.com/MateusOrlando/SpendWise)

-   :material-bug:{ .lg .middle } **Reportar Bug**

    ---

    Encontrou um problema? Reporte através do GitHub Issues.

    [:octicons-arrow-right-24: Issues](https://github.com/MateusOrlando/SpendWise/issues)

</div>

