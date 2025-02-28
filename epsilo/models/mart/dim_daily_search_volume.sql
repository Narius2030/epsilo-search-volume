{{ config(
    unique_key=["keyword_id", "created_date"]
) }}

SELECT DISTINCT
	MD5(CONCAT(
        COALESCE(CAST(DATE(created_datetime) AS CHAR), ''),
        '-',
        COALESCE(CAST(keyword_id AS CHAR), '')
    )) AS daily_key,
    keyword_id,
    DATE(created_datetime) AS created_date,
	SUM(search_volume) OVER (PARTITION BY keyword_id, DATE(created_datetime)) AS search_volume
FROM {{ source("epsilo", "hourly_search_volume") }}