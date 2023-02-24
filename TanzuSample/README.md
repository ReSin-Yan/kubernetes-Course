## Kubernetes 操作  

登入到Taznu環境  
```
export KUBECTL_VSPHERE_PASSWORD=xxxx
kubectl vsphere login --insecure-skip-tls-verify --server 192.168.170.73 --vsphere-username tcbbankxx@vsphere.local
kubectl config use-context tcbbank
```
確認是否連線  
```
kubectl get node
```

### 建立TKC   

使用已下指令  
```
cd 
git clone https://github.com/ReSin-Yan/kubernetes-Course
cd kubernetes-Course/TanzuSample
```

使用命令提示字元編輯檔案  

```
vim creategc.yaml
```

編輯此檔案內容的[edit here]
```
apiVersion: run.tanzu.vmware.com/v1alpha1      #TKGS API endpoint
kind: TanzuKubernetesCluster                   #required parameter
metadata:
  name: tkgs-cluster-1                         #cluster name, user defined
  namespace: tgks-cluster-ns                   #vsphere namespace
spec:
  distribution:
    version: v1.20                             #Resolves to latest TKR 1.20
  topology:
    controlPlane:
      count: 1                                 #number of control plane nodes
      class: best-effort-medium                #vmclass for control plane nodes
      storageClass: vwt-storage-policy         #storageclass for control plane
    workers:
      count: 3                                 #number of worker nodes
      class: best-effort-medium                #vmclass for worker nodes
      storageClass: vwt-storage-policy         #storageclass for worker nodes
```

```
kubectl apply -f creategc.yaml
```

# Tanzu Guest Cluster使用外部式的Harbor  

TKGs的安裝方式分為vDS以及NSX-T版本  
NSX-T版本中，有包含了內嵌式的Harbor，但是在vDS版本中，就沒有包含內嵌式的Harbor  
所以本內容會著重在如何在沒有內嵌式Harbor的環境下，使用外部式的Harbor  

本文參考設定  
[Video範例](https://www.youtube.com/watch?v=sqC9bP8gwQ0&ab_channel=VMwareTanzu   "link")  
[參考文件](https://docs.vmware.com/en/VMware-vSphere/7.0/vmware-vsphere-with-tanzu/GUID-376FCCD1-7743-4202-ACCA-56F214B6892F.html "link")
  

## 設定步驟  

### 環境準備  

本內容使用的參數為在7.0.2版本新增的設定`TkgServiceConfiguration`方式  
vSphere版本必須>=7.0.2  
Harbor需透過https的方式安裝完成  

### 設定步驟  

#### 取得openssl 憑證  

在任何一台linux client或是tanzu的linx client端點機器輸入  
```
openssl s_client -connect <your harbor FQDN>.com:443
```
輸入之後，點`Ctrl + c`退出  

複製下Server certificate全部的資訊  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Harbor/Tanuz%20use%20externel%20harbor/harborServer%20certificate.png "img")  
需要確保連同`-----BEGIN CERTIFICATE-----`以及`-----END CERTIFICATE-----` 都要複製

#### 將文字轉換成Base64格式  

透過以下網站進行  
[Base64](https://base64.guru/ "link")  

左方工具列`Encoders` > `Text to Base64` 
將剛剛複製下來的資訊貼到`Text*`欄位中  
點選`Encode Text to Base64`  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Harbor/Tanuz%20use%20externel%20harbor/TextToBase64.png "img")  
將產出的內容複製下來  

#### Linux client Docker login

[參考方式](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/tree/main/Harbor#docker-login "link")  
由於在worker端是沒有docker login的憑證，只有SSL的  
所以需要在linux client透過docker login的方式進行登入環境  


#### 編輯TkgServiceConfiguration  

在vsphere7.0.2之後，針對外部的認證，新增的設定值  
先登入Tanzu的SC namespaces內  
指令對應的參數根據環境輸入  
登入使用者必須是administratror喔  
 | 參數 | 輸入值 | 
|-------|:-----:| 
| --server   |  10.74.0.1  |  
| --vsphere-username   |  administrator@vsphere.local  |
| namespaces | demo |


```
kubectl vsphere login --insecure-skip-tls-verify --server 10.74.0.1 --vsphere-username administrator@vsphere.local
```
輸入密碼  

切換到namespace  
```
kubectl config use-context demo
```

編輯此namespace的TkgServiceConfiguration  
```
kubectl edit tkgServiceConfiguration
```
開始編輯模式之後  
參考以下方式進行修改  
新增在設定的最下面spec  


 | 參數 | 輸入值 | 
|-------|:-----:| 
| name   |  yourFQDN.com  |  
| data   |  [前一步驟所複製base64轉碼](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Harbor/Tanuz%20use%20externel%20harbor/README.md#%E5%B0%87%E6%96%87%E5%AD%97%E8%BD%89%E6%8F%9B%E6%88%90base64%E6%A0%BC%E5%BC%8F "link")  |
 
```
apiVersion: run.tanzu.vmware.com/v1alpha1
kind: TkgServiceConfiguration
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"run.tanzu.vmware.com/v1alpha1","kind":"TkgServiceConfiguration","metadata":{"annotations":{},"creationTimestamp":"2021-06-14T14:59:40Z","generation":1,"name":"tkg-service-configuration","resourceVersion":"3016","selfLink":"/apis/run.tanzu.vmware.com/v1alpha1/tkgserviceconfigurations/tkg-service-configuration","uid":"60494827-07d3-4253-b755-5cf2c9130c1c"},"spec":{"defaultCNI":"antrea"}}
  creationTimestamp: "2021-06-14T14:59:40Z"
  generation: 5
  name: tkg-service-configuration
  resourceVersion: "21388420"
  selfLink: /apis/run.tanzu.vmware.com/v1alpha1/tkgserviceconfigurations/tkg-service-configuration
  uid: 60494827-07d3-4253-b755-5cf2c9130c1c
spec:
  defaultCNI: antrea
  trust:
    additionalTrustedCAs:
    - data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlGK0RDQ0ErQ2dBd0lCQWdJVVltNTRrZERlcjI0RlFUMnUydWhyN2l6dGJPa3dEUVlKS29aSWh2Y05BUUVODQpCUUF3Y0RFTE1Ba0dBMVVFQmhNQ1EwNHhFREFPQmdOVkJBZ01CMEpsYVdwcGJtY3hFREFPQmdOVkJBY01CMEpsDQphV3BwYm1jeEVEQU9CZ05WQkFvTUIyVjRZVzF3YkdVeEVUQVBCZ05WQkFzTUNGQmxjbk52Ym1Gc01SZ3dGZ1lEDQpWUVFEREE5eVpYTnBibWhoY21KdmNpNWpiMjB3SGhjTk1qRXdOekE1TURFd05EUTRXaGNOTXpFd056QTNNREV3DQpORFE0V2pCd01Rc3dDUVlEVlFRR0V3SkRUakVRTUE0R0ExVUVDQXdIUW1WcGFtbHVaekVRTUE0R0ExVUVCd3dIDQpRbVZwYW1sdVp6RVFNQTRHQTFVRUNnd0haWGhoYlhCc1pURVJNQThHQTFVRUN3d0lVR1Z5YzI5dVlXd3hHREFXDQpCZ05WQkFNTUQzSmxjMmx1YUdGeVltOXlMbU52YlRDQ0FpSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnSVBBRENDDQpBZ29DZ2dJQkFOclZjdUhhcnRabUE2RVFNQjM5bWdCbDhCYnZPRG54Y3laMDJFSGpZQVViYUtvSTZpQTBtaGw0DQp5Y2tXcGlIMTVQdHdGRWdDc2lMVXhtRXJuL1RrVnJrSTVoTDhjL0pqVXZLWE4rbDZvVVMxNTh0WHhFUkhuMGVvDQprby9KMUxaN0FBQ21qNWtYdTFkZWkyaEJMclhlN1pZYmVxNUpSQ095VXUyUWZNZkVtT245eHZaRmxBbzAxY1JiDQp3eHdpcUdDRW0rYUlNZW1XbFVaekQ3Y1RYOTlVd0tKS3lPYVlhMTI2d1JTSGhGQ1NHaFI4Z3FKNG4zSGJDbi93DQpyMzVLNXVGNXNHNG9UWm5qKy9PeFlKOTZ0bWFFUHFGR0pCQVcwUVVycDh3UnF3b2NyYWpwNTlMK0EwZlpSNVFZDQpWSG8rVWllVFZ6ZEV5cnRmS3Q5RDVOeFFvODc4MWJIckhmL2VIZ2Y1Yis5Zmk4U05lUi9vQ1JkT3RmK2dxWE5ZDQpUM3hiRW9id0VsMWhLd1RGRk9RRVh1VHVxbEduMWJmZTB1STJFZkVFdE0xRU1iYzB6VEZxTkFCdk5KNWZObFU1DQpOUHJWL2plL1ZWNnEzTGl2aW9qeUhCeHB4dEZDUHdmOGNFd1JxbTk2VHkwa3FBZG5sQW5tWlZYWXluS0F2U2MxDQpJWk9aR3EvSlB0aEZNQngraWR2TURMSFNUYmcrZVlYeVNDbEprRE1EWmVPKzBlYkZJWE1YMGRyN2JnUGpnU3ZwDQpnN0lKMGFUV3ZCV0hhSGI0aGRwMy9jaTRmVVp4ODc5NmdoRU5ESEhHVnpiNlhBZ2FVR04yOUw2bmpKeHNmK0VPDQoxR2Q1UmljZXUrTzF4eXBlcVF2T3N0QWdFSFNnYXhBSUpDUkNDaVJLZWF4ZVgvZmJSZnp2QWdNQkFBR2pnWWt3DQpnWVl3SHdZRFZSMGpCQmd3Rm9BVXZPS2VLMTcwc1lVSjFkSnZOcXBzYzIyQXEwMHdDUVlEVlIwVEJBSXdBREFMDQpCZ05WSFE4RUJBTUNCUEF3RXdZRFZSMGxCQXd3Q2dZSUt3WUJCUVVIQXdFd05nWURWUjBSQkM4d0xZSVBjbVZ6DQphVzVvWVhKaWIzSXVZMjl0Z2d0eVpYTnBibWhoY21KdmNvSU5kV0oxYm5SMUxXaGhjbUp2Y2pBTkJna3Foa2lHDQo5dzBCQVEwRkFBT0NBZ0VBVjdSbitsL1FkeGh0WFUwMlgrZzlpeWhiUUY4UlhUNmNrUFI2U0JlaWdCSjg2d1JxDQpOVnAwOThOMVl6cnhsb0ZDclE3a25uRnpRRUlRMk9XTVUzSUt5RXhHODVVb0p1MjVPRE54ZGhEY1JSamo0SkpFDQptZHhpTDhyV291Lys3Z2NueWIxWU5Nc2JUV2NsRHR4YU4xRHVXcU8xZFVQWUtoRHp5U0FFeTlFbHhQZldhd200DQpMNE9BMUVDYzd4bXRaaTZqREgzb0FrZTN2aEZ3a0tnRFV4SXhSNUk2TU1uVEtBQnpCMVJwem84YThXbVVqa2g3DQpPQnpJZ3ZKNzBwL2dPR1ZBMzZBTDFQamlBTnczbGZKaE1udVR1MUFSRTR0QlhvNTVTSHMxOEExTGdDeWpaKzNDDQpzQXIzaWFzSmlVZGdDWkduQkhkM1hQR0hHV1NDMU43ejNPNU9CbEpaTFIyZXVTbVVLZ0djeGxDdVNwRzd3L2pKDQpvM1RzN0ZYUVM4U0NaMkNFdFo2Y2RSU2IvZUdBUjAwMnA0aTkrL1p4cDU3V0lMWG0zM3g0UEsydXJtY1dqa2RZDQowRHFsZk52MDFBSldNM1RCK0I3RS9vd2FrKzVUeHBySEF6cm9YcFBNc2tyb2hOWW5wdXU2VUZOWTRMbmJ2OVJSDQpqNTJYUTVVZDdSM3kvYndrRmkxdTBoR04ybkVxUXdZUDY4VlFIQ0l2TnJPWjNVMmZGR3MwNDFxeGlwTzNreldmDQpGeElCanFpNHlkaHgzQ3ZuZ016Zy9KcVZvY1NlNXZQS0Rtd2VtNWsvL1NwNXlyaTZ1b2J3aU9KWTd0cjZwZEdyDQpISlpGY3Z1S1JKQzB4bTdDN2dMK0phcHhaV0tHREJjM3dkL05TSWo2U2N3VlFsaityR1l1VnVMR1BpRT0NCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0=
      name: resinharbor.com
```
新增完畢之後儲存離開  

#### 新增Guest Cluster並且部屬拉harbor的yaml檔案  

根據自己環境修改文件`name`,`namespace`,`version`,`storageClass`  
其中`class`,`count`,`volumes`建議一樣即可  
```
apiVersion: run.tanzu.vmware.com/v1alpha1
kind: TanzuKubernetesCluster
metadata:
  name: demogc1
  namespace: demo
spec:
  distribution:
    version: v1.20
  topology:
    controlPlane:
      count: 1
      class: best-effort-small
      storageClass: wcppolicy
      volumes:
        - name: etcd
          mountPath: /var/lib/etcd
          capacity:
            storage: 20Gi
    workers:
      count: 2
      class: best-effort-small
      storageClass: wcppolicy
      volumes:
        - name: containerd
          mountPath: /var/lib/containerd
          capacity:
            storage: 50Gi
```
等待建立完成之後  
切換環境過去  

```
kubectl vsphere login --insecure-skip-tls-verify --server 10.74.0.1 --vsphere-username administrator@vsphere.local --tanzu-kubernetes-cluster-name demogc1 
kubectl config use-context demogc1
```

建立Deployment服務  
其中`image`需要指定到harbor上的images(由前一個session產生，也可以放入自己的內容)
```
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-ui
spec:
  selector:
    matchLabels:
      app: nginx-ui
  replicas: 2 # tells deployment to run 2 pods matching the template
  imagePullSecrets:
  template:
    metadata:
      labels:
        app: nginx-ui
    spec:
      containers:
      - name: nginx-ui
        image: resinharbor.com/demo/ubuntu:latest
        ports:
        - containerPort: 80
```

之後部屬此檔案進行測試


