#!/bin/bash

# modified from: https://github.com/hosteons/SSH-Port-Changer-Script/blob/main/ssh_port_changer.sh

# SSH Port Changer Script for Ubuntu, Debian, CentOS, AlmaLinux
# Developed by Hosteons.com
# License: MIT

set -e

# Detect OS
if [ -e /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
  OS_VER=$VERSION_ID
else
  echo "Unsupported OS"
  exit 1
fi

NEW_PORT=${1:-2222}  # Default to 2222 if no argument is provided

# Backup sshd_config
# cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)

# Update sshd_config
if grep -qE '^#?Port ' /etc/ssh/sshd_config; then
  sed -i "s/^#\?Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config
else
  echo "Port $NEW_PORT" >> /etc/ssh/sshd_config
fi

# Allow new port in firewall
if command -v ufw >/dev/null 2>&1; then
  echo "Detected ufw. Adding rule."
  ufw allow $NEW_PORT/tcp || true
elif command -v firewall-cmd >/dev/null 2>&1; then
  echo "Detected firewalld. Adding rule."
  firewall-cmd --permanent --add-port=$NEW_PORT/tcp || true
  firewall-cmd --reload || true
elif command -v iptables >/dev/null 2>&1; then
  echo "Detected iptables. Adding rule."
  iptables -I INPUT -p tcp --dport $NEW_PORT -j ACCEPT
  if command -v netfilter-persistent >/dev/null 2>&1; then
    netfilter-persistent save
  elif command -v service >/dev/null 2>&1 && service iptables save >/dev/null 2>&1; then
    service iptables save
  fi
else
  echo "No supported firewall manager found. Please open the port manually if needed."
fi

# Handle SELinux
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" != "Disabled" ]; then
  if command -v semanage >/dev/null 2>&1; then
    echo "SELinux is enforcing. Adding port context."
    semanage port -a -t ssh_port_t -p tcp $NEW_PORT 2>/dev/null || semanage port -m -t ssh_port_t -p tcp $NEW_PORT
  else
    echo "SELinux is enforcing but semanage is not installed. Installing policycoreutils-python-utils."
    if [[ $OS_ID == "centos" || $OS_ID == "almalinux" ]]; then
      yum install -y policycoreutils-python-utils
    elif [[ $OS_ID == "ubuntu" || $OS_ID == "debian" ]]; then
      apt install -y policycoreutils-python-utils || apt install -y policycoreutils-python
    fi
    semanage port -a -t ssh_port_t -p tcp $NEW_PORT 2>/dev/null || semanage port -m -t ssh_port_t -p tcp $NEW_PORT
  fi
fi

echo "SSH port successfully changed to $NEW_PORT."