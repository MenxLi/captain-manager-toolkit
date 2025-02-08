import inspect
from typing import Optional
from functools import wraps
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import HTTPException
import docker

from ..eng.docker import restart_container, query_container_by_id
from ..eng.gpu import list_processes_on_gpus, GPUProcess
from ..eng.errors import *

app = FastAPI(docs_url=None, redoc_url=None)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)
docker_client = docker.from_env()
                    
def handle_exception(fn):
    @wraps(fn)
    async def wrapper(*args, **kwargs):
        try:
            if inspect.iscoroutinefunction(fn):
                return await fn(*args, **kwargs)
            return fn(*args, **kwargs)
        except Exception as e:
            if isinstance(e, HTTPException): 
                print(f"HTTPException: {e}, detail: {e.detail}")
            if isinstance(e, HTTPException): raise e
            if isinstance(e, InvalidInputError): raise HTTPException(status_code=400, detail=str(e))
            if isinstance(e, NotFoundError): raise HTTPException(status_code=404, detail=str(e))
            raise
    return wrapper


@app.middleware("http")
async def log_requests(request, call_next):
    print(f"Request: {request.url}")
    print(f"Headers: {request.headers}")
    print(f"From: {request.client.host}")
    response = await call_next(request)
    return response

@app.post("/restart")
@handle_exception
def restart_pod(container_name: str):
    return restart_container(docker_client, container_name, execute_after_restart="service ssh start")

@app.get("/gpu-status")
@handle_exception
def gpu_status(id: str):
    def _container_id_from_cgoup(cgoup: str) -> Optional[str]:
        last = cgoup.split("/")[-1]
        if not last.startswith("docker-"): return None
        if not last.endswith(".scope"): return None
        return last[len("docker-"):-len(".scope")]
    def process_gpu_proc(gpu_proc: GPUProcess):
        container_id = _container_id_from_cgoup(gpu_proc.cgoup)
        if container_id is None: return {"pid": gpu_proc.pid, "gpu_memory_used": gpu_proc.gpu_memory_used, "container": None}   # not running in a container
        container_info = query_container_by_id(docker_client, container_id)
        if container_info is not None:
            del container_info["ports"]
            del container_info["status"]
        return {
            "pid": gpu_proc.pid,
            "gpu_memory_used": gpu_proc.gpu_memory_used,
            "container": container_info
        }
    try:
        _ids = [int(i.strip()) for i in id.split(",")]
    except ValueError:
        raise InvalidInputError("Invalid GPU ID")
    gpu_procs = list_processes_on_gpus(_ids)
    return {gpu_id: [process_gpu_proc(proc) for proc in gpu_procs[gpu_id]] for gpu_id in gpu_procs}
                
def start_server(
    host: str = "0.0.0.0",
    port: int = 8000,
    workers: Optional[int] = None,
):
    import uvicorn
    uvicorn.run(f"pody.svc.app:app", host=host, port=port, workers=workers)