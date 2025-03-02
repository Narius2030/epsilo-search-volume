{{ config(
    unique_key='subscription_id',
    depends_on=['stg_overlap_subscriptions']
) }}

WITH dimension AS (
    SELECT
        MD5(CONCAT(
            COALESCE(CAST(s.user_id AS CHAR), ''),
            '-',
            COALESCE(CAST(s.keyword_id AS CHAR), ''),
            '-',
            COALESCE(CAST(s.subscription_id AS CHAR), '')
        )) AS subscription_key,
        s.subscription_id, s.user_id, s.keyword_id, s.timing,
        s.start_time, s.end_time
    FROM {{ ref("stg_overlap_subscriptions") }} s
)

SELECT * FROM dimension