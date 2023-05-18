## LoadBalance  

Kubernetes 不提供LoadBalancer類型的服務用於Bare metal cluster。  
Kubernetes 附帶的LoadBalancer實現都是調用各種 IaaS 平台（GCP、AWS、Azure……）。  
如果在常見的 IaaS 平台（GCP、AWS、Azure……）上運行，LoadBalancers在創建時將無限期地保持在“掛起”狀態。  

Bare metal cluster只剩下兩個方式來將使用流量導入集群  
“NodePort”和“externalIPs”服務。  
這兩種選擇對於Production 都有明顯的缺點，這使得Bare metal cluster成為 Kubernetes 生態系統中的二等公民。  

> Refernece metallb offical  

![img](https://miro.medium.com/v2/resize:fit:913/0*YxZrrdmKZ4Hw2s1c.png)   


### 安裝 metalllb  

[官方網站](https://metallb.universe.tf/ "link")  

安裝需求  
| 需求 | 版本or建議規格 | 
|-------|-------|
| Kubernetes Cluster | 1.13.0 or later |
| cluster network config |  [官方網站](https://metallb.universe.tf/installation/network-addons/ "link")   |
| IP Range  | 空的網段，至少1個 |


從官方網站部屬yaml(需要對外)  
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.9/config/manifests/metallb-native.yaml
```


設定ippool以及L2連線  
```
cat > ippool.yaml <<-EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - x.x.x.x-x.x.x.x
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
EOF

kubectl apply -f ippool.yaml
```

