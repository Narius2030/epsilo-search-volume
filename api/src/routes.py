import sys
sys.path.append('./')

import logging
from src.models import KeyWord
from src.services import getHourlySearchVolume, getDailySearchVolume
from src.models import RespKeyWord
from fastapi import status, APIRouter, Body
from fastapi.responses import JSONResponse


# router
epsilo_router = APIRouter(
    prefix="/api/v1/epsilo",
    tags=["Keyword"],
    responses={404: {"description": "Not found"}}
)

logger = logging.getLogger("uvicorn")


@epsilo_router.post('/search-volume', status_code=status.HTTP_200_OK)
async def search_volume(keyword:KeyWord=Body(...)):
    if keyword.timing == 'hourly':
        values = await getHourlySearchVolume(keyword)
    else:
        values = await getDailySearchVolume(keyword)
    response = {
        "user_id": keyword.user_id,
        "timing": keyword.timing,
        "data": values
    }
    # logger.info(f'========== Fetched successfully: {len(response["data"]["hourly"])} ==========')
    return response


