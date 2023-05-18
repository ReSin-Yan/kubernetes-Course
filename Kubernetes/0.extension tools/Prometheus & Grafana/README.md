# 使用helm安裝ingress版本的kube-prometheus-stack

使用helm安裝ingress版本的kube-prometheus-stack  
安裝參考:[Kube-prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack "link")  
使用Monitoring Stack方式  
一次安裝
 

 | 腳色 |
|-------|
| Promethues |
| Grafana    |  
| alertmanager    |


## 事先準備  

 | 事先需求 |
|-------|
| helm |
| StorageClass    |  
| ingress    |


## 安裝步驟  
  
加入repo&進行升級  
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts  
helm repo update
```

建立放置安裝內容的命名空間  
```
kubectl create ns monitor  
```

對需要監控的節點打上lable  
```
kubectl get node



NAME          STATUS   ROLES                  AGE   VERSION
mandy-k8s01   Ready    control-plane,master   22d   v1.21.2
mandy-k8s02   Ready    <none>                 22d   v1.21.2
mandy-k8s03   Ready    <none>                 22d   v1.21.2  

```

例如我的全部的節點都需要被監控
```
kubectl label node mandy-k8s01 category=monitoring
kubectl label node mandy-k8s02 category=monitoring
kubectl label node mandy-k8s03 category=monitoring
```

## 檢查 values.yaml  
修改此附檔的values.yaml  
需要修改幾個部分  
以下皆修改成符合自己環境設定及需求  
FQDN:設定成自已想要的名稱  
SC設定成當前環境的SC名稱  
Alertmananger的FQDN   
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/img/prom1.png)  

Alertmananger的SC名稱(根據自己的SC命名)  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/img/prom2.png)  

grafana的FQDN  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/img/prom3.png)  

prometheus的FQDN  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/img/prom4.png)  

prometheus的StorageClass  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/img/prom5.png)  

## 部屬服務  

透過helm部屬服務
```
helm install prometheus prometheus-community/kube-prometheus-stack -f values.yaml -n monitor
```
接下來就是透過網站登入  
Grafana帳號密碼預設為 : admin/P@ssw0rd  
可以再values.yaml裡面修改  
<https://prometheusFQDN.com/>  
<https://grafanaFQDN.com/>  
<https://AlertmanangerFQDN.com/>  
