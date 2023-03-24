## Deployment  

Deployment 為 pod & replicaset 提供了一個宣告式的設定 & 更新方式  
透過定義 desired status，Deployment controller 會在所謂的 controlled rate 下達到使用者所期望的狀態  
這些機制是由 k8s 自動化完成，因此官方建議應該透過 Deployment 來佈署 pod & replicaset。  
  
下面是 deployment 的架構圖。  
![img](https://godleon.github.io/blog/images/kubernetes/k8s-deployment.png)   

### 建立 Deployment  

透過 "--record" 參數來保留後續的 revision history
```
kubectl apply -f nginx-deployment.yaml --record
```

接著透過 kubectl 來查詢剛剛佈署的 deployment 相關資訊：  
```
kubectl get deployment
```

- NAME： 列出了在目前 namespace 中的 deployment 清單  
- DESIRED： 使用者所宣告的 desired status  
- CURRENT： 表示目前有多少個 pod 副本在運行  
- UP-TO-DATE： 表示目前有多個個 pod 副本已經達到 desired status  
- AVAILABLE： 表示目前有多個 pod 副本已經可以開始提供服務  
- AGE： 顯示目前 pod 運行的時間  


如果要即時監控 deployment 佈署的狀況，可以使用以下指令：  
```
kubectl rollout status deployment/nginx-deployment
```

```
deployment "nginx-deployment" successfully rolled out
```

接著繼續往下看關於 ReplicaSet 的細節：  
```
kubectl get rs  
```

透過 Deployment 建立的 ReplicaSet，名稱都會是 **[DEPLOYMENT-NAME]-[POD-TEMPLATE-HASH-VALUE]**  
因此透過檢視 ReplicaSet name，其實很容易就可以知道這是由那一個 Deployment 所建立出來的。  

接著再往下看 Pod 的細節：  
deployment controller 同時也幫 pod 增加了一個 "pod-template-hash" label，hash value 也是相同的
```
kubectl get pod --show-labels
```


##### Pod-Template-Hash Label  

關於 pod-template-hash label，有幾點：

- 是由 deployment controller 加到每個 replicaset 的，主要是透過將 template 拿來計算 hash value 的方式來確保每個 replicaset 中的 template 定義不會有重複，
- pod-template-hash label 同時會被 deployment controller 加到 replicaset & pod 中，利用此 hash value 就可以確認那些 deploymen/replicaset/pod 是屬於同一組
- replicaset 名稱的 hash value 跟 pod-template-hash 不一樣，但應該是不同的 hash 方法所導致(因為透過相同的 YAML 檔案重新建立 deployment 也還是會得到相同的結果)


### 更新 Deployment  

剛使用者需要更新 deployment 內容時，就會考慮到這個問題，但更新的發生可能來自以下兩種變更：  

1. 修改 replica 的數量 (.spec.replicas)

2. 修改 template 的內容 (.spec.template)  

```
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1 --record
```

檢視 rollout status  
```
kubectl rollout status deployment/nginx-deployment
```

> 也可以透過 kubectl edit deployment/nginx-deployment 指令直接對 YAML 檔案進行修改。

透過修改 replica 數量不會讓 pod-template-hash 有變動  
但是修改 template 的內容就會造成 pod-template-hash 的變動了  
由於上方已經變更了 container image version  
因此來檢查一下目前 replicaset & pod 的狀態資訊：  

檢視 replicaset 的狀態  
可以發現 pod-template-hash 已經變換
```
kubectl get rs
```

```
kubectl describe rs/nginx-deployment-xxxxx
```

```
kubectl get pod --show-labels
```


以上狀況是在原本的 deployment 已經完成佈署的狀態下，變更 template 後會發生的行為，那如下發生以下狀況：  

> 佈署 5 個副本 + nginx:1.7.9 的 deployment，但當只有 3 個 pod 佈署完成時，馬上將 template 中的 container image version 修改為 nginx:1.9.1  

以上面的例子來說，k8s 就不會遵守原本的更新規則，而是會直接砍掉原本的 3 個 pod，然後開始建立新版本的 5 個 pod。  

### Deployment 版本回溯  

在預設情況下，系統中會包含 Deployment rollout 的歷史資訊(也就是 .spec.template 有變動時)  
因此使用者可以在 在 revision history limit 的範圍內，回復到任何一個時間點的狀態。  
> 由於只有當 .spec.template 變更時才會有 revision 記錄，因此改變 replica 數量就不會產生新的 revision 記錄  
 
將 container image 從 nginx:1.9.1 更新為 nginx:1.91  
```
kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

pod 則是明確的顯示遇到 image pull 的問題，時間一久就會開始進入 back off 的狀態  
```
kubectl get pod  
``` 

透過 rollout history 指令可以看出曾經下過什麼指令  
```
kubectl rollout history deployment/nginx-deployment
``` 

檢視 rollout hsitory 的細節  
```
kubectl rollout history deployment/nginx-deployment --revision=2
```

指令效果相同於 "kubectl rollout undo deployment/nginx-deployment --to-revision=2"  
```
kubectl rollout undo deployment/nginx-deployment  
```

### Scale out/in Deployment  

設定目前的 pod repplica 為 10  
```
kubectl scale deployment/nginx-deployment --replicas=10
``` 

設定目前的 pod repplica 為 3 
```
kubectl scale deployment/nginx-deployment --replicas=3
``` 
