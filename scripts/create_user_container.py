from pody.docker_utils import create_container, ContainerConfig
import argparse
import docker
from typing import Optional, List

def create_user_container(
    username: str, 
    ssh_port: int,
    container_name_suffix: Optional[str] = None,
    extra_port: Optional[int] = None,               # map to 8000 
    gpu_ids: Optional[List[int]] = None,
):
    client = docker.from_env()
    config = ContainerConfig(
        image_name="ubuntu2204-cu121-base",
        container_name=username + (f"-{container_name_suffix}" if container_name_suffix else ""),
        volumes=[f"/data/{username}:/data/{username}"],
        port_mapping=[f"{ssh_port}:22"] + ([f"{extra_port}:8000"] if extra_port else []),
        memory_limit="96g", 
        gpu_ids=gpu_ids,
    )
    return create_container(client, config)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("username", type=str)
    parser.add_argument("ssh_port", type=int)
    parser.add_argument("--tag", type=str, default=None, help="Container name suffix")
    parser.add_argument("--extra_port", type=int, default=None, help="Map to 8000")
    parser.add_argument("--gpu-ids", type=int, nargs="+", default=None, help="GPU ids")
    args = parser.parse_args()
    create_user_container(args.username, args.ssh_port, 
                          container_name_suffix=args.tag, 
                          extra_port=args.extra_port, 
                          gpu_ids=args.gpu_ids
                          )