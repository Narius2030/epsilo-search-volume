from fastapi import FastAPI
from fastapi.responses import JSONResponse
from starlette.middleware.authentication import AuthenticationMiddleware
from starlette.middleware.cors import CORSMiddleware
from src.routes import epsilo_router

app = FastAPI(
    title="Metadata API", 
    docs_url='/docs', 
    openapi_url="/openapi.json"
)
app.include_router(epsilo_router)

# Add Middleware
origins = ['*']
# app.add_middleware(AuthenticationMiddleware, backend=JWTAuth())
# app.add_middleware( 
#     CORSMiddleware,
#     allow_origins=origins,
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"]
# )

@app.get('/')
def health_check():
    return JSONResponse(content={'status':'running'})