[dockerfile](https://docs.docker.com/engine/reference/builder/)

## Hub 换源
[Docker Hub 镜像源](https://juejin.cn/post/7165806699461378085)
[阿里云镜像加速器](https://help.aliyun.com/zh/acr/user-guide/accelerate-the-pulls-of-docker-official-images?spm=5176.12818093_-1363046575.top-nav.92.3be916d0st6szw&scm=20140722.S_help%40%40文档%40%4060750.S_RQW%40ag0%2BBB2%40ag0%2BBB1%40ag0%2Bhot%2Bos0.ID_60750-RL_镜像加速器-LOC_console~UND~help-OR_ser-V_3-P0_0)

[Github - Docker 国内镜像](https://github.com/dongyubin/DockerHub.git)

```json
{ 
	"registry-mirrors": [ 
		"https://dockerproxy.com", 
		"https://hub-mirror.c.163.com", 
		"https://mirror.baidubce.com",
		"https://ccr.ccs.tencentyun.com"
	] 
}
```
> http服务需要填写到`insecure-registries`下面

> 配置文件所在位置：
> - Linux: `/etc/docker/daemon.json`


## Use proxy
To make Docker use the proxy, you will have to configure `dockerd`. One way to do this is to create the file `/etc/systemd/system/docker.service.d/proxy.conf` (or run `sudo systemctl edit docker.service`) with the following content:

```ini
[Service]
Environment="HTTP_PROXY=socks5://127.0.0.1:8080"
Environment="HTTPS_PROXY=socks5://127.0.0.1:8080"
Environment=“NO_PROXY=localhost,127.0.0.1”
```

(You most likely do not even need the `HTTP_PROXY` line, but it also doesn’t hurt. ;-) )

Once this file is in place, you need to restart the Docker service:

```bash
systemctl daemon-reload
systemctl restart docker
```

## Check
```sh
docker ps -a
docker ps --no-trunc  # long id
docker inspect ...
```

# build
```
docker build -t <image_name> .
docker tag <image_name> <new_image_name>
```

build with `--network host` to use host ip and proxy

## Docker volumes
[Official-volumes](https://docs.docker.com/storage/volumes/)
Create:
```sh
docker volume create my-vol
```
List:
```sh
docker volume ls
```
Inspect:
```sh
docker volume inspect my_vol
```
Remove:
```console
docker volume rm my_vol
```

[Docker: Named Volumes and Bind Mounts](https://www.christopherng.org/posts/docker-named-volumes-and-bind-mounts/#)

# Run docker
```sh
docker run <image_name>
docker start/stop <container_name>
docker attach <container_name>
docker rm <container_name>
docker rmi <image_name>
```

detach from an interactive docker terminal:
> Once attached to a container, users detach from it and leave it running using the using `CTRL-p CTRL-q` key sequence. This detach key sequence is customizable using the `detachKeys` property.

## Execute commands
```sh
docker exec [-it] <container_name> <commands> ...
```

**Useful command args**: 
[docker run](https://docs.docker.com/engine/reference/commandline/run/):
- `--name`: Assign a name to the container
- `-d / --detached`:  Run container in background and print container ID
- `-e / --expose`: Expose a port or a range of ports
- `--gpus`: GPU devices to add to the container (‘all’ to pass all GPUs)
- `-v / --volume`: Bind mount a volume
- `-i / --interactive`: Keep STDIN open even if not attached
- `-t / --tty`: Allocate a pseudo-TTY
- `-p / --expose`: Expose a port or a range of ports, usage: `--expose=7000-8000`, `-p <host_port>:<container_port>`
- `-w / --workdir`: Working directory inside the container. If the path does not exist, Docker creates it inside the container.
- `--restart`: Restart policy to apply when a container exits, usage: `--restart=always / unless-stopped`
- `-m / --memory`: The maximum amount of memory the container can use, usage: `--memory=512m or -m=4g`
- `--cpus`: specify how much of the available CPU resources a container can use. usage: `--cpus=1.5` uses as most one and half cpu
- [`--add-host`](https://docs.docker.com/reference/cli/docker/container/run/#add-host): Add a custom host-to-IP mapping (host:ip). usage: `--add-host=host.docker.internal:host-gateway`

examples:
- [run with volume](https://docs.docker.com/engine/reference/commandline/run/#volume)
- [expose port](https://docs.docker.com/engine/reference/commandline/run/#publish)
	- `docker run -p <hostPort>:<containerPort> imageName`
- [expose GPUs](https://docs.docker.com/engine/reference/commandline/run/#gpus)

[docker start](https://docs.docker.com/engine/reference/commandline/start/)
- `-a / --attach`: Attach STDOUT/STDERR and forward signals
- `-i / --interactive`: Attach container’s STDIN


# Checkout docker process
```
docker images
docker ps
docker ps -a
docker logs <container_name>
docker attach <container_name>
```

# Hub
```
docker push <image_name>
```


## Space check and Prune
### Check space
[How to Check Disk Space Usage for Docker Images, Containers and Volumes](https://linuxhandbook.com/docker-disk-space-usage/)
```sh
docker system df [-v]
```

check all image size: `docker image ls`
check running container size: `docker ps --size`
with formatted output:
```sh
docker ps -a --format="table {{.Names}}\t{{.Status}}\t{{.Size}}" --size
```

[How to clean up docker](https://stackoverflow.com/a/64917377)

### Prune
Remove as much as possible: 
[Clear space](https://apple.stackexchange.com/a/339608): `docker system prune -a`

Remove dangling images - [Image prune](https://docs.docker.com/engine/reference/commandline/image_prune/):  
```
docker image prune
```


## NVIDIA Docker
[Installation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
(CDI - [container-device-interface](https://github.com/container-orchestrated-devices/container-device-interface/blob/main/SPEC.md))
examples:
```sh
sudo docker run --rm -it --runtime=nvidia --gpus all nvidia/cuda:11.7.1-devel-ubuntu22.04
```


## Save and transfer docker image
[Save and transfer docker image](https://stackoverflow.com/questions/23935141/how-to-copy-docker-images-from-one-host-to-another-without-using-a-repository)
```
docker save -o <path for generated tar file> <image name>
docker load -i <path to image tar file>
```
e.g. `docker save -o c:/myfile.tar centos:16`

# Trouble shooting
[Docker container not starting (docker start)](https://stackoverflow.com/a/29957746)
[How to SSH Into a Docker Container](https://www.howtogeek.com/devops/how-to-ssh-into-a-docker-container/)
[Failed to initialize NVML: Unknown Error without any kublet update(cpu-manager-policy is default none)](https://github.com/NVIDIA/nvidia-docker/issues/1618#issuecomment-1120104007)
[Failed to initialize NVML](https://stackoverflow.com/a/76646962/6775765)
my solution: change docker cgroup - `"exec-opts": ["native.cgroupdriver=cgroupfs"]`
[docker change cgroup driver to systemd](https://stackoverflow.com/questions/43794169/docker-change-cgroup-driver-to-systemd)
[Get container ip address](https://stackoverflow.com/a/46310428/6775765): `docker inspect <container id> | grep "IPAddress"` 

[run with out sudo](https://www.linuxtechi.com/install-docker-on-opensuse-leap/):  [[docker_wo_sudo-user_man.png]]
```sh
sudo usermod -aG docker $USER
newgrp docker
```


## 阿里云代理
[docker-image-pusher](https://github.com/MenxLi/docker_image_pusher)

## Access host IP
```
--add-host=host.docker.internal:host-gateway
```


## 迁移容器位置
[迁移 Docker 容器储存位置](https://zhuanlan.zhihu.com/p/73576522)
验证Docker存储设置：
```sh
> docker info | grep "Docker Root Dir"
	Docker Root Dir: /var/lib/docker
```

停止docker并转移数据：
```sh
service docker stop
mkdir -p /data/docker/
rsync -avz /var/lib/docker/ /data/docker
```
编辑 `/etc/docker/daemon.json` 配置文件，如果没有这个文件，那么需要自己创建一个，根据上面的迁移目录，基础配置如下：

```text
{
    "data-root": "/data/docker"
}
```
将容器服务启动起来。
```sh
service docker start
docker info | grep "Docker Root Dir"    # ensure settings
rm -rf /var/lib/docker
```
