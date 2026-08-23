# ERD - Modelo de Dados

O modelo utiliza star schema, na variante conhecida como constelação de fatos (fact constellation ou galaxy schema): uma extensão do star schema para os casos em que existe mais de um processo de negócio mensurável. Múltiplas tabelas fato compartilham as mesmas dimensões (chamadas de dimensões conformadas), e cada tabela fato, isoladamente, ainda forma uma estrela com suas próprias dimensões — a constelação é a sobreposição de mais de uma dessas estrelas. As dimensões são mantidas desnormalizadas, sem quebrar em sub-tabelas — essa é uma decisão independente da constelação de fatos: o eixo estrela/constelação descreve quantas tabelas fato existem; normalizar ou não as dimensões é o eixo que distingue star schema de snowflake schema. As tabelas `geolocation` e `product_category_name_translation` do dataset original não entram no modelo; os motivos estão no README.md.

```mermaid
erDiagram

    ORDER_ITEMS {
        string order_id PK, FK
        int order_item_id PK
        string product_id FK
        string seller_id FK
        float price
        float freight_value
    }

    PAYMENTS {
        string order_id PK, FK
        int payment_sequential PK
        string payment_type
        int payment_installments
        float payment_value
    }

    REVIEWS {
        string review_id PK
        string order_id PK, FK
        int review_score
        string review_comment_title
        string review_comment_message
        date review_creation_date
        timestamp review_answer_timestamp
    }

    ORDERS {
        string order_id PK
        string customer_id FK
        string order_status
        timestamp order_purchase_timestamp
        timestamp order_approved_at
        timestamp order_delivered_carrier_date
        timestamp order_delivered_customer_date
        date order_estimated_delivery_date
    }

    CUSTOMERS {
        string customer_id PK
        string customer_unique_id
        int customer_zip_code_prefix
        string customer_city
        string customer_state
    }

    PRODUCTS {
        string product_id PK
        string product_category_name
        int product_name_lenght
        int product_description_lenght
        int product_photos_qty
        float product_weight_g
        float product_length_cm
        float product_height_cm
        float product_width_cm
    }

    SELLERS {
        string seller_id PK
        int seller_zip_code_prefix
        string seller_city
        string seller_state
    }

    CUSTOMERS ||--|| ORDERS : "faz"
    ORDERS ||--o{ ORDER_ITEMS : "contém"
    PRODUCTS ||--o{ ORDER_ITEMS : "aparece em"
    SELLERS ||--o{ ORDER_ITEMS : "vende"
    ORDERS ||--o{ PAYMENTS : "é pago via"
    ORDERS ||--o{ REVIEWS : "recebe"
```

## Notas sobre as cardinalidades

- `CUSTOMERS ||--|| ORDERS`: relação um-para-um. `customer_id` é único tanto em `customers` quanto em `orders`; todo `customer_id` de um lado tem correspondência no outro (verificado nos dois sentidos). Quem se repete entre pedidos diferentes do mesmo cliente é o `customer_unique_id`, não o `customer_id`.
- `ORDERS ||--o{ ORDER_ITEMS`: zero ou muitos. `order_items` contém apenas itens reais, na mesma granularidade da tabela de origem — não é criada nenhuma linha artificial para representar um pedido sem item. Pedidos sem nenhum item (majoritariamente com status `canceled` ou `unavailable`) simplesmente não têm linha correspondente em `order_items`, o que é correto: eles não geraram receita de item. A tabela `orders` continua sendo a fonte completa de todos os pedidos, independentemente de terem ou não item associado — qualquer análise que precise considerar todos os pedidos (incluindo cancelados) deve consultar `orders` diretamente, não inferir isso a partir de `order_items`. `customer_id` e a data de compra não são replicados em `order_items`: como todo `order_id` de `order_items` sempre existe em `orders`, um join simples recupera essas informações quando necessário, sem justificar a redundância de manter cópias.
- `PRODUCTS ||--o{ ORDER_ITEMS` e `SELLERS ||--o{ ORDER_ITEMS`: zero ou muitos. Essa é a cardinalidade correta do ponto de vista do schema — um produto ou vendedor cadastrado pode, em princípio, nunca ter tido uma venda. No recorte atual dos dados, todo `product_id` e todo `seller_id` cadastrados aparecem em pelo menos uma linha de `order_items`, mas isso é uma característica observada deste dataset específico, não uma garantia estrutural — por isso a cardinalidade mínima documentada é zero, não um.
- `ORDERS ||--o{ PAYMENTS`: zero ou muitos. Existe ao menos um pedido com status `delivered` e itens associados que não possui nenhum registro de pagamento — um caso isolado e inconsistente, mas que já demonstra por si só que a cardinalidade mínima não pode ser um.
- `ORDERS ||--o{ REVIEWS`: zero ou muitos. Parte dos pedidos não tem nenhuma review associada.

## Chaves compostas

- `ORDER_ITEMS`: a chave é a combinação de `order_id` e `order_item_id`.
- `PAYMENTS`: a chave é a combinação de `order_id` e `payment_sequential` (um pedido pode ter mais de uma linha de pagamento, cada uma com um método diferente).
- `REVIEWS`: a chave é a combinação de `review_id` e `order_id` (um mesmo `review_id` pode estar associado a mais de um pedido, e um mesmo pedido pode ter mais de uma review em momentos diferentes).
