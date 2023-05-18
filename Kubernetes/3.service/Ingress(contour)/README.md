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
  

### 安裝Contour  
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

