SELECT
    CAST(seller_id AS VARCHAR) AS seller_id,
    CAST({{ normalize_zip_code('seller_zip_code_prefix') }} AS VARCHAR) AS seller_zip_code_prefix,
    CAST({{ normalize_upper('seller_city') }} AS VARCHAR) AS seller_city,
    CAST({{ normalize_upper('seller_state') }} AS VARCHAR) AS seller_state
FROM
    {{ source('raw', 'sellers') }}
