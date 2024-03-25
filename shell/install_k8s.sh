#!/usr/bin/bash

pull_images(){
  str="正在转换 k8s 所需镜像"
  echo -e "\033[1m \033[32m${str}\033[0m"
  url=registry.cn-hangzhou.aliyuncs.com/google_containers
  version=v1.21.0
  images=(`kubeadm config images list --kubernetes-version=$version|awk -F '/' '{print $2}'`)
  for imagename in ${images[@]} ; do
      if [ $imagename != 'coredns' ]
      then
      docker pull $url/$imagename

      docker tag $url/$imagename k8s.gcr.io/$imagename
      docker rmi -f $url/$imagename
      else
        docker pull coredns/coredns:1.8.0
        docker tag coredns/coredns:1.8.0 k8s.gcr.io/coredns/coredns:v1.8.0
        docker rmi coredns/coredns:1.8.0
      fi
  done
  #拉取metrics
  docker pull bitnami/metrics-server:0.4.4
  docker tag bitnami/metrics-server:0.4.4 k8s.gcr.io/metrics-server/metrics-server:v0.4.4
  str="镜像拉取完成"
  echo -e "\033[1m \033[32m${str}\033[0m"

}

#安装K8S
install_k8s(){
#关闭Swap
swapoff -a && sysctl -w vm.swappiness=0
#sed -i 's/^ */dev/mapper/centos-swap swap   swap    defaults     0 0/BOOTPROTO="static"/g' /etc/sysconfig/network-scripts/ifcfg-enp0s3

#配置内核参数，将桥接的IPv4流量传递到iptables的链
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

str="添加阿里kubernetes源"
echo -e "\033[1m \033[32m${str}\033[0m"
cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

str="正在安装 kubernetes"
echo -e "\033[1m \033[32m${str}\033[0m"
yum install -y kubectl kubelet kubeadm


str="正在启动 kubelet"
echo -e "\033[1m \033[32m${str}\033[0m"
systemctl start kubelet
systemctl enable kubelet

str="K8S 安装完成"
echo -e "\033[1m \033[32m${str}\033[0m"
}

init_k8s_master(){
  str="正在初始化 k8s 集群"
  echo -e "\033[1m \033[32m${str}\033[0m"
  cat > ./kubeadm-config.yaml  <<EOF
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: ClusterConfiguration
  kubernetesVersion: v1.21.0
  apiServer:
    certSANs:    #填写所有kube-apiserver节点的hostname、IP、VIP
    - master
    - 192.168.5.13
  controlPlaneEndpoint: "192.168.5.13:6443"
  networking:
    podSubnet: "10.244.0.0/16"
EOF

  kubeadm init --config=kubeadm-config.yaml
  #删除master节点默认污点
  kubectl describe node master|grep -i taints
  kubectl taint nodes master node-role.kubernetes.io/master-

  str="正在加载环境变量"
  echo -e "\033[1m \033[32m${str}\033[0m"
  #加载环境变量
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  export KUBECONFIG=/etc/kubernetes/admin.conf
  echo "source <(kubectl completion bash)" >> ~/.bash_profile
  source ~/.bash_profile

  str="正在初始化 k8s 网络"
  echo -e "\033[1m \033[32m${str}\033[0m"
  wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  kubectl apply -f kube-flannel.yml

  str="正在查看 k8s 运行状态"
  echo -e "\033[1m \033[32m${str}\033[0m"
  #查看节点状态
  kubectl get nodes
  #集群基本组件状态
  kubectl get cs
  kubectl get po -o wide --all-namespaces
}

#安装K8S dashboard
install_k8s_dashboard(){
  str="正在部署 k8s dashboard"
  echo -e "\033[1m \033[32m${str}\033[0m"
  wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

  kubectl apply -f recommended.yaml
  #删除
  kubectl delete service kubernetes-dashboard --namespace=kubernetes-dashboard

  cat > ./dashboard-svc.yaml <<EOF
  kind: Service
  apiVersion: v1
  metadata:
    labels:
      k8s-app: kubernetes-dashboard
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard
  spec:
    type: NodePort
    ports:
      - port: 443
        targetPort: 8443
        nodePort: 30443
    selector:
      k8s-app: kubernetes-dashboard
EOF

  kubectl apply -f dashboard-svc.yaml

  cat > dashboard-admin.yaml << EOF
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: dashboard-admin
    namespace: kubernetes-dashboard
  ---
  kind: ClusterRoleBinding
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: dashboard-admin
  subjects:
    - kind: ServiceAccount
      name: dashboard-admin
      namespace: kubernetes-dashboard
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
EOF

  kubectl apply -f dashboard-admin.yaml
  #允许master部署应用
  kubectl taint nodes --all node-role.kubernetes.io/master-
  #状态查看
  kubectl get deployment -n kubernetes-dashboard
  #查看pod状态
  kubectl get pods --all-namespaces -o wide
  # 查看现有的服务
  kubectl get svc --all-namespaces
  #获取 token
  kubectl get secret -n kubernetes-dashboard | grep admin|awk '{print $1}'
  #获取 token
  kubectl describe secrets -n kubernetes-dashboard  dashboard-admin
  #kubectl describe secret $(kubectl get secret -n kubernetes-dashboard |grep admin|awk '{print $1}') -n kubernetes-dashboard|grep '^token'|awk '{print $2}'
}

install_kuboard(){
#  允许master部署
  kubectl taint nodes k8s-master node-role.kubernetes.io/master-

sudo docker run -d \
  --restart=unless-stopped \
  --name=kuboard_v3 \
  -p 10080:80/tcp \
  -p 10081:10081/udp \
  -p 10081:10081/tcp \
  -e KUBOARD_ENDPOINT="http://192.168.5.13:10080" \
  -e KUBOARD_AGENT_SERVER_UDP_PORT="10081" \
  -e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
  -v /root/kuboard-data:/data/kuboard \
  eipwork/kuboard:v3

  wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  kubectl apply -f components.yaml
  #添加参数–kubelet-insecure-tls 参数

#用户名： admin
#密 码： Kuboard123
}

install_all(){
echo "安装所有软件"
}

cat << EOF
软件安装操作
请输入要执行的操作的编号：[0-9]
============================
【0】安装所有组件
【3】安装 K8S
【4】拉取 K8S 镜像
【5】初始化 master
【6】安装 K8S kuboard
【7】安装 K8S Dashboard
【8】安装
【9】安装
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
  0)install_all;;
  3)install_k8s;;
  4)pull_images;;
  5)init_k8s_master;;
  6)install_kuboard;;
  7)install_k8s_dashboard;;
  8);;
  9);;
  *)exit;;
esac