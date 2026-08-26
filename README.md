# Brazilian E-Commerce - Analytics Engineer Case

Projeto de analytics engineering ponta a ponta usando o dataset público de e-commerce brasileiro da Olist, para entender quais são as alavancas mais efetivas para aumentar a receita nos próximos 6 meses. O projeto cobre modelagem de dados, qualidade de dados, um pipeline ETL/ELT reprodutível, análise exploratória, automação com IA e uma recomendação executiva.


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
| Transformers (Hugging Face) | Classificador de sentimento (BERT multilíngue), rodando localmente |

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
- **`payments` e `reviews` mantidas na granularidade original:** preservar o detalhe de pagamento e o texto das reviews é necessário para análises mais qualitativas, como de análise de sentimento.
- **Geolocalização e tradução de categoria fora do modelo:** `customers` e `sellers` já trazem cidade e estado; a tradução de categoria não é necessária para o público da análise.

## Qualidade de Dados

Testes automatizados no dbt cobrem nulos, duplicatas, integridade referencial, outliers e inconsistências temporais, aplicados sobre os models de mart. Achados conhecidos e não bloqueantes ficam marcados como `warn`; o restante quebra o build em caso de falha. O resultado consolidado, com saída pass/fail, está em [`notebooks/data_quality_report.ipynb`](notebooks/data_quality_report.ipynb).

## Análise de Negócio

A análise responde a cinco perguntas de negócio, sendo elas: categorias mais rentáveis, sazonalidade de vendas, impacto da entrega na recompra, CLV por região e concentração de receita entre vendedores. Além de outras três alavancas adicionais investigadas (itens por pedido, mix de cliente novo vs. recorrente, satisfação e recompra) e uma seção final de estimativa de impacto financeiro (R$ e % de uplift) para as alavancas priorizadas. Todas as queries, gráficos e decisões documentadas estão em [`notebooks/analise_exploratoria.ipynb`](notebooks/analise_exploratoria.ipynb).

## Automação com IA

Um modelo open source, gratuito e executado localmente, dentro do `.venv` do projeto: um classificador de sentimento (BERT multilíngue) roda em todas as ~41 mil reviews com texto e prevê uma nota de 1 a 5 a partir do texto. A diferença absoluta entre essa nota e a nota real (`review_score`) mede, de forma determinística e para a população inteira, o quanto texto e nota divergem.

O resultado fica em cache (`data/processed/sentiment_scores.parquet`), então reexecuções são quase instantâneas. Pra gerar do zero, basta apagar esse arquivo antes de rodar o notebook de novo.

Ver [`notebooks/automacao_ia_sentimento.ipynb`](notebooks/automacao_ia_sentimento.ipynb).

## Reprodutibilidade

Pré-requisitos: Python 3.14+, Git.

O dataset deve ser baixado em https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce, extraído e posicionado em `data/raw/`.

Criação do ambiente virtual, instalação das dependências e execução do pipeline completo:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
python run_pipeline.py
```

Pra incluir a automação com IA (~25min na 1ª vez, depois fica em cache), troque a última linha por:

```powershell
python run_pipeline.py --com-ia
```

As etapas abaixo são o mesmo pipeline, uma por vez, caso precise rodar ou depurar uma etapa isolada.

Ingestão dos CSVs no DuckDB (a partir da raiz do projeto):

```powershell
python src/ingest.py
```

Execução do dbt (staging, marts e testes). O comando precisa ser rodado de dentro de `dbt_project/`, porque o caminho do banco em `profiles.yml` é relativo ao diretório de onde o comando é chamado, não ao projeto:

```powershell
cd dbt_project
dbt build
cd ..
```

Testes do pipeline de ingestão:

```powershell
pytest
```

O Data Quality Report roda o `dbt build` internamente e apresenta o resultado; basta abrir e executar `notebooks/data_quality_report.ipynb`.

A análise exploratória está em `notebooks/analise_exploratoria.ipynb`. A automação com IA está em `notebooks/automacao_ia_sentimento.ipynb`; na primeira execução, o classificador de sentimento leva cerca de 25 minutos (roda em CPU, sobre ~41 mil reviews).

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

A recomendação executiva, com as três alavancas de receita priorizadas para os próximos 6 meses e o impacto financeiro estimado de cada uma, está em [`docs/recomendacao_executiva.md`](docs/recomendacao_executiva.md). Uma versão visual, em formato de slide está em [`docs/one_page.html`](docs/one_page.html) na versão HTML e, no mesmo local, com versão PDF.
