#!/bin/bash
#安装Nginx
install_nginx(){
  str="开始安装 Nginx..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  if ! which nginx > /dev/null
  then
    str="正在安装 Nginx 依赖包"
    echo -e "\033[1m \033[31m${str}\033[0m"
    yum -y install zlib zlib-devel openssl openssl-devel pcre-devel \
    gcc gcc-c++ autoconf automake
    groupadd nginx
    useradd -r -g nginx nginx
    str="正在下载 Nginx"
    echo -e "\033[1m \033[31m${str}\033[0m"
    wget -P /tmp 'http://tengine.taobao.org/download/tengine-2.3.3.tar.gz'
    tar -xzf /tmp/tengine-2.3.3.tar.gz -C /tmp
    cd /tmp/tengine-2.3.3
    str="正在编译 Nginx"
    echo -e "\033[1m \033[31m${str}\033[0m"
    ./configure --prefix=/usr/local/nginx \
    --user=nginx --group=nginx \
    --with-http_ssl_module --with-http_flv_module \
    --pid-path=/usr/local/nginx/nginx.pid
    str="正在安装 Nginx"
    echo -e "\033[1m \033[31m${str}\033[0m"
    make
    make install
    cd -
    rm -rf /tmp/tengine*
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
    str="Nginx 正在启动"
    echo -e "\033[1m \033[32m${str}\033[0m"
    nginx
    str="Nginx 安装完成"
    echo -e "\033[1m \033[32m${str}\033[0m"
  else
    str="Nginx 已经存在"
    echo -e "\033[1m \033[31m${str}\033[0m"
    nginx -v | xargs echo
  fi
}

#安装redis
install_redis(){
str="开始安装 Redis"
  echo -e "\033[1m \033[31m${str}\033[0m"
  if ! which redis-server > /dev/null
  then
    str="正在下载 Redis"
    echo -e "\033[1m \033[31m${str}\033[0m"
    wget -P /tmp/ https://download.redis.io/releases/redis-6.2.3.tar.gz
    tar -xzf /tmp/redis-6.2.3.tar.gz -C /tmp
    cd /tmp/redis-6.2.3
    make install PREFIX=/usr/local/redis
    cp /tmp/redis-6.2.3/redis.conf /usr/local/redis/redis.conf
    cd -
    rm -rf /tmp/redis*
    sed -i '$adaemonize yes' /usr/local/redis/bin/redis.conf
    str="正在添加环境变量"
    echo -e "\033[1m \033[31m${str}\033[0m"
    sed -i '$aexport PATH=$PATH:/usr/local/redis/bin' /etc/profile
    source /etc/profile
    str="Redis 正在启动"
    echo -e "\033[1m \033[31m${str}\033[0m"
    redis-server /usr/local/redis/redis.conf
    str="Redis安装完成"
    echo -e "\033[1m \033[32m${str}\033[0m"
  else
    str="Redis 已经存在"
    echo -e "\033[1m \033[31m${str}\033[0m"
    redis-server -v | xargs echo
  fi
}

##安装pyenv
install_pyenv(){
  str="开始安装 pyenv..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  if ! which pyenv > /dev/null
  then
    str="正在安装 pyenv"
    echo -e "\033[1m \033[31m${str}\033[0m"
    curl -L  https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bash_profile
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    source ~/.bash_profile
    pyevn -v
    str="pyenv 安装完成"
    echo -e "\033[1m \033[32m${str}\033[0m"
  else
    str="pyenv 已经存在"
    echo -e "\033[1m \033[31m${str}\033[0m"
    which pyenv | xargs echo
  fi
  str="pyenv 正在更新"
  echo -e "\033[1m \033[32m${str}\033[0m"
  pyenv update
}

#安装Python
install_python(){
  str="开始安装 Python3.7..."
  echo -e "\033[1m \033[31m${str}\033[0m"
  if ! which python > /dev/null
  then
    str="正在安装 Python 依赖包"
    echo -e "\033[1m \033[31m${str}\033[0m"
    yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel \
    sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
    str="正在下载 Python"
    echo -e "\033[1m \033[31m${str}\033[0m"
    wget -P /tmp 'https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz'
    tar -xzf /tmp/Python-3.7.10.tgz-C /tmp
    cd /tmp/Python-3.7.10
    str="正在编译 Python"
    echo -e "\033[1m \033[31m${str}\033[0m"
    ./configure --prefix=/usr/local/python3
    str="正在安装 Python"
    echo -e "\033[1m \033[31m${str}\033[0m"
    make
    make install
    cd -
    rm -rf /tmp/Python-3.7.10*
    sed -i '$aexport PATH=$PATH:/usr/local/python3/bin' /etc/profile
    source /etc/profile
    str="Python 正在启动"
    echo -e "\033[1m \033[32m${str}\033[0m"
    python -V
    str="Python 安装完成"
    echo -e "\033[1m \033[32m${str}\033[0m"
  else
    str="Python 已经存在"
    echo -e "\033[1m \033[31m${str}\033[0m"
    python -V | xargs echo
  fi
}

remove_python2(){
  rpm -qa|grep python|xargs rpm -ev --allmatches --nodeps #强制删除已安装程序及其关联
  whereis python |xargs rm -frv ##删除所有残余文件 ##xargs，允许你对输出执行其他某些命令
  whereis python ##验证删除，返回无结果

}

install_all(){
echo "安装所有软件"
}

cat << EOF
软件安装操作
请输入要执行的操作的编号：[0-9]
============================
【0】安装所有组件
【1】安装 Nginx
【2】安装 Redis
【3】安装 pyenv
【4】安装 Python
【5】安装
【6】安装
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
  0);;
  1)install_nginx;;
  2)install_redis;;
  3)install_pyenv;;
  4)install_python;;
  5);;
  6);;
  7);;
  8);;
  9);;
  *)exit;;
esac