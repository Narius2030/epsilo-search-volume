import sys
sys.path.append('./')

import time
import mysql.connector
from utils.setting import Settings
from contextlib import closing


class SQLOperators:
    def __init__(self, conn_id: str, settings: Settings):
        try:
            self.settings = settings
            self.__dbconn = mysql.connector.connect(
                host=settings.MYSQL_HOST,
                port=settings.MYSQL_PORT,
                user=settings.MYSQL_USER,
                password=settings.MYSQL_PASSWORD,
                database=conn_id
            )
        except Exception as ex:
            raise Exception(f"====> Can't connect to '{conn_id}' database with host: {self.settings.TRINO_HOST} - {str(ex)}")
    
    def execute_query(self, query):
        try:
            with closing(self.__dbconn.cursor()) as cursor:
                cursor.execute(query)
                data = cursor.fetchall()
                return [dict(zip([col[0] for col in cursor.description], row)) for row in data]
        except Exception as ex:
            raise Exception(f"====> Can't execute query: {query} - {str(ex)}")