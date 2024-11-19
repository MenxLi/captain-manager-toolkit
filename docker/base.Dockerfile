FROM registry.cn-hangzhou.aliyuncs.com/limengxun/cuda:12.1.1-cudnn8-devel-ubuntu22.04

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN apt-get update -y && apt-get upgrade -y

# some dev tools
RUN apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential

# set up ssh
RUN mkdir -p ~/.ssh
RUN touch ~/.ssh/authorized_keys

# install other dependencies
RUN apt-get install -y rsync openssh-server tmux vim neovim
RUN apt-get install -y curl wget iproute2 iputils-ping proxychains-ng
RUN apt-get install -y htop iftop

# cpp things
RUN apt-get install -y clangd bear

# install python things
RUN apt-get install -y python3 python3-pip python3-dev
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN echo '\nalias python=python3\nalias pip=pip3\n' >> .bashrc


# set timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

ENV PATH="$PATH:/usr/local/cuda-12.1/bin"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-12.1/lib64"

WORKDIR /root
EXPOSE 22
EXPOSE 8080
