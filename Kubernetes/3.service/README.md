# 基礎常用套件簡述    

[參考資料 雲原生資料庫(簡中)](https://lib.jimmysong.io/kubernetes-handbook/service-discovery/service/)

## Services(Service discovery&Route)  

Kubernetes Pod 是有Lifecycle的，它們可以被創建，也可以被銷毀，然而一旦被銷毀Lifecycle就永遠結束。  
每個 Pod 都會有自己的 IP 地址，即使這些 IP 不是永遠相同。  
這會導致一個問題：在 Kubernetes 集群中，如果一組Pod(前端)其它 Pod(後端)提供服務，那麼該如何連接呢？  


### 關於Service  
 
Kubernetes Service 定義了這樣一種抽象：Pod 的邏輯分組，一種可以訪問它們的策略 —— 通常稱為微服務。  
這一組 Pod 能夠被 Service 訪問到。  

舉個例子，假設有一個用於圖片處理，並且運行了三個副本的 pod(後端)。  
這些副本是可互換的 —— frontend 不需要關心它們調用了哪個 backend 副本。然而組成這一組 backend 程序的 Pod 實際上可能會發生變化，frontend 客戶端不應該也沒必要知道，而且也不需要跟踪這組 backend 的狀態。 Service 定義的抽象能夠解耦這種關聯。

對 Kubernetes 集群中的應用，Kubernetes 提供了簡單的 Endpoints API，只要 Service 中的一組 Pod 發生變更，應用程序就會被更新。對非 Kubernetes 集群中的應用，Kubernetes 提供了基於 VIP 的橋接器(Network Bridge)方式訪問 Service，再由 Service 重定向到 backend Pod。

### 定義service    

一個 Service 在 Kubernetes 中是一個 REST 對象，和 Pod 類似。  
像所有的 REST 對像一樣， Service 定義可以基於 POST 方式，請求 apiserver 創建新的實例。  

例如，假定有一組 Pod，它們對外暴露了 9376 端口，同時還被打上 "app=MyApp" 標籤。  

```
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```
上述配置將創建一個名稱為 “my-service” 的 Service 對象，它會將請求到 9376 TCP 端口，且具有標籤 "app=MyApp" 的 Pod 上。  
這個 Service 將被指派一個 IP 地址（通常稱為 “Cluster IP”），它會被服務的代理使用。  
該 Service 的 selector 將會持續評估，處理結果將被 POST 到一個名稱為 “my-service” 的 Endpoints 。

```
kubectl get ep,svc,pod -o wide -A
```

需要注意的是， Service 能夠將一個接收端口映射到任意的 targetPort。  
默認情況下，targetPort 將被設置為與 port 字段相同的值。  
Kubernetes Service 支持 TCP 和 UDP 協議，默認為 TCP 協議。  


### Type  

 | 類型 | 說明 |
|-------|-------|
| ClusterIP | 通過集群的內部 IP 暴露服務，選擇該值，服務只能夠在集群內部可以訪問，這也是默認的 ServiceType |
| NodePort| 通過每個 Node 上的 IP 和Static Port（NodePort）暴露服務。 NodePort 服務會路由到 ClusterIP 服務，這個 ClusterIP 服務會自動創建。通過請求 <NodeIP>:<NodePort>，可以從集群的外部訪問一個 NodePort 服務。 |
| LoadBalancer	 | 使用Provider的負載均衡器，可以向外部暴露服務。外部的LoadBalancer可以路由到 NodePort 服務和 ClusterIP 服務(通常是ClusterIP)。 |
| ExternalName  | 通過返回 CNAME 和它的值，可以將服務映射到 externalName 字段的內容（例如， foo.bar.example.com）。沒有任何類型代理被創建，這只有 Kubernetes 1.7 或更高版本的 kube-dns 才支持。 |

