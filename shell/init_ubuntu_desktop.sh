#! /bin/bash

# 更新软件列表
sudo apt update

# 修复复损坏的软件包，尝试卸载出错的包，重新安装正确版本
sudo apt-get -f install

# 自动卸载不需要的依赖
sudo apt-get --purge autoremove -y

# 更新软件
sudo apt upgrade -y

# 安装编译软件
sudo apt install vim net-tools openssh-server build-essential git python3-pip -y

# 安装媒体解码器
sudo apt install ubuntu-restricted-extras -y

# 设置双系统时间
sudo timedatectl set-local-rtc 1

#  卸载系统中可能存在的 nvidia 驱动
sudo apt remove --purge nvidia* -y

# 自动安装驱动
#sudo ubuntu-drivers autoinstall

# Nvidia-510
sudo apt intall nvidia-driver-510

# 安装 Docker
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


