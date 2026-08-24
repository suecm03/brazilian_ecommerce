SELECT
    CAST(review_id AS VARCHAR) AS review_id,
    CAST(order_id AS VARCHAR) AS order_id,
    CAST(review_score AS BIGINT) AS review_score,
    CAST(LOWER(review_comment_title) AS VARCHAR) AS review_comment_title,
    CAST(LOWER(review_comment_message) AS VARCHAR) AS review_comment_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM
    {{ source('raw', 'reviews') }}
