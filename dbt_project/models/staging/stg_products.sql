SELECT
    CAST(product_id AS VARCHAR) AS product_id,
    CAST({{ normalize_lower('product_category_name') }} AS VARCHAR) AS product_category_name,
    CAST(product_name_lenght AS BIGINT) AS product_name_length,
    CAST(product_description_lenght AS BIGINT) AS product_description_length,
    CAST(product_photos_qty AS BIGINT) AS product_photos_qty,
    CAST(product_weight_g AS BIGINT) AS product_weight_g,
    CAST(product_length_cm AS BIGINT) AS product_length_cm,
    CAST(product_height_cm AS BIGINT) AS product_height_cm,
    CAST(product_width_cm AS BIGINT) AS product_width_cm
FROM
    {{ source('raw', 'products') }}
