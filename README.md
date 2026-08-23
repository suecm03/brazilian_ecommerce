# Brazilian E-Commerce - Analytics Engineer Case

Projeto de analytics engineering ponta a ponta usando o dataset público de e-commerce brasileiro da Olist, para entender quais são as alavancas mais efetivas para aumentar a receita nos próximos 6 meses. O projeto cobre modelagem de dados, qualidade de dados, um pipeline ETL/ELT reprodutível, análise exploratória, automação com IA e uma recomendação executiva.

## Escopo do Projeto

| Etapa | Entregável | Status |
| --- | --- | --- |
| Modelagem de Dados | Modelo dimensional e ERD | Concluído |
| Qualidade de Dados | Suite de validação automatizada | Pendente |
| Pipeline de Dados | Pipeline reprodutível (Python + DuckDB + dbt) | Pendente |
| Análise Exploratória | Resposta às 5 perguntas de negócio | Pendente |
| Automação com IA | Classificação de reviews via LLM | Pendente |
| Recomendação de Negócio | One-pager executivo | Pendente |

## Arquitetura

```text
Dataset Olist (Kaggle)
        |
        v
  CSVs em data/raw/
        |
        v
  Ingestão (Python)
        |
        v
      DuckDB
        |
        v
Transformações (dbt)
        |
        v
 Modelo dimensional
        |
        +-------------------+
        |                   |
        v                   v
Análise de Negócio    Automação com IA
        |                   |
        +---------+---------+
                  |
                  v
     Recomendação Executiva
```

O pipeline roda localmente, sem servidor de banco de dados nem infraestrutura externa. O DuckDB é o banco analítico (arquivo local), e o dbt é responsável pela camada de transformação.

## Stack Técnica

| Tecnologia | Uso |
| --- | --- |
| Python | Ingestão, processamento e automação |
| DuckDB | Banco de dados analítico local |
| dbt | Transformação e modelagem dimensional |
| Pandas | Exploração e processamento de dados |
| Pytest | Testes automatizados |
| Jupyter | Exploração e análise |
| Matplotlib / Seaborn | Visualização |
| LLM (a definir) | Automação com IA |

## Fonte de Dados

O projeto usa o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), com dados relacionais de um marketplace brasileiro.

O dataset deve ser baixado manualmente do Kaggle e extraído em `data/raw/` (os arquivos brutos não são versionados). O download manual foi escolhido em vez da API do Kaggle para manter o setup simples e não depender de credencial pessoal de API.

## Modelo de Dados

O modelo utiliza star schema, na variante conhecida como constelação de fatos (fact constellation): múltiplas tabelas fato compartilhando as mesmas dimensões.

**Tabelas fato:**
- `order_items` — grão de item de pedido; medidas `price` e `freight_value`
- `payments` — grão de método de pagamento por pedido; medida `payment_value`
- `reviews` — grão de avaliação

**Dimensões:** `customers`, `products`, `sellers`, `orders`.

**Fora do modelo:** `geolocation` e `product_category_name_translation`.

O ERD completo, com todas as colunas, cardinalidades e chaves compostas, está em [`docs/erd.md`](docs/erd.md).

## Decisões-Chave

- **Constelação de fatos, não um fato único:** existe mais de um processo de negócio mensurável (venda de item, pagamento), cada um com sua própria medida.
- **`order_items` contém apenas itens reais:** pedidos sem item (majoritariamente cancelados ou indisponíveis) não geram linha nessa tabela. A tabela `orders` é a fonte completa para qualquer pergunta sobre todos os pedidos.
- **`customer_unique_id` para análises de cliente, `customer_id` para o grão da dimensão:** o endereço do cliente muda entre pedidos, então a dimensão `customers` é mantida no grão de `customer_id`; `customer_unique_id` é preservado como coluna para identificar recorrência (CLV, recompra).
- **Receita definida na camada de análise, não no pipeline:** apenas pedidos `delivered` contam como receita; os demais status permanecem nos dados para auditoria ou uma definição alternativa.
- **`payments` e `reviews` mantidas na granularidade original:** preservar o detalhe de pagamento e o texto das reviews é necessário para análises mais qualitativas, como de análise de sentimento.
- **DuckDB e dbt em vez de um banco com servidor:** roda localmente a partir de um arquivo, sem infraestrutura ou configuração adicional, adequado ao prazo do case.
- **Geolocalização e tradução de categoria fora do modelo:** `customers` e `sellers` já trazem cidade e estado; a tradução de categoria não é necessária para o público da análise.

## Qualidade de Dados

Achados detalhados de qualidade de dados (nulos, duplicatas, outliers, integridade referencial, inconsistências temporais) são documentados no Data Quality Report, com checagens automatizadas e saída pass/fail (etapa pendente).

## Análise de Negócio

A análise responde a cinco perguntas de negócio: sazonalidade de vendas, categorias mais rentáveis, impacto da entrega na recompra, CLV por região, e concentração de vendas por vendedor. A análise detalhada e as visualizações estarão no notebook de análise exploratória (etapa pendente).

## Automação com IA

Componente de IA voltado a um problema analítico concreto, não a um chatbot de demonstração. O texto das reviews foi preservado no modelo especificamente para viabilizar essa etapa (por exemplo, classificação de sentimento das avaliações). Implementação e justificativa da abordagem escolhida serão documentadas separadamente (etapa pendente).

## Reprodutibilidade

Pré-requisitos: Python 3.14+, Git.

Criação do ambiente virtual e instalação das dependências:

```bash
python -m venv .venv
source .venv/Scripts/activate  # Git Bash no Windows
pip install -r requirements.txt
```

O dataset deve ser baixado em https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce, extraído e posicionado em `data/raw/`.

Execução do pipeline, dos testes (`pytest`) e do dbt: instruções serão adicionadas quando essas etapas estiverem implementadas.

## Estrutura do Repositório

```
data/raw/          csvs originais do Kaggle (não versionado)
data/processed/    dados tratados pelo pipeline
src/               scripts de ingestão e transformação
dbt_project/       modelagem/transformação via dbt
notebooks/         exploração de dados e análise
tests/             testes automatizados
docs/              ERD e documentação complementar
```

## Resultados

A recomendação executiva, com as alavancas de receita priorizadas, estará disponível como one-pager ao final do projeto (etapa pendente).

## Melhorias Futuras

Fora do escopo deste case, mas consideradas como evolução natural: orquestração do pipeline, integração com CI/CD, modelos incrementais no dbt, observabilidade de dados, ingestão automatizada via API do Kaggle, e modelos adicionais de segmentação de cliente.
