{{ config(
    unique_key=["keyword_id", "created_datetime"]
) }}

SELECT 
    *
FROM {{ source("epsilo", "hourly_search_volume") }}
LIMIT 10