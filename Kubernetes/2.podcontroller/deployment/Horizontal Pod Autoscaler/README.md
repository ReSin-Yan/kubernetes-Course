# Horizontal Pod Autoscaler  
透過實作metrics-server來達到Pod水平擴展  
本文會分為兩段，分別實作metrics-server  
並且透過metrics-server來達到Pod的水平擴展  

## metrics-server  
metrics-server為

### 安裝步驟  

將metrics-server匯入至Kubernetess內  
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

修改deployment的設定  
記得要加入 -n kube-system，metrics-server服務會自動帶入kube-system
```
kubectl edit deploy metrics-server -n kube-system
```

將以下內容加入到檔案內  
加入路徑為spec.template.spec.containers.args  
```
- --kubelet-insecure-tls
```

可以參考以下圖片  

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Horizontal%20Pod%20Autoscaler/metrics-server%20setting.png)   

安裝好之後會將原有服務砍掉重新建立一個  

之後來確認服務是否有安裝完成
```
kubectl top node
```
如果有成功看到Node的CPU&RAM使用率，就代表安裝完成  

## Horizontal Pod Autoscaler    
  
參考網址為:[Horizontal Pod Autoscaler演練](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/ "link")  

利用php-apha來進行測試  
安裝完服務之後，利用大量的下載來達到讓CPU使用率衝高的測試  

### 安裝步驟  

部屬PHP-apache服務  
```
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
```

設定autoscale規則  
參數設定:
 | 參數 | 參數意義 | 
|-------|-------|
| --cpu-percent | CPU使用率瓶頸 |
| --min |  pod的減少最小值 |
| --max  | pod的增加最大值 |  

將剛剛部屬的應用設定autoscale服務  
```
kubectl autoscale deployment php-apache --cpu-percent=40 --min=1 --max=10
``` 

可以透過以下指令來觀察是否設定完成  
注意其中的unkonw會花一點時間進行設定  
設定完會變成0%代表設定完成    
```
kubectl get hpa
``` 
### 增加服務運載  

這邊要注意開啟一個新的終端機(putty)  
使用新的終端機來進行壓力測試  

新的終端機指令(可以同一個環境)  
會看到一堆OK，代表已經向php進行下載請求完成  
藉此來拉高CPU使用率  
``` 
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
``` 
可以在原本的終端機執行以下指令來進行監控  
也可以透過其他指令來檢查是否有增加pod

```
watch -n 0.5 kubectl get hpa 
``` 
or  
``` 
kubectl get hpa 
``` 

如果有看到pod數量增加，代表完成測試  
回到新的終端機，把服務停掉(Ctrl+C)  
過一段時間可以看到pod的數量減少  
