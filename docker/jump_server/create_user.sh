#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <username> <public_key>"
    exit 1
fi

USERNAME=$1
PUBLIC_KEY=$2
USERGROUP="captain_users"

generate_strong_password() {
    local password_length=32
    local special_chars='!^()-_=+:.?'
    local all_chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'"$special_chars"
    local password=$(cat /dev/urandom | tr -dc "$all_chars" | fold -w "$password_length" | head -n 1)
    echo "$password"
}

useradd -m -d /home/$USERNAME -s /bin/bash -g $USERGROUP $USERNAME

echo "$USERNAME:$(generate_strong_password)" | chpasswd

USER_SSH_DIR="/home/$USERNAME/.ssh"
mkdir -p $USER_SSH_DIR
if grep -q "$PUBLIC_KEY" $USER_SSH_DIR/authorized_keys; then
    echo "Public key already exists for user $USERNAME."
else
    echo "Adding public key for user $USERNAME."
    echo "$PUBLIC_KEY" >> $USER_SSH_DIR/authorized_keys
fi
chmod 700 $USER_SSH_DIR
chmod 600 $USER_SSH_DIR/authorized_keys
chown -R $USERNAME:$USERGROUP $USER_SSH_DIR

su - $USERNAME -c "pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple"
su - $USERNAME -c "echo alias python='python3' >> ~/.bashrc\n"
su - $USERNAME -c "echo alias pip='pip3' >> ~/.bashrc\n"