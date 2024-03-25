#! /bin/bash

# 更新软件列表
sudo apt update

# 修复复损坏的软件包，尝试卸载出错的包，重新安装正确版本
sudo apt -f install

# 自动卸载不需要的依赖
sudo apt --purge autoremove -y

# 更新软件
sudo apt upgrade -y

# 安装必要软件
sudo apt install vim net-tools openssh-server build-essential git python3-pip -y

# 安装媒体解码器
# sudo apt install ubuntu-restricted-extras -y

# 设置双系统时间
sudo timedatectl set-local-rtc 1

#  卸载系统中可能存在的 nvidia 驱动
sudo apt remove --purge nvidia*

# 自动安装驱动
#sudo ubuntu-drivers autoinstall


# 安装 Docker
#sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


# 安装3588编译环境
sudo apt install gnupg xsltproc libz-dev gcc liblz-dev m4 perl libxml2-utils wget bc pngcrush unzip expect zlib1g-dev liblz4-tool cvs gperf flex lib32readline-dev uuid tar make liblzo2-dev openjdk-8-jdk libswitch-perl binutils gcc-multilib schedtool file zip texinfo g++ bzip2 android-sdk-ext4-utils libsdl1.2-dev git-core diffstat fakeroot libncurses5 sed build-essential gawk binfmt-support subversion g++-multilib libesd-java ssh device-tree-compiler lib32ncurses5-dev chrpath uuid-dev git lib32z1-dev android-sdk-libsparse-utils libssl-dev rsync mtd-utils liblzo2-2 mercurial curl patchelf cmake cpio squashfs-tools libxml2 bison gzip libncurses5-dev lzop live-build patch libc6-dev gdisk u-boot-tools bzr qemu-user-static  -y


# 自动卸载不需要的依赖
sudo apt --purge autoremove