SELECT
    seller_id,
    {{ normalize_zip_code('seller_zip_code_prefix') }} AS seller_zip_code_prefix,
    {{ normalize_upper('seller_city') }} AS seller_city,
    {{ normalize_upper('seller_state') }} AS seller_state
FROM
    {{ source('raw', 'sellers') }}