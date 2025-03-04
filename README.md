# Requirements

We build a service that collects hourly search volume of different keywords.
Daily data will be the record of 9:00AM every day or nearest time of the day if 9:00AM data is not available.
Users can subscribe and query the search volume hourly or daily in a range of time of any keyword.
Users can subscribe to the overlap timeline of a keyword and will see the union range of them.
Users who subscribe daily will not see data hourly but users who subscribe hourly will see the daily data.

Original 2 tables for record metrics look like this:

1. keyword:
    - keyword_id - bigint
    - keyword_name - varchar(255)
    - primary key (keyword_id)

2. keyword_search_volume:
    - keyword_id - bigint
    - created_datetime - datetime (hourly format - yyyy-MM-dd HH:00:00)
    - search_volume - bigint
    - primary key (keyword_id, created_datetime)

Write HTTP service in Python or Java to support query data
- Input in JSON:
    - user ID
    - list keywords
    - timing (hourly/daily)
    - start time
    - end time
- Return in JSON:
    - the search volume in the time range of input keywords following user subscription

# Data Flow
Dữ liệu khối lượng tìm kiếm được trích xuất từ ​​cơ sở dữ liệu nguồn (MySQL) và được biến đổi trong 2 bước: `staging` -> `mart`
- **staging:** là nơi lưu trữ trung gian trong quá trình biến đổi
- **mart:** chứa data có giá trị nghiệp vụ là các bảng `dimension và fact` trong `data warehouse`
- **API Endpoint:** tạo API để trích xuất search volume trong `khoảng thời gian` của input keywords tương ứng vói mỗi `user subscription`

Technology:
- **Database:** MySQL (source, data warehouse)
- **Transfromation tool:** DBT, SQL
- **HTTP Request:** FastAPI

![image](https://github.com/user-attachments/assets/b52ce773-964f-4ce3-bb07-9c76e3cbf2e4)


# Data Warehouse Design
**Source Database** bao gồm 3 bảng gốc là `keyword, hourly_search_volume (keyword_search_volume), subscriptions`

Đánh Indexing trên các bảng _hourly_search_volume_

![image](https://github.com/user-attachments/assets/46b5012c-3ab7-4d2a-a77c-7857b9ade835)


**Data Warehouse** tạo các bảng dimension và fact theo mô hình `Star schema (Kimball)`:
- **Table dim_hourly_search_volume**: dùng cho keyword search volume đã được ghi lại `hàng giờ`
- **Table dim_daily_search_volume**: dùng cho `tổng search volume theo giờ` của mỗi keyword được ghi mỗi ngày vào lúc `9:00 AM`
- **Table dim_subscriptions:** chứa user subscriptions đã được làm sạch từ staging view `stg_overlap_subscription`
- **View fact_hourly_volume:** trích xuất `theo giờ` search volume trong `khoảng thời gian` của mỗi user subscription
- **View fact_daily_volume:** rtrích xuất `theo ngày` search volume trong `khoảng thời gian` của mỗi user subscription

Đánh Indexing trên các bảng _dim_daily_search_volume, dim_hourly_search_volume và dim_subscriptions_ để tăng `hiệu suất truy vấn`

![image](https://github.com/user-attachments/assets/50397283-4318-4835-aff5-c79b21a323ff)



# HTTP Request
**Gửi Request:** sẽ được xác thực thông tin người dùng và khoảng thời gian học yêu cầu trích xuất, nếu thời gian hợp lệ với dữ liệu subscription sẽ tiến hành lấy data

```json
{
  "user_id": 0,
  "keywords": [
    "string"
  ],
  "timing": "hourly",
  "start_time": "2025-03-03T03:56:52",
  "end_time": "2025-03-03T03:56:52"
}
```

![image](https://github.com/user-attachments/assets/f8e95fe7-7cbb-4283-80f4-1b964c1bd42c)


**Nhận Response:** data được trả về có cấu trúc như sau
```json
{
    user_id: ...
    timing: ...
    data: [
        ...keyword search volume...
    ]
}
```

![image](https://github.com/user-attachments/assets/f810e19e-7d13-46d9-b8a6-35988327746c)


**Kiểm thử**

Input

```json
{
  "user_id": 123,
  "keywords": [
    "blockchain"
  ],
  "timing": "hourly",
  "start_time": "2025-02-01 23:59:59",
  "end_time": "2025-03-10 00:00:00"
}
```

Output

```
{
    "user_id": 123,
    "timing": "hourly",
    "data": {
    "hourly": [
        {
            "keyword_name": "blockchain",
            "search_volume": 1845,
            "created_datetime": "2025-03-01T00:00:00"
        },
        {
            "keyword_name": "blockchain",
            "search_volume": 457,
            "created_datetime": "2025-03-01T01:00:00"
        },
        ...
    ]
    "daily": [
        {
            "keyword_name": "blockchain",
            "search_volume": 24582,
            "created_date": "2025-03-01"
        },
        {
            "keyword_name": "blockchain",
            "search_volume": 22185,
            "created_date": "2025-03-02"
        },
        ...
    ]
}
```
