{{ config(
    unique_key=['subscription_key', 'daily_key', 'datetime_key'],
    materialized='view',
    depends_on=['dim_subscriptions', 'dim_daily_search_volume']
) }}


SELECT
	CAST(UNIX_TIMESTAMP(h.created_date) AS CHAR(255)) AS datetime_key,
	s.subscription_key, h.daily_key,
	s.subscription_id, s.user_id, h.keyword_id, k.keyword_name, h.search_volume, 
    s.timing, h.created_date, s.start_time, s.end_time
FROM {{ ref("dim_subscriptions") }} s
JOIN {{ ref("dim_daily_search_volume") }} h
	ON h.keyword_id=s.keyword_id AND (h.created_date BETWEEN s.start_time AND s.end_time)
JOIN {{ source("epsilo", "keyword") }} k
	ON k.keyword_id=s.keyword_id