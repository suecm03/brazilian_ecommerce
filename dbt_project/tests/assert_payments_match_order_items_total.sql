{{ config(severity = 'warn') }}

WITH pagamentos AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_pago
    FROM
        {{ ref('fct_payments') }}
    GROUP BY
        order_id
),

itens AS (
    SELECT
        order_id,
        SUM(price + freight_value) AS total_itens
    FROM
        {{ ref('fct_order_items') }}
    GROUP BY
        order_id
)

SELECT
    pagamentos.order_id,
    pagamentos.total_pago,
    itens.total_itens,
    ABS(pagamentos.total_pago - itens.total_itens) AS diferenca
FROM
    pagamentos
INNER JOIN
    itens
ON
    pagamentos.order_id = itens.order_id
WHERE
    ABS(pagamentos.total_pago - itens.total_itens) > 1
