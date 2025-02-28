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
(3, 123, 1, '2025-03-01 00:00:00', '2025-03-15 00:00:00', 'hourly');


--
-- View for search_volume in time range of keywords
--

-- Check valid subscription
-- SELECT *
-- FROM subscriptions
-- WHERE user_id=123
-- AND keyword_id=(SELECT keyword_id FROM keyword WHERE keyword_name='machine learning')
-- AND NOT (
--     end_time<='2025-03-5 06:00:00' OR start_time>='2025-03-01 23:59:59'
-- );

CREATE OR REPLACE VIEW vw_keyword_subscribes
AS
SELECT
	s.subscription_id, s.user_id, h.keyword_id, k.keyword_name, h.search_volume, 
    s.timing, h.created_datetime, s.start_time, s.end_time
FROM subscriptions s
JOIN hourly_search_volume h
	ON h.keyword_id=s.keyword_id AND (h.created_datetime BETWEEN s.start_time AND s.end_time)
JOIN keyword k
	ON k.keyword_id=s.keyword_id
;

