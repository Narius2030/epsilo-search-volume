{{ config(
    unique_key=["keyword_id", "created_datetime"]
) }}

SELECT 
    MD5(CONCAT(
        COALESCE(CAST(DATE(created_datetime) AS CHAR), ''),
        '-',
        COALESCE(CAST(keyword_id AS CHAR), '')
    )) AS hourly_key,
    keyword_id, 
    created_datetime, 
    search_volume
FROM {{ source("epsilo", "hourly_search_volume") }}