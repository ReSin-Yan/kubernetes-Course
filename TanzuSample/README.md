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
