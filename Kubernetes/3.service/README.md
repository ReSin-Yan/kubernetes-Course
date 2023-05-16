
# 基礎常用套件簡述    


## Services(Service discovery&Route)  

Kubernetes Pod 是有Lifecycle的，它們可以被創建，也可以被銷毀，然而一旦被銷毀Lifecycle就永遠結束。  
每個 Pod 都會有自己的 IP 地址，即使這些 IP 不是永遠相同。  
這會導致一個問題：在 Kubernetes 集群中，如果一組 Pod為其它 Pod提供服務，那麼該如何連接呢？  


### 關於Service  
 
Kubernetes Service 定義了這樣一種抽象：Pod 的邏輯分組，一種可以訪問它們的策略 —— 通常稱為微服務。  
這一組 Pod 能夠被 Service 訪問到。  

舉個例子，假設有一個用於圖片處理的運行了三個副本的 pod。  
這些副本是可互換的 —— frontend 不需要關心它們調用了哪個 backend 副本。然而組成這一組 backend 程序的 Pod 實際上可能會發生變化，frontend 客戶端不應該也沒必要知道，而且也不需要跟踪這組 backend 的狀態。 Service 定義的抽象能夠解耦這種關聯。

對 Kubernetes 集群中的應用，Kubernetes 提供了簡單的 Endpoints API，只要 Service 中的一組 Pod 發生變更，應用程序就會被更新。對非 Kubernetes 集群中的應用，Kubernetes 提供了基於 VIP 的網橋的方式訪問 Service，再由 Service 重定向到 backend Pod。

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
