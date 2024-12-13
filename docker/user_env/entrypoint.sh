#!/bin/bash

# 检查输入参数是否齐全
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <username> <user_id> <password> <public_key>"
  exit 1
fi

USERNAME=$1
USER_ID=$2  # 接收用户 ID 参数
PASSWORD=$3
PUBLIC_KEY=$4

# 创建用户并设置 shell 和 UID
useradd -m -d /home/$USERNAME -s /bin/bash -u $USER_ID $USERNAME
usermod -aG sudo $USERNAME

# 设置新用户密码
echo "$USERNAME:$PASSWORD" | chpasswd

# 配置 SSH 公钥
USER_SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p $USER_SSH_DIR
echo "$PUBLIC_KEY" > $USER_SSH_DIR/authorized_keys
chmod 700 $USER_SSH_DIR
chmod 600 $USER_SSH_DIR/authorized_keys
chown -R $USERNAME:$USERNAME $USER_SSH_DIR

# 配置 root 用户的密码
echo "root:$PASSWORD" | chpasswd

# 配置 root 用户的 SSH 公钥
ROOT_SSH_DIR="/root/.ssh"
mkdir -p $ROOT_SSH_DIR
echo "$PUBLIC_KEY" > $ROOT_SSH_DIR/authorized_keys
chmod 700 $ROOT_SSH_DIR
chmod 600 $ROOT_SSH_DIR/authorized_keys
chown -R root:root $ROOT_SSH_DIR

service ssh start

# 启动 bash shell
exec /bin/bash
