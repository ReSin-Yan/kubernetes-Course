# Contour安裝方式

使用helm安裝Contour  
Contour是由VMware提出並維護的開源套件
如果需要使用本身是不用收費  
但是如果需要到enterprise等級的support  
或是進階的錯誤排除，就會需要額外購買support  

 

 | 套件名稱 | 角色  |
|-------|-------|
| MetalLB | L4 loadbalancer |  
| Contour | L7 Ingress |  


## 事先準備  

 | 事先需求 |
|-------|
| helm |
| kubernetes|  


## 安裝步驟  
  
### 沒有LoadBalance的安裝方式  
由於沒有LoadBalance  
所以需要自己額外安裝此項功能  
這邊採用同為opensource的metalLB  

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.0/manifests/metallb.yaml
```

透過以上兩行進行metalLB的安裝(版本為0.10)  

接下來需要設定給定的IP Range(今天服務用LoadBalance的方式建立出來之後，會去拿一個IP)  
給定的這段IP會分配給建立出來的服務  

```
vim configIPrange.yaml
```

貼入以下內容
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses: [startIP] - [endIP]
```

```
kubectl apply -f configIPrange.yaml
```

本資料夾內有放置相關的執行腳本，可以直接下載來使用  

```
sh installMetallb.sh [startIP] [endIP]
```
會執行兩個測試檔案  
可以透過以下指令查看是否部屬成功  


### 安裝Contout(有LoadBalance的安裝方式)  
如果本身的Kubernetes具有loadbalance的功能(如Tanzu)  
loadbalance的功能是由平台開發商提供  
可以跳過安裝loadbalance的部分  

透過helm安裝  
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/contour
kubectl get svc my-release-contour-envoy --namespace default
kubectl describe svc my-release-contour-envoy --namespace default | grep Ingress | awk '{print $3}'
```
透過以上三行安裝完成  
會有一個service去拿一個Loadbalance的IP(所以才需要LB工具)  

接著可以執行測試檔案(測試檔案一樣放在本資料夾內)  
測試之前需要修改路徑設定(如果client端是windows就修改hosts)

```
kubectl apply -f ingress.yaml
kubectl apply -f ingress2.yaml
```

