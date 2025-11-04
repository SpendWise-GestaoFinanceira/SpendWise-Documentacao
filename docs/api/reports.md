# API - Relatórios

## **Endpoints de Relatórios**

Esta seção documenta todos os endpoints relacionados à geração de relatórios e análises no sistema SpendWise.

---

## **Modelos de Dados**

### **ReportSummary**
```json
{
  "periodo": "string",
  "dataInicio": "datetime",
  "dataFim": "datetime",
  "totalReceitas": "decimal",
  "totalDespesas": "decimal",
  "saldoLiquido": "decimal",
  "transacoesCount": "integer",
  "categoriasCount": "integer"
}
```

### **CategoryReport**
```json
{
  "categoria": {
    "id": "string (uuid)",
    "nome": "string",
    "cor": "string (hex)"
  },
  "valor": "decimal",
  "percentual": "decimal",
  "transacoes": "integer",
  "limite": "decimal",
  "percentualLimite": "decimal"
}
```

### **TrendAnalysis**
```json
{
  "tendencia": "crescente | decrescente | estavel",
  "variacao": "decimal",
  "percentualVariacao": "decimal",
  "confianca": "alta | media | baixa"
}
```

---

## **GET /api/relatorios/dashboard**

Obtém dados consolidados para o dashboard.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)
- `ano` (optional): Ano específico (default: ano atual)
- `mes` (optional): Mês específico (1-12, usado apenas com periodo=mensal)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "resumo": {
      "periodo": "mensal",
      "dataInicio": "2024-01-01T00:00:00Z",
      "dataFim": "2024-01-31T23:59:59Z",
      "totalReceitas": 5300.00,
      "totalDespesas": 2810.00,
      "saldoLiquido": 2490.00,
      "transacoesCount": 47,
      "categoriasCount": 8
    },
    "kpis": {
      "taxaEconomia": 47.0,
      "mediaDiaria": 90.65,
      "crescimentoReceitas": 10.5,
      "crescimentoDespesas": 6.2,
      "eficienciaOrcamentaria": 85.3
    },
    "evolucaoMensal": [
      {
        "mes": "2024-01",
        "receitas": 5300.00,
        "despesas": 2810.00,
        "saldo": 2490.00
      },
      {
        "mes": "2023-12",
        "receitas": 4800.00,
        "despesas": 2650.00,
        "saldo": 2150.00
      }
    ],
    "topCategorias": [
      {
        "categoria": {
          "id": "cat-123",
          "nome": "Alimentação",
          "cor": "#10b981"
        },
        "valor": 850.00,
        "percentual": 30.2,
        "transacoes": 15,
        "limite": 800.00,
        "percentualLimite": 106.25
      }
    ],
    "alertas": [
      {
        "tipo": "limite_excedido",
        "categoria": "Alimentação",
        "valor": 850.00,
        "limite": 800.00,
        "severidade": "alta"
      }
    ]
  }
}
```

---

## **GET /api/relatorios/categorias**

Relatório detalhado por categorias.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `trimestral`, `anual` (default: `mensal`)
- `tipo` (optional): `receita`, `despesa`, `todas` (default: `todas`)
- `incluirInativas` (optional): `true`, `false` (default: `false`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "mensal",
    "resumo": {
      "totalCategorias": 8,
      "categoriasComGastos": 6,
      "categoriasAcimaDaMedia": 3,
      "categoriaComMaiorGasto": "Alimentação",
      "valorMedioCategoria": 351.25
    },
    "categorias": [
      {
        "categoria": {
          "id": "cat-123",
          "nome": "Alimentação",
          "cor": "#10b981",
          "icone": "utensils"
        },
        "valor": 850.00,
        "percentual": 30.2,
        "transacoes": 15,
        "limite": 800.00,
        "percentualLimite": 106.25,
        "mediaTransacao": 56.67,
        "tendencia": {
          "tendencia": "crescente",
          "variacao": 70.00,
          "percentualVariacao": 8.96,
          "confianca": "alta"
        },
        "evolucaoMensal": [
          {
            "mes": "2024-01",
            "valor": 850.00,
            "transacoes": 15
          },
          {
            "mes": "2023-12",
            "valor": 780.00,
            "transacoes": 12
          }
        ]
      }
    ],
    "insights": [
      {
        "tipo": "alerta",
        "titulo": "Categoria Alimentação acima do limite",
        "descricao": "Você gastou R$ 50,00 a mais que o limite estabelecido",
        "impacto": "alto"
      },
      {
        "tipo": "oportunidade",
        "titulo": "Economia em Transporte",
        "descricao": "Você economizou 15% em transporte comparado ao mês anterior",
        "impacto": "positivo"
      }
    ]
  }
}
```

---

##  **GET /api/relatorios/mensal**

