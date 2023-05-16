
# 基礎常用套件簡述    


## Workloads Controllers  

Kubernetes的Workloads Controllers ，這邊分別介紹三個最常使用的來說（涵蓋大部分應用場景）。    

Deployments  
StatefulSets  
DaemonSets  

### Deployments  
 
通常部署的微服務，如API Services都會使用此類別   
Deployment掌管ReplicaSets（ReplicaSets是Replica Controller進化而來的），ReplicaSets掌管Pods。  
而因為有關聯，所以在Deployment下的Label Name，會同樣印在pod上。  

那使用Deployments更重要的是，可以方便Rollback到之前版本，而使用StatefulSets、DaemonSets是不能Rollback。  
如果是RollingUpdate，他會先保證新啟用的服務的狀態為Running時，才會把舊的砍掉。  

Scale up則會看現在<replica-set-id>是在哪個，則對哪個版本作擴展。  
那使用PVC（PersistentVolumeClaim），每個Pods都會共用同一個掛載硬碟。  
因為此機制，才會說Deployments 適合使用 stateless application。  
那也因為只有Deployment可以很方便的Rollback，且版本都又記錄下來，故而大部分服務都可以適用。  

### StatefulSets    

StatefulSet 在 v1.9 版後正式支援。而每一個 pod 都有固定的識別資訊，不會因為 pod reschedule 後有變動。  

什麼場景要應用此方案呢？  
需要穩定且唯一的網路識別  
需要穩定的 persistent storage （使用PVC時，會有各自獨立的Storage）  
佈署與擴展時，每個 pod 的產生都是有其順序且逐一慢慢完成的，且是先進後出，意思是部署4個Replicas時，會如1、2、3、4逐一部署，而要刪除時則是從4、3、2、1來逐一刪除  



那如何識別  
每一個 StatefulSet Pod 都有一個獨一無二的識別資訊，但這件事情在 k8s 中是如何被達成的? 其實是分別由以下三種資訊所組成：  

Ordinal Index  
若一個 statefulset 包含了 n 個 replica，那每一個 pod 都會被分配到一個獨立的索引，從 0 ~ n-1，即使 pod reschedule 也不會變。  
Stable Network ID  
那因為有獨立的索引，$(service name).$(namespace).svc.cluster.local也是獨立的。  
Stable Storage  
可以透過volumeClaimTemplates + StorageClass 來設定獨立的Storage（勢必要為獨立的）  

那要怎麼設定  
設定 .spec.updateStrategy.rollingUpdate.partition 為一個整數(int)，當index 大於等於此int的 pod 就會被更新，而小於此int的 pod 就不會被更新。  
舉例：有四個（foo-0、foo-1、foo-2、foo-3），設定整數值為2時，foo-2、foo-3這兩個會被更新。  
那可以Rollback嗎？不行。因為沒有創建ReplicaSet或是任何有相關的排序，所以只能delete or scale up/down。  

### DaemonSet  

簡單來說就是在每一個Node都會跑一個Pod，所以不管是新增/刪除Node，都會新增/刪除Pod。  

主要應用場景  
Monitoring Exporters  
Logs Collection Daemon  
在監控或是取得Log上，會使用DaemonSet，那當然可以使用taints來去排除，再用tolerations解除！端看怎麼使用囉（詳細使用方式可以看筆者的前幾篇）。  

那在PVC上，DaemonSet與Deployment是一樣的，共同使用同一個Storage。  

在更新方面，除了部分原因少於三個Node外，DaemonSet更新方式為一個Pod先關閉，而後才起新的Pod，以此類推。那假如有一個出錯時（通常要出錯就是第一個出錯），會停止而不影響後面原本穩定的版本，故而這時只有一個Pod被關閉。  

DaemonSet也無法Rollback。  
