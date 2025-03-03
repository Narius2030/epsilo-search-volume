import sys
sys.path.append('./')

from src.models import KeyWord
from utils.sql import SQLOperators
from utils.setting import get_settings
from fastapi.exceptions import HTTPException

settings = get_settings()
sql_opt = SQLOperators("epsilo", settings)

async def getHourlySearchVolume(keyword:KeyWord):
    ## TODO: check valid request
    sql_string = f"""
        SELECT
            subscription_key
        FROM dim_subscriptions
        WHERE user_id={keyword.user_id}
        AND timing='{keyword.timing}'
        AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN {tuple(keyword.keywords) if len(keyword.keywords) > 1 else f"('{keyword.keywords[0]}')"})
        AND NOT (
            (end_time<'{keyword.start_time}') OR (start_time>'{keyword.end_time}')
        );
    """
    subs = sql_opt.execute_query(sql_string)
    if not subs:
        raise HTTPException(status_code=404, 
                            detail="user's subscription info is not found")
    try:
        sql_string = f"""
            SELECT
                keyword_name, search_volume, created_datetime
            FROM fact_hourly_volume
            WHERE user_id='{keyword.user_id}'
            AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN {tuple(keyword.keywords) if len(keyword.keywords) > 1 else f"('{keyword.keywords[0]}')"})
            AND (created_datetime BETWEEN '{keyword.start_time}' AND '{keyword.end_time}');
        """
        hourly_data = sql_opt.execute_query(sql_string)
        
        sql_string = f"""
            SELECT
                keyword_name, search_volume, created_date
            FROM fact_daily_volume
            WHERE user_id={keyword.user_id}
            AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN {tuple(keyword.keywords) if len(keyword.keywords) > 1 else f"('{keyword.keywords[0]}')"})
            AND (created_date BETWEEN '{keyword.start_time}' AND '{keyword.end_time}');
        """
        daily_data = sql_opt.execute_query(sql_string)
        
        return {
            "hourly": hourly_data,
            "daily": daily_data
        }
    except Exception as ex:
        raise HTTPException(status_code=505, 
                            detail=f"Internal Fail - {str(ex)}")
        

async def getDailySearchVolume(keyword:KeyWord):
    ## TODO: check valid request
    sql_string = f"""
        SELECT
            subscription_key
        FROM dim_subscriptions
        WHERE user_id={keyword.user_id}
        AND timing='{keyword.timing}'
        AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN {tuple(keyword.keywords) if len(keyword.keywords) > 1 else f"('{keyword.keywords[0]}')"})
        AND NOT (
            (end_time<'{keyword.start_time}') OR (start_time>'{keyword.end_time}')
        );
    """
    subs = sql_opt.execute_query(sql_string)
    if not subs:
        raise HTTPException(status_code=404, 
                            detail="user's subscription info is not found")
    try:
        sql_string = f"""
            SELECT
                keyword_name, search_volume, created_date
            FROM fact_daily_volume
            WHERE user_id={keyword.user_id}
            AND keyword_id IN (SELECT keyword_id FROM keyword WHERE keyword_name IN {tuple(keyword.keywords) if len(keyword.keywords) > 1 else f"('{keyword.keywords[0]}')"})
            AND (created_date BETWEEN '{keyword.start_time}' AND '{keyword.end_time}');
        """
        data = sql_opt.execute_query(sql_string)
        return data
    except Exception as ex:
        raise HTTPException(status_code=505, 
                            detail=f"Internal Fail - {str(ex)}")


if __name__ == "__main__":
    keyword = {
        "user_id": 123,
        "keywords": ['blockchain','machine learning'],
        "start_time": "2025-02-01 23:59:59",
        "end_time": "2025-03-10 00:00:00"
    }
    
    print(getHourlySearchVolume(keyword))