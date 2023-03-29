## DaemonSet  

DaemonSet 確保全部（或是一些）Node 上運行一個 Pod 的副本。  
當有Node 加入集群時，也會為他們新增一個Pod  
當有Node 從集群移除時，這些Pod 也會被回收。刪除DaemonSet 將會刪除它創建的所有Pod。  
  
 
使用DaemonSet 的一些常見用法：

cluster儲存daemon，例如在每個Node 上運行glusterd、ceph。
在每個Node 上運行log收集daemon，例如fluentd、logstash。
在每個Node 上運行監控daemon，例如Prometheus Node Exporter、collectd、Datadog 代理、New Relic 代理，或Ganglia gmond。 
  
下面是 DaemonSet 的架構圖。  
![img](https://support.huaweicloud.com/intl/en-us/basics-cce/en-us_image_0258871213.png)   

### 建立 DaemonSet  

透過 "--record" 參數來保留後續的 revision history
```
kubectl apply -f nginx-daemonset.yaml --record
```

接著透過 kubectl 來查詢剛剛佈署的 daemonset 相關資訊：  
```
kubectl get daemonset
kubectl get ds
```

- NAME： 列出了在目前 namespace 中的 daemonset 清單  
- DESIRED： 使用者所宣告的 desired status  
- CURRENT： 表示目前有多少個 pod 副本在運行  
- UP-TO-DATE： 表示目前有多個個 pod 副本已經達到 desired status  
- AVAILABLE： 表示目前有多個 pod 副本已經可以開始提供服務  
- AGE： 顯示目前 pod 運行的時間  


如果要即時監控 daemonset 佈署的狀況，可以使用以下指令：  
```
kubectl rollout status daemonset/nginx-daemonset
```

```
daemonset "nginx-daemonset" successfully rolled out
```

接著繼續往下看關於 ReplicaSet 的細節：  
```
kubectl get ds  
```

透過 daemonset 建立的 ReplicaSet，名稱都會是 **[DAEMONSET-NAME]-[POD-TEMPLATE-HASH-VALUE]**  
因此透過檢視 ReplicaSet name，其實很容易就可以知道這是由那一個 daemonset 所建立出來的。  

接著再往下看 Pod 的細節：  
daemonset controller 同時也幫 pod 增加了一個 "controller-revision-hash" label，hash value 也是相同的
```
kubectl get pod --show-labels
```


### 更新 daemonset  

剛使用者需要更新 daemonset 內容時，就會考慮到這個問題，但更新的發生可能來自以下醫種變更：  

1. 修改 template 的內容 (.spec.template)  

```
kubectl set image daemonset/nginx-daemonset nginx=nginx:1.9.1 --record
```

檢視 rollout status  
```
kubectl rollout status daemonset/nginx-daemonset
```

> 也可以透過 kubectl edit daemonset/nginx-daemonset 指令直接對 YAML 檔案進行修改。

修改 template 的內容就會造成 controller-revision-hash 的變動了  
由於上方已經變更了 container image version  
因此來檢查一下目前 replicaset & pod 的狀態資訊：  

檢視 replicaset 的狀態  
可以發現 controller-revision-hash 已經變換
```
kubectl get rs
```

```
kubectl describe rs/nginx-daemonset-xxxxx
```

```
kubectl get pod --show-labels
```
  
### daemonset 版本回溯  

在預設情況下，系統中會包含 daemonset rollout 的歷史資訊(也就是 .spec.template 有變動時)  
因此使用者可以在 在 revision history limit 的範圍內，回復到任何一個時間點的狀態。  
> 由於只有當 .spec.template 變更時才會有 revision 記錄，因此改變 replica 數量就不會產生新的 revision 記錄  
 
將 container image 從 nginx:1.9.1 更新為 nginx:1.91  
```
kubectl set image daemonset/nginx-daemonset nginx=nginx:1.91
```

pod 則是明確的顯示遇到 image pull 的問題，時間一久就會開始進入 back off 的狀態  
```
kubectl get pod  
``` 

透過 rollout history 指令可以看出曾經下過什麼指令  
```
kubectl rollout history daemonset/nginx-daemonset
``` 

檢視 rollout hsitory 的細節  
```
kubectl rollout history daemonset/nginx-daemonset --revision=2
```

指令效果相同於 "kubectl rollout undo daemonset/nginx-daemonset --to-revision=2"  
```
kubectl rollout undo daemonset/nginx-daemonset  
```