Relatório mensal detalhado.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `ano` (required): Ano (YYYY)
- `mes` (required): Mês (1-12)
- `compararMesAnterior` (optional): `true`, `false` (default: `true`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": {
      "ano": 2024,
      "mes": 1,
      "nome": "Janeiro 2024",
      "diasNoMes": 31,
      "diasComTransacoes": 18
    },
    "resumoFinanceiro": {
      "receitas": 5300.00,
      "despesas": 2810.00,
      "saldo": 2490.00,
      "transacoes": 47,
      "mediaTransacaoDia": 2.61,
      "mediaDiaria": 90.65
    },
    "comparacaoMesAnterior": {
      "receitas": {
        "anterior": 4800.00,
        "atual": 5300.00,
        "variacao": 500.00,
        "percentual": 10.42
      },
      "despesas": {
        "anterior": 2650.00,
        "atual": 2810.00,
        "variacao": 160.00,
        "percentual": 6.04
      },
      "saldo": {
        "anterior": 2150.00,
        "atual": 2490.00,
        "variacao": 340.00,
        "percentual": 15.81
      }
    },
    "distribuicaoPorSemana": [
      {
        "semana": 1,
        "dataInicio": "2024-01-01",
        "dataFim": "2024-01-07",
        "receitas": 4500.00,
        "despesas": 245.30,
        "saldo": 4254.70,
        "transacoes": 3
      }
    ],
    "distribuicaoPorCategoria": [
      {
        "categoria": {
          "id": "cat-123",
          "nome": "Alimentação",
          "cor": "#10b981"
        },
        "valor": 850.00,
        "percentual": 30.2,
        "transacoes": 15,
        "limite": 800.00,
        "status": "acima_limite"
      }
    ],
    "padroes": {
      "diaSemanaComMaisGastos": {
        "dia": "sexta-feira",
        "valor": 456.80,
        "transacoes": 8
      },
      "horarioComMaisGastos": {
        "periodo": "18:00-20:00",
        "valor": 234.50,
        "transacoes": 5
      },
      "maiorTransacao": {
        "id": "trans-123",
        "descricao": "Salário Janeiro",
        "valor": 4500.00,
        "tipo": "receita",
        "data": "2024-01-01"
      }
    },
    "metas": {
      "economia": {
        "meta": 2000.00,
        "realizado": 2490.00,
        "percentual": 124.5,
        "status": "superada"
      },
      "gastos": {
        "meta": 3000.00,
        "realizado": 2810.00,
        "percentual": 93.7,
        "status": "dentro_meta"
      }
    }
  }
}
```

---

## **GET /api/relatorios/tendencias**

Análise de tendências financeiras.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `6meses`, `1ano`, `2anos` (default: `6meses`)
- `metrica` (optional): `receitas`, `despesas`, `saldo`, `todas` (default: `todas`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo": "6meses",
    "analise": {
      "receitas": {
        "tendencia": "crescente",
        "variacao": 650.00,
        "percentualVariacao": 13.5,
        "confianca": "alta",
        "projecao6Meses": 5850.00
      },
      "despesas": {
        "tendencia": "estavel",
        "variacao": 45.00,
        "percentualVariacao": 1.6,
        "confianca": "media",
        "projecao6Meses": 2855.00
      },
      "saldo": {
        "tendencia": "crescente",
        "variacao": 605.00,
        "percentualVariacao": 32.1,
        "confianca": "alta",
        "projecao6Meses": 2995.00
      }
    },
    "evolucaoMensal": [
      {
        "mes": "2024-01",
        "receitas": 5300.00,
        "despesas": 2810.00,
        "saldo": 2490.00
      },
      {
        "mes": "2023-12",
        "receitas": 4800.00,
        "despesas": 2650.00,
        "saldo": 2150.00
      }
    ],
    "sazonalidade": {
      "mesesComMaiorReceita": ["Janeiro", "Julho", "Dezembro"],
      "mesesComMaiorDespesa": ["Dezembro", "Janeiro", "Julho"],
      "padraoIdentificado": "Gastos elevados em feriados e férias"
    },
    "recomendacoes": [
      {
        "tipo": "economia",
        "titulo": "Oportunidade de economia em Dezembro",
        "descricao": "Baseado no histórico, você pode economizar 15% planejando melhor os gastos de fim de ano",
        "impactoEstimado": 421.50
      }
    ]
  }
}
```

---

## **GET /api/relatorios/metas**

Relatório de acompanhamento de metas.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo` (optional): `mensal`, `anual` (default: `mensal`)
- `status` (optional): `ativas`, `concluidas`, `todas` (default: `ativas`)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "resumo": {
      "totalMetas": 5,
      "metasAtivas": 3,
      "metasConcluidas": 1,
      "metasAtrasadas": 1,
      "percentualGeralCumprimento": 78.5
    },
    "metas": [
      {
        "id": "meta-123",
        "titulo": "Economia Mensal",
        "descricao": "Economizar R$ 2.000 por mês",
        "tipo": "economia",
        "valorMeta": 2000.00,
        "valorAtual": 2490.00,
        "percentualCumprimento": 124.5,
        "status": "superada",
        "prazo": "2024-01-31",
        "categoria": null,
        "historico": [
          {
            "data": "2024-01-31",
            "valor": 2490.00,
            "percentual": 124.5
          },
          {
            "data": "2023-12-31",
            "valor": 2150.00,
            "percentual": 107.5
          }
        ]
      }
    ],
    "insights": [
      {
        "tipo": "parabens",
        "titulo": "Meta de economia superada!",
        "descricao": "Você economizou R$ 490,00 a mais que sua meta mensal",
        "impacto": "positivo"
      }
    ]
  }
}
```

