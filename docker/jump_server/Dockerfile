
# should run with host network, 
# so that the user can access local network
ARG SSH_PORT=2222
FROM ubuntu:noble

RUN cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.old
RUN echo "\
Types: deb \n\
URIs: http://mirrors.aliyun.com/ubuntu/ \n\
Suites: noble noble-updates noble-security \n\
Components: main restricted universe multiverse \n\
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg \
" > /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update -y && apt-get upgrade -y

RUN apt-get install -y python3 python3-pip python3-dev
RUN apt-get install -y openssh-server
RUN apt-get install -y tmux vim htop

RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR /root

ADD ./disable_ssh_password.sh /root/disable_ssh_password.sh
RUN chmod +x /root/disable_ssh_password.sh
RUN ./disable_ssh_password.sh
RUN rm /root/disable_ssh_password.sh

ADD ./set_ssh_port.sh /root/set_ssh_port.sh
RUN chmod +x /root/set_ssh_port.sh
RUN ./set_ssh_port.sh $SSH_PORT
RUN rm /root/set_ssh_port.sh

ADD ./create_user.sh /root/create_user.sh
RUN chmod +x /root/create_user.sh

RUN groupadd -g 2222 captain_users
EXPOSE $SSH_PORT
ENTRYPOINT service ssh restart && bash
