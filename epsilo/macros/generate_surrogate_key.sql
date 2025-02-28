-- macros/custom_surrogate_key.sql
{% macro generate_surrogate_key(field_list) %}
    MD5(CONCAT(
        {% for field in field_list %}
            COALESCE(CAST({{ field }} AS CHAR), '') {% if not loop.last %}, '-'{% endif %}
        {% endfor %}
    ))
{% endmacro %}