from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
import os
from datetime import datetime
from config import get_value
app = FastAPI()

# Mount static files directory
app.mount("/static", StaticFiles(directory="resources"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def read_env_variables(request: Request):
    ssm_parameter = os.getenv("SSM_PARAMETER", "Not Set")
    ssm_secret_parameter = os.getenv("SSM_SECRET_PARAMETER", "Not Set")
    s3_env_parameter = os.getenv("S3_ENV_PARAMETER", "Not Set")
    secrets_manager_parameter = os.getenv("SECRETS_MANAGER_PARAMETER", "Not Set")

    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "ssm_parameter": ssm_parameter,
            "ssm_secret_parameter": ssm_secret_parameter,
            "s3_env_parameter": s3_env_parameter,
            "secrets_manager_parameter": secrets_manager_parameter,
            "background": str(get_value("background", "#e3ffe3")),
            "now": datetime.now,
        }
    )

@app.get("/refresh")
async def get_env_variables():
    return JSONResponse({
        "ssm_parameter": os.getenv("SSM_PARAMETER", "Not Set"),
        "ssm_secret_parameter": os.getenv("SSM_SECRET_PARAMETER", "Not Set"),
        "s3_env_parameter": os.getenv("S3_ENV_PARAMETER", "Not Set"),
        "secrets_manager_parameter": os.getenv("SECRETS_MANAGER_PARAMETER", "Not Set"),
        "background": str(get_value("background", "#e3ffe3")),
        "last_refresh": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    })
