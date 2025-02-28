{% macro custome_surrogate_key(field_list) %}
    MD5(CONCAT(
        {% for field in field_list %}
            COALESCE(CAST({{ field }} AS CHAR), '')
        {% endfor %}
    ))
{% endmacro %}