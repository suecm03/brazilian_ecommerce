SELECT 
    review_id,
    order_id,
    review_score,
    LOWER(review_comment_title) AS review_comment_title,
    LOWER(review_comment_message) AS review_comment_message,
    CAST(review_creation_date AS TIMESTAMP) AS review_creation_date,
    CAST(review_answer_timestamp AS TIMESTAMP) AS review_answer_timestamp
FROM 
    {{ source('raw', 'reviews') }}