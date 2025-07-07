# captain-manager-toolkit

实验室服务器管理用脚本和镜像:)

构建计算节点镜像：
```bash
make image CUDA_TAG="12.6.3-cudnn-devel-ubuntu22.04"
```

## 跳板容器
跳板容器允许用户通过统一的入口连接到其他局域网内的计算节点进行管理，
所有人共用一个端口进行ssh转发（可在主机上将此端口暴露到公网方便访问）。
```bash
make jump-build
make jump-run
```
默认跳板容器会使用宿主网络（`--network=host`）运行SSH服务，默认容器名称为`jump`，ssh端口为2222。

可以通过以下命令添加用户
```bash
# docker exec -it jump bash -c "create_user.sh <username> <public_key>"
# or: 
make jump-add
```
使用`ssh -p 2222 <username>@<host_ip>`连接到跳板容器。
在主机上使用`docker exec -it jump bash`进入容器进行用户管理。

删除用户可以使用以下命令：
```bash
docker exec -it jump bash -c "userdel -r <username>"
```