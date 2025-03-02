{{ config(
    unique_key=['subscription_key', 'hourly_key', 'datetime_key'],
    materialized='view',
    depends_on=['dim_subscriptions', 'dim_hourly_search_volume']
) }}


SELECT
    CAST(UNIX_TIMESTAMP(h.created_datetime) AS CHAR(255)) AS datetime_key,
    s.subscription_key, h.hourly_key,
	s.subscription_id, s.user_id, h.keyword_id, k.keyword_name, h.search_volume, 
    s.timing, h.created_datetime, s.start_time, s.end_time
FROM {{ ref("dim_subscriptions") }} s
JOIN {{ ref("dim_hourly_search_volume") }} h
	ON h.keyword_id=s.keyword_id AND (h.created_datetime BETWEEN s.start_time AND s.end_time)
JOIN {{ source("epsilo", "keyword") }} k
	ON k.keyword_id=s.keyword_id