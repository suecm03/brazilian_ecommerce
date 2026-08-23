SELECT
    order_id,
    payment_sequential,
    {{ normalize_lower('payment_type') }} AS payment_type,
    payment_installments,
    payment_value
FROM
    {{ source('raw', 'payments') }}