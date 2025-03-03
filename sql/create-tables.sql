USE epsilo;

CREATE TABLE keyword (
    keyword_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    keyword_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE hourly_search_volume (
    keyword_id BIGINT,
    created_datetime DATETIME,  -- yyyy-MM-dd HH:00:00
    search_volume BIGINT,
    PRIMARY KEY (keyword_id, created_datetime),
    FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id)
);

CREATE TABLE daily_search_volume (
    keyword_id BIGINT,
    created_date DATE,  -- yyyy-MM-dd
    search_volume BIGINT,
    PRIMARY KEY (keyword_id, created_date),
    FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id)
);

CREATE TABLE subscriptions (
    subscription_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    keyword_id BIGINT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    timing ENUM('hourly', 'daily') NOT NULL,
    FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id)
);
INSERT INTO subscriptions(subscription_id, user_id, keyword_id, start_time, end_time, timing) value
(4, 123, 8, '2025-03-10 00:00:00', '2025-03-25 00:00:00', 'hourly');


--
-- Check valid subscription
--

SELECT *
FROM dim_subscriptions
WHERE user_id=123
AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN ('blockchain'))
AND NOT (
    (end_time<'2025-01-01 23:59:59') OR (start_time>'2025-03-10 00:00:00')
);


SELECT 
	keyword_name, search_volume, created_datetime
FROM vw_fact_hourly_volume
WHERE user_id=123 
AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN ('blockchain', 'machine learning'))
AND (created_datetime BETWEEN '2025-02-01 23:59:59' AND '2025-03-10 00:00:00')
;

SELECT 
    keyword_name, search_volume, created_date
FROM vw_fact_daily_volume
WHERE user_id=123 
AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN ('blockchain', 'machine learning'))
AND (created_date BETWEEN '2025-02-01 23:59:59' AND '2025-03-10 00:00:00')
;

SELECT * FROM vw_fact_daily_volume;

--
-- View for search_volume in time range of keywords
--


CREATE OR REPLACE VIEW vw_fact_hourly_volume
AS
SELECT
	CAST(UNIX_TIMESTAMP(h.created_datetime) AS CHAR(255)) AS datetime_key,
	s.subscription_key, h.hourly_key,
	s.user_id, h.keyword_id, k.keyword_name, h.search_volume, 
    s.timing, h.created_datetime, s.start_time, s.end_time
FROM dim_subscriptions s
JOIN dim_hourly_search_volume h
	ON h.keyword_id=s.keyword_id AND (h.created_datetime BETWEEN s.start_time AND s.end_time)
JOIN keyword k
	ON k.keyword_id=s.keyword_id
;


CREATE OR REPLACE VIEW vw_fact_daily_volume
AS
SELECT
	CAST(UNIX_TIMESTAMP(h.created_date) AS CHAR(255)) AS datetime_key,
	s.subscription_key, h.daily_key,
	s.user_id, h.keyword_id, k.keyword_name, h.search_volume, 
    s.timing, h.created_date, s.start_time, s.end_time
FROM dim_subscriptions s
JOIN dim_daily_search_volume h
	ON h.keyword_id=s.keyword_id AND (h.created_date BETWEEN s.start_time AND s.end_time)
JOIN keyword k
	ON k.keyword_id=s.keyword_id
;


