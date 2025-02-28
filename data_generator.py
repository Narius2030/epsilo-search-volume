import random
import mysql.connector
from datetime import datetime, timedelta
from config import get_settings

# Kết nối MySQL
settings = get_settings()
conn = mysql.connector.connect(
    host=settings.MYSQL_HOST,
    port=settings.MYSQL_PORT,
    user=settings.MYSQL_USER,
    password=settings.MYSQL_PASSWORD,
    database=settings.MYSQL_DATABASE
)


def keyword(keywords:list):
    # 🔹 Chèn dữ liệu vào bảng keyword
    with conn.cursor() as cursor:
        try:
            # Xóa dữ liệu cũ nếu có
            cursor.execute("DELETE FROM keyword")
            conn.commit()
            # Chèn dữ liệu mới
            for i, kw in enumerate(keywords, start=1):
                cursor.execute("INSERT INTO keyword (keyword_id, keyword_name) VALUES (%s, %s)", (i, kw))
            conn.commit()
            print("[✅] Đã chèn dữ liệu vào bảng 'keyword'")
        except Exception as ex:
            raise Exception(f"Something wrong when inserting - {ex}")


def hourly_search_volume(start_date, end_date):
    data = []
    current_time = start_date
    insert_query = "INSERT INTO hourly_search_volume (keyword_id, created_datetime, search_volume) VALUES (%s, %s, %s)"
    with conn.cursor() as cursor:
        while current_time <= end_date:
            for keyword_id in range(1, 11):  # 10 keyword_id từ 1 -> 10
                search_volume = random.randint(50, 5000)  # Giá trị ngẫu nhiên trong khoảng 50 - 5000
                data.append((keyword_id, current_time.strftime('%Y-%m-%d %H:%M:%S'), search_volume))

            # Cập nhật thời gian
            current_time += timedelta(hours=1)

            # Chèn theo batch 5000 bản ghi/lần để tối ưu hiệu suất
            if len(data) >= 5000:
                cursor.executemany(insert_query, data)
                conn.commit()
                print(f"[✅] Đã chèn {len(data)} bản ghi vào 'hourly_search_volume'")
                data = []
                
                

if __name__ == "__main__":
    # keywords = [
    #     "machine learning", "deep learning", "data science", "artificial intelligence", "big data",
    #     "cloud computing", "edge computing", "blockchain", "quantum computing", "computer vision"
    # ]
    # keyword(keywords)
    
    start_date = datetime(2025, 1, 1, 0, 0, 0)
    end_date = datetime(2025, 3, 31, 23, 0, 0)
    hourly_search_volume(start_date, end_date)