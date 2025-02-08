from typing import Optional
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import docker

from ..eng.docker import restart_container

app = FastAPI(docs_url=None, redoc_url=None)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
docker_client = docker.from_env()

@app.middleware("http")
async def log_requests(request, call_next):
    print(f"Request: {request.url}")
    print(f"Headers: {request.headers}")
    print(f"From: {request.client.host}")
    response = await call_next(request)
    return response

@app.post("/restart")
def restart_pod(container_name: str):
    return restart_container(docker_client, container_name, execute_after_restart="service ssh start")
                
def start_server(
    host: str = "0.0.0.0",
    port: int = 8000,
    workers: Optional[int] = None,
):
    import uvicorn
    uvicorn.run(f"pody.svc.app:app", host=host, port=port, workers=workers)