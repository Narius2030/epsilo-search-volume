{{ config(
    unique_key=["keyword_id", "created_datetime"]
) }}

SELECT 
    {{ generate_surrogate_key(['created_datetime']) }} AS hourly_key, 
    keyword_id, created_datetime, search_volume
FROM {{ source("epsilo", "hourly_search_volume") }}