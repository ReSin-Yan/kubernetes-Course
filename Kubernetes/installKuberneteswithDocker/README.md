# Kubernetes  

## ubuntu with Docker 安裝  

#### 環境硬體配置(建議需求)  
使用的環境為  
OS      :ubutu desktop 22.04  
CPU     :4 CPU  
Memory  :8 GB  
Disk    :200GB  

#### 環境安裝(Master)  

環境更新及安裝基本套件  
```
sudo apt update
sudo apt -y full-upgrade
```

安裝Kubernetes執行套件(kubelet,kubeadm,kubectl)  
```
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install sshpass vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

取消swap，並將其寫入開機程序
```
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
```

安裝Docker container
```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
```

安裝cri-docker      
```
sudo apt update
sudo apt install git wget curl
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
echo $VER
wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
tar xvf cri-dockerd-${VER}.amd64.tgz
sudo mv cri-dockerd/cri-dockerd /usr/local/bin/
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
sudo sed -i '10d' cri-docker.service
sudo sed -i '9a ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni' cri-docker.service
sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket

```

確認及設定kubernetes control plan
```
sudo kubeadm config images pull --cri-socket /run/cri-dockerd.sock
sudo kubeadm init  --pod-network-cidr=10.244.0.0/16   --cri-socket /run/cri-dockerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 環境安裝(Worker)  


#### 安裝CNI(讓節點處於Ready)  

Flannel    
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Calico  
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```
