# KubernetesDashboard  

使用kubectl apply 的方式直接部屬yaml檔案  
之後透過tunnel& kubectl proxy的方式連線  

## 安裝步驟   

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
```

## 產生登入憑證  
  
Dashboard的服務是跟ServiceAccount綁定  
所以會產生一組SA然後進行綁定  
之後利用Token進行登入  

產生一組SA  
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

將SA進行ClusterRoleBinding  
```
cat <<EOF | kubectl create -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

產生憑證  
```
kubectl -n kubernetes-dashboard create token admin-user
```

## 從proxy進行登入  

```
kubectl proxy
```

之後設定tunnel  
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