---

## **GET /api/relatorios/comparativo**

Relatório comparativo entre períodos.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Query Parameters**
- `periodo1` (required): Data início período 1 (YYYY-MM-DD)
- `periodo1Fim` (required): Data fim período 1 (YYYY-MM-DD)
- `periodo2` (required): Data início período 2 (YYYY-MM-DD)
- `periodo2Fim` (required): Data fim período 2 (YYYY-MM-DD)

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "periodo1": {
      "nome": "Janeiro 2024",
      "dataInicio": "2024-01-01",
      "dataFim": "2024-01-31",
      "receitas": 5300.00,
      "despesas": 2810.00,
      "saldo": 2490.00,
      "transacoes": 47
    },
    "periodo2": {
      "nome": "Dezembro 2023",
      "dataInicio": "2023-12-01",
      "dataFim": "2023-12-31",
      "receitas": 4800.00,
      "despesas": 2650.00,
      "saldo": 2150.00,
      "transacoes": 42
    },
    "comparacao": {
      "receitas": {
        "diferenca": 500.00,
        "percentual": 10.42,
        "tendencia": "positiva"
      },
      "despesas": {
        "diferenca": 160.00,
        "percentual": 6.04,
        "tendencia": "negativa"
      },
      "saldo": {
        "diferenca": 340.00,
        "percentual": 15.81,
        "tendencia": "positiva"
      }
    },
    "categoriasMaisImpactadas": [
      {
        "categoria": "Alimentação",
        "periodo1": 850.00,
        "periodo2": 780.00,
        "diferenca": 70.00,
        "percentual": 8.97
      }
    ]
  }
}
```

---

## **POST /api/relatorios/gerar**

Gera relatório personalizado em PDF/Excel.

### **Headers**
```http
Authorization: Bearer {token}
Content-Type: application/json
```

### **Request Body**
```json
{
  "tipo": "completo",
  "formato": "pdf",
  "periodo": {
    "dataInicio": "2024-01-01",
    "dataFim": "2024-01-31"
  },
  "secoes": [
    "resumo_financeiro",
    "categorias",
    "tendencias",
    "metas",
    "graficos"
  ],
  "filtros": {
    "categorias": ["cat-123", "cat-456"],
    "tipoTransacao": "todas"
  },
  "configuracoes": {
    "incluirGraficos": true,
    "incluirDetalhes": true,
    "idioma": "pt-BR"
  }
}
```

### **Response 200 - Success**
```json
{
  "success": true,
  "data": {
    "id": "relatorio-123e4567-e89b-12d3-a456-426614174000",
    "status": "processando",
    "estimativaMinutos": 2,
    "urlDownload": null,
    "dataCriacao": "2024-01-21T15:30:00Z"
  }
}
```

---

##  **GET /api/relatorios/{id}/download**

Faz download de relatório gerado.

### **Headers**
```http
Authorization: Bearer {token}
```

### **Path Parameters**
- `id`: UUID do relatório

### **Response 200 - Success**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="relatorio_janeiro_2024.pdf"

[Conteúdo binário do PDF]
```

---

##  **Códigos de Erro**

| Código | Descrição |
|--------|-----------|
| `INVALID_DATE_RANGE` | Intervalo de datas inválido |
| `REPORT_NOT_FOUND` | Relatório não encontrado |
| `REPORT_GENERATION_FAILED` | Falha na geração do relatório |
| `INSUFFICIENT_DATA` | Dados insuficientes para análise |
| `INVALID_PERIOD` | Período inválido |

---

##  **Exemplos de Uso**

### **cURL - Dashboard**
```bash
curl -X GET "https://api.spendwise.com/api/relatorios/dashboard?periodo=mensal" \
  -H "Authorization: Bearer seu_token_aqui" \
  -H "Content-Type: application/json"
```

### **JavaScript - Relatório de Categorias**
```javascript
const response = await fetch('/api/relatorios/categorias?periodo=mensal&tipo=despesa', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});

const { data: relatorio } = await response.json();
```

### **Python - Gerar Relatório PDF**
```python
import requests

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

payload = {
    'tipo': 'completo',
    'formato': 'pdf',
    'periodo': {
        'dataInicio': '2024-01-01',
        'dataFim': '2024-01-31'
    },
    'secoes': ['resumo_financeiro', 'categorias', 'graficos']
}

response = requests.post(
    'https://api.spendwise.com/api/relatorios/gerar',
    headers=headers,
    json=payload
)

relatorio = response.json()
```

