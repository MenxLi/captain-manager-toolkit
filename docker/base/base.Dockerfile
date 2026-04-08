ARG CUDA_TAG=12.6.3-cudnn-devel-ubuntu24.04
FROM nvcr.io/nvidia/cuda:${CUDA_TAG}

ARG ARCH=amd64

RUN if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi

RUN if [ -f /etc/apt/sources.list ]; then \
        sed -i \
            -e 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' \
            -e 's|http://security.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' \
            /etc/apt/sources.list; \
    fi && \
    if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then \
        sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g; s|http://security.ubuntu.com/ubuntu/|http://mirrors.aliyun.com/ubuntu/|g' \
            /etc/apt/sources.list.d/ubuntu.sources; \
    fi

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
RUN apt-get install -y apt-utils
RUN apt-get install -y rsync openssh-server tmux vim neovim
RUN apt-get install -y curl wget iproute2 iputils-ping proxychains-ng
RUN apt-get install -y htop iftop lsof
RUN apt-get install -y zip unzip

# locale
RUN apt-get install -y locales
RUN locale-gen zh_CN.UTF-8
ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8

# timezone
ARG TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

# cpp things
RUN apt-get install -y clangd bear

# install python things
RUN apt-get install -y python3 python3-pip python3-dev python3-venv
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN echo '\nalias python=python3\nalias pip=pip3\n' >> .bashrc

# common libs
RUN apt-get install -y libsqlite3-dev libomp-dev libnuma-dev

# miniconda
# https://www.anaconda.com/docs/getting-started/miniconda/install
RUN mkdir -p ~/miniconda3
RUN if [ "$ARCH" = "amd64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh; \
    elif [ "$ARCH" = "arm64" ]; then \
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ~/miniconda3/miniconda.sh; \
    fi
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm ~/miniconda3/miniconda.sh
RUN . ~/miniconda3/bin/activate && conda init --all

# uv
RUN curl -sSf https://install.astral.sh/uv | sh

# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# node
RUN git clone https://github.com/nvm-sh/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abrev=0 --tags`
RUN . ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts && nvm alias --lts

WORKDIR /workspace
EXPOSE 22
EXPOSE 8000

# entrypoint
COPY --chmod=755 ./entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
