SELECT
    CAST(customer_id AS VARCHAR) AS customer_id,
    CAST(customer_unique_id AS VARCHAR) AS customer_unique_id,
    CAST({{ normalize_zip_code('customer_zip_code_prefix') }} AS VARCHAR) AS customer_zip_code_prefix,
    CAST({{ normalize_upper('customer_city') }} AS VARCHAR) AS customer_city,
    CAST({{ normalize_upper('customer_state') }} AS VARCHAR) AS customer_state
FROM
    {{ source('raw', 'customers') }}
