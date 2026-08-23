{% macro normalize_upper(column_name) %}
    UPPER(
        STRIP_ACCENTS(
            TRIM({{ column_name }})
        )
    )
{% endmacro %}

{% macro normalize_lower(column_name) %}
    LOWER(
        STRIP_ACCENTS(
            TRIM({{ column_name }})
        )
    )
{% endmacro %}

{% macro normalize_zip_code(column_name) %}
    LPAD(
        CAST({{ column_name }} AS VARCHAR), 
        5, '0'
    )
{% endmacro %}
