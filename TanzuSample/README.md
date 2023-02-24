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
