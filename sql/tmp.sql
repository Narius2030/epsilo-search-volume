USE epsilo;

WITH non_overlap AS (
	SELECT 
		s1.user_id,
		s1.keyword_id,
        s1.timing,
		MIN(s1.start_time) AS start_time,
		MAX(s1.end_time) AS end_time,
        CASE
			WHEN s1.start_time<=s2.start_time AND s1.end_time>=s2.end_time
			THEN s1.subscription_id ELSE s2.subscription_id
		END AS subscription_id
	FROM subscriptions s1
	JOIN subscriptions s2 
		ON s2.user_id=s1.user_id
		AND s2.keyword_id=s1.keyword_id
		AND s2.start_time<s1.end_time
		AND s1.start_time<s2.end_time
	GROUP BY s1.user_id, s1.keyword_id, s1.timing,
		CASE
			WHEN s1.start_time<=s2.start_time AND s1.end_time>=s2.end_time
			THEN s1.subscription_id ELSE s2.subscription_id
		END
)

SELECT 
    subscription_id, user_id, keyword_id, timing,
    MIN(start_time) AS start_time,
    MAX(end_time) AS end_time
FROM non_overlap
GROUP BY user_id, keyword_id, subscription_id, timing
;




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
FROM stg_overlap_subscriptions s
GROUP BY user_id, keyword_id, timing, start_time, end_time

