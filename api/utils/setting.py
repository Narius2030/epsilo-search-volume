import os
from pathlib import Path
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

env_path = Path(".") / ".env"
load_dotenv(dotenv_path=env_path)

class Settings(BaseSettings):
    # Trino
    TRINO_USER:str = os.getenv('TRINO_USER')
    TRINO_HOST:str = os.getenv('TRINO_HOST')
    TRINO_PORT:str = os.getenv('TRINO_PORT')
    TRINO_CATALOG:str = os.getenv('TRINO_CATALOG')
    # Mysql
    MYSQL_HOST:str = os.getenv('MYSQL_HOST')
    MYSQL_PORT:str = os.getenv('MYSQL_PORT')
    MYSQL_USER:str = os.getenv('MYSQL_USER')
    MYSQL_PASSWORD:str = os.getenv('MYSQL_PASSWORD')
    MYSQL_DATABASE:str = os.getenv('MYSQL_DATABASE')
    
    
def get_settings() -> Settings:
    return Settings()