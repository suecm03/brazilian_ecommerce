SELECT
    customer_id,
    customer_unique_id,
    {{ normalize_zip_code('customer_zip_code_prefix') }} AS customer_zip_code_prefix,
    {{ normalize_upper('customer_city') }} AS customer_city,
    {{ normalize_upper('customer_state') }} AS customer_state
FROM
    {{ source('raw', 'customers') }}