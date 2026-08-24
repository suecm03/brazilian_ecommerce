SELECT
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(payment_sequential AS BIGINT) AS payment_sequential,
    CAST({{ normalize_lower('payment_type') }} AS VARCHAR) AS payment_type,
    CAST(payment_installments AS BIGINT) AS payment_installments,
    CAST(payment_value AS DOUBLE) AS payment_value
FROM
    {{ source('raw', 'payments') }}
