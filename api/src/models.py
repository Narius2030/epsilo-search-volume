from datetime import datetime
from typing import List, Literal, Dict, Any
from pydantic import BaseModel, Field, ValidationError, field_validator

class KeyWord(BaseModel):
    user_id: int = Field(...)
    keywords: List[str] = Field(...)
    timing: Literal["hourly", "daily"] = Field(...)
    start_time: datetime = Field(...)
    end_time: datetime = Field(...)
    
    @field_validator("timing", mode='before')
    @classmethod
    def is_valid_timing(cls, timing:str):
        if timing in ["hourly", "daily"]:
            return timing
        raise ValueError(f'{timing} is not an valid timing')
        
    @field_validator("start_time", mode='after')
    @classmethod
    def is_valid_start_time(cls, start_time: datetime):
        if start_time >= datetime(2025, 1, 1, 0, 0, 0):
            return start_time
        raise ValueError(f'start_time has to be greater than or equal 2025-01-01 00:00:00')
    
    @field_validator("end_time", mode='after')
    @classmethod
    def is_valid_end_time(cls, end_time: datetime):
        if end_time <= datetime(2025, 3, 31, 23, 0, 0):
            return end_time
        raise ValueError(f'end_time has to be less than or equal 2025-03-31 23:00:00')
    
    
class RespKeyWord(BaseModel):
    user_id: int = Field(...)
    keywords: List[int] = Field(...)
    timing: Literal["hourly", "daily"] = Field(...)
    data: List[Dict[str, Any]]
    
    @field_validator("timing", mode='before')
    @classmethod
    def is_valid_timing(cls, timing:str):
        if timing in ["hourly", "daily"]:
            return timing
        raise ValueError(f'{timing} is not an valid timing')