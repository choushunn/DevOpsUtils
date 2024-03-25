#!/usr/bin/bash

#安装docker
install_docker(){
str="开始安装 Docker..."
echo -e "\033[1m \033[31m${str}\033[0m"
if ! which docker > /dev/null;then
  #清理环境
  str="正在清理环境"
  echo -e "\033[1m \033[31m${str}\033[0m"
  sudo yum remove docker docker-client docker-client-latest \
  docker-common docker-latest docker-latest-logrotate \
  docker-logrotate  docker-engine

  #获取 docker
  str="正在获取 Docker repo"
  echo -e "\033[1m \033[31m${str}\033[0m"
  sudo yum install -y yum-utils
  sudo yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

  #安装docker
  str="正在安装 Docker"
  echo -e "\033[1m \033[31m${str}\033[0m"
  sudo yum install -y docker-ce docker-ce-cli containerd.io
  str="正在启动 Docker"
  echo -e "\033[1m \033[31m${str}\033[0m"

  #启动docker
  systemctl start docker  && systemctl enable docker

  str="Docker 镜像加速"
  echo -e "\033[1m \033[31m${str}\033[0m"

  #Docker镜像加速
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json << EOF
{
"exec-opts": ["native.cgroupdriver=systemd"],
"registry-mirrors":["https://docker.mirrors.ustc.edu.cn"]
}
EOF

  #重新加载
  sudo systemctl daemon-reload
  str="Docker 正在重启"
  echo -e "\033[1m \033[31m${str}\033[0m"

  #重启 Docker
  sudo systemctl restart docker
  sudo docker run hello-world

  #查看版本
  str="Docker 版本"
  echo -e "\033[1m \033[31m${str}\033[0m"
  docker version

  str="Docker 安装完成"
  echo -e "\033[1m \033[32m${str}\033[0m"
else
  str="Docker已经存在"
  echo -e "\033[1m \033[31m${str}\033[0m"
  docker --version | xargs echo
fi
}

#安装docker_compose
install_docker_compose(){
  str="开始安装 Docker compose ..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  if ! which docker-compose > /dev/null
  then
    str="Docker Compose 正在启动"
    echo -e "\033[1m \033[31m${str}\033[0m"
    sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    mv docker-compose /usr/local/bin/
    sudo chmod +x /usr/local/bin/docker-compose
    str="Docker Compose 安装完成"
    echo -e "\033[1m \033[32m${str}\033[0m"
  else
    str="Docker Compose 已经存在"
    echo -e "\033[1m \033[31m${str}\033[0m"
    docker-compose --version | xargs echo
  fi
}

#系统更新
system_update(){
#  CentOS7 yum
  str="系统正在更新..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  yum -y install wget
  mv /etc/yum.repos.d/CentOS-Base.repo.bak /etc/yum.repos.d/CentOS-Base.repo
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
  yum update -y
  yum upgrade -y
  str="系统更新完成"
  echo -e "\033[1m \033[32m${str}\033[0m"
}

#安装系统软件
install_software(){
  echo "正在安装系统组件..."
  BASIC="man gcc gcc-c++ make glibc sudo lsof  openssl tree vim bash-completion  yum-utils "
  EXT="net-tools psmisc sysstat"
  NETWORK="curl telnet traceroute wget ntp"
  LIBS="glibc-devel pcre pcre-devel openssl-devel zlib zlib-devel ruby"
  SOFTWARE="git zip unzip lrzsz "
  #dos2unix nethogs glances
  #虚拟机上传下载 lrzsz
  yum install -y $BASIC $EXT $NETWORK $LIBS $SOFTWARE
  #systemd-devel iotop bc screen tcpdump ntpdate
  str="正在清理临时文件"
  echo -e "\033[1m \033[32m${str}\033[0m"
  yum autoremove
  yum clean all
  yum makecache
  str="系统组件安装完毕。\n"
  echo -e "\033[1m \033[32m${str}\033[0m"
}

#关闭防火墙
stop_firewall(){
  str="正在关闭防火墙..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  firewall-cmd --state
  systemctl stop firewalld
  systemctl disable firewalld
  firewall-cmd --state
  str="防火墙关闭完成"
  echo -e "\033[1m \033[32m${str}\033[0m"
}

#关闭selinux
stop_selinux(){
  str="正在关闭Selinux..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  getenforce
  setenforce 0 #临时关闭selinux
  getenforce
  sed -i 's/^ *SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config  #永久关闭
  str="Selinux关闭完成"
  echo -e "\033[1m \033[32m${str}\033[0m"
}


init_all(){
  system_update
  install_software
  stop_firewall
  stop_selinux
  install_docker
  install_docker_compose
}

cat << EOF
软件安装操作
请输入要执行的操作的编号：[0-9]
============================
【0】全部执行
【1】安装 Docker
【2】安装 Docker Compose
【3】系统更新
【4】安装系统组件
【5】关闭防火墙
【6】关闭Selinux
【Q】退出
============================
EOF

if [[ $1 ]];then
  input=$1
  echo "执行操作：$1"
else
  read -p "请选择：" input
fi


case $input in
  0)init_all;;
  1)install_docker;;
  2)install_docker_compose;;
  3)system_update;;
  4)install_software;;
  5)stop_firewall;;
  6)stop_selinux;;
  8);;
  9);;
  *)exit;;
esac