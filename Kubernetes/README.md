# Kubernetes   


## Kubernetes 四元件  

### Pod  

Kubernetes 運作的最小單位，一個 Pod 對應到一個應用服務（Application） ，舉例來說一個 Pod 可能會對應到一個 API Server。  

每個 Pod 都有一個身分證，也就是屬於這個 Pod 的 yaml 檔  
一個 Pod 裡面可以有一個或是多個 Container，但一般情況一個 Pod 最好只有一個 Container  
同一個 Pod 中的 Containers 共享相同資源及網路，彼此透過 local port number 溝通  


### Worker Node  

Kubernetes 運作的最小硬體單位，一個 Worker Node（簡稱 Node）對應到一台機器，可以是實體機如你的筆電、或是虛擬機如 AWS 上的一台 EC2 或 GCP 上的一台 Computer Engine。  

每個 Node 中都有三個組件：kubelet、kube-proxy、Container Runtime。  

#### kubelet  

該 Node 的管理員，負責管理該 Node 上的所有 Pods 的狀態並負責與 Master 溝通  
#### kube-proxy  

該 Node 的傳訊員，負責更新 Node 的 iptables，讓 Kubernetes 中不在該 Node 的其他物件可以得知該 Node 上所有 Pods 的最新狀態  
#### Container Runtime  

該 Node 真正負責容器執行的程式，以 Docker 容器為例其對應的 Container Runtime 就是 Docker Engine  

### Master Node    
Kubernetes 運作的指揮中心，可以簡化看成一個特化的 Node 負責管理所有其他 Node。一個 Master Node（簡稱 Master）中有四個組件：kube-apiserver、etcd、kube-scheduler、kube-controller-manager。  

#### kube-apiserver  

管理整個 Kubernetes 所需 API 的接口（Endpoint），例如從 Command Line 下 kubectl 指令就會把指令送到這裏  
負責 Node 之間的溝通橋樑，每個 Node 彼此不能直接溝通，必須要透過 apiserver 轉介  
負責 Kubernetes 中的請求的身份認證與授權  
#### etcd  

用來存放 Kubernetes Cluster 的資料作為備份，當 Master 因為某些原因而故障時，我們可以透過 etcd 幫我們還原 Kubernetes 的狀態  
#### kube-controller-manager  

負責管理並運行 Kubernetes controller 的組件，簡單來說 controller 就是 Kubernetes 裡一個個負責監視 Cluster 狀態的 Process，例如：Node Controller、Replication Controller  
這些 Process 會在 Cluster 與預期狀態（desire state）不符時嘗試更新現有狀態（current state）。例如：現在要多開一台機器以應付突然增加的流量，那我的預期狀態就會更新成 N+1，現有狀態為 N，這時相對應的 controller 就會想辦法多開一台機器  
controller-manager 的監視與嘗試更新也都需要透過訪問 kube-apiserver 達成  
####  kube-scheduler  

整個 Kubernetes 的 Pods 調度員，scheduler 會監視新建立但還沒有被指定要跑在哪個 Node 上的 Pod，並根據每個 Node 上面資源規定、硬體限制等條件去協調出一個最適合放置的 Node 讓該 Pod 跑  

### Cluster  

Kubernetes 中多個 Node 與 Master 的集合。基本上可以想成在同一個環境裡所有 Node 集合在一起的單位。  


### 常用指令列表  

 | 指令 | 說明  | 範例 |
|-------|-------|-------|
| run | 	新建或啟動 |  docker run -d centos |
| start [Contain ID]	 | 啟動 |  docker start xx |
| stop [Contain ID]		 | 停止 |  docker stop xx |
| rm [Contain ID]	 | 刪除 |  docker rm xx |
| rmi [Images ID]	 | 刪除映像檔 |  docker rmi xx |
| ps -a	 | 啟動 |  docker start a469b9226fc8 |
| logs [Contain ID]	 | 查看容器內的資訊 |  		docker logs -f a4 |
| attach [Contain ID]		 | 進入容器 |  	docker attach  a4  |
| inspect	 | 查看 |  docker inspect a4 |
| images	 | 啟動 |  docker start a469b9226fc8 |
| start [Contain ID]	 | 啟動 |  docker start a469b9226fc8 |
| start [Contain ID]	 | 啟動 |  docker start a469b9226fc8 |
