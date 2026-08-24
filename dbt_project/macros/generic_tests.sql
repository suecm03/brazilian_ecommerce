{% test non_negative(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < 0

{% endtest %}


{% test after_column(model, column_name, reference_column) %}

SELECT *
FROM {{ model }}
WHERE {{ column_name }} < {{ reference_column }}

{% endtest %}


{% test unique_combination_of_columns(model, combination_of_columns) %}

SELECT
    {{ combination_of_columns | join(', ') }},
    COUNT(*) AS n_registros
FROM {{ model }}
GROUP BY {{ combination_of_columns | join(', ') }}
HAVING COUNT(*) > 1

{% endtest %}
