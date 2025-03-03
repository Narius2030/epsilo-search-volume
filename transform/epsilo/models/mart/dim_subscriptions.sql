{{ config(
    unique_key='subscription_key',
    depends_on=['stg_overlap_subscriptions']
) }}

WITH dimension AS (
    SELECT
        MD5(CONCAT(
            COALESCE(CAST(s.user_id AS CHAR), ''),
            '-',
            COALESCE(CAST(s.keyword_id AS CHAR), ''),
            '-',
            COALESCE(CAST(s.start_time AS CHAR), ''),
            '-',
            COALESCE(CAST(s.end_time AS CHAR), '')
        )) AS subscription_key,
        s.user_id, s.keyword_id, s.timing,
        s.start_time, s.end_time
    FROM {{ ref("stg_overlap_subscriptions") }} s
    GROUP BY user_id, keyword_id, timing, start_time, end_time
)

SELECT * FROM dimension