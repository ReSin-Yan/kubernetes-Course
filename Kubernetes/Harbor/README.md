# Harbor  
此資料夾包含安裝步驟的說明文件，以及其他相關會用到的資訊  
目前有:  
再Tanzu環境使用外部式Harbor  


以下為Https + FQDN的 Harbor安裝模式  

## 安裝步驟  

#### 環境硬體配置(建議需求)  
使用的環境為  
OS      :ubutu desktop 20.04  
CPU     :4 CPU  
Memory  :8 GB  
Disk    :200GB  

#### 環境套件需求(必要)  
Docker engine   : Version 17.06.0-ce+ 或著更高版本  
Docker Compose  : Version 1.18.0 或著更高版本  
Openssl         : 最新版本  

(在ubutnu20版本不需要額外安裝)  

#### 環境準備  

環境更新及安裝基本套件  
```
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y install vim build-essential curl ssh
sudo apt-get install net-tools
sudo apt-get install nfs-kernel-server nfs-common
```

安裝Docker engine    
```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

確認安裝版本
```
sudo docker --version
```

安裝Docker Compose    
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

確認安裝版本
```
sudo docker-compose --version
```

### 憑證準備  

#### 建立存放資料夾  

憑證將會放到此資料夾，接下來harbor的安裝包也會下載到這邊  
```
mkdir harbor
cd harbor/
```

#### 產生由認證機構發布的證書  

建立本地https憑證  
其中`<YourFQDN>`整段換成自己的FQDN  
參數內部是包含時區...等資訊  
參數可以跟自行修改或是按照步驟中設定即可  


生成 CA key
```
openssl genrsa -out ca.key 4096
```

生成 CA 憑證
```
openssl req -x509 -new -nodes -sha512 -days 3650 -subj  "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=<YourFQDN>.com" -key ca.key -out ca.crt
```

#### 生成 server的憑證  

憑證通常包含一個 .crt 文件和一個 .key 文件  

生成私有金鑰  
```
openssl genrsa -out <YourFQDN>.com.key 4096
```

生成certificate signing request(CSR)  
```
openssl req -sha512 -new -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN=<YourFQDN>.com" -key <YourFQDN>.com.key -out <YourFQDN>.com.csr
```

#### 建立 x509 v3 擴展文件  

無論是使用 FQDN 還是 IP 地址連接到Harbor  
都必須創建此文件，讓Harbor主機產生符合(SAN)和x509 v3的憑證要求  
替換DNS.1,DNS.2,DNS.3  
```
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1=<YourFQDN>.com
DNS.2=<YourFQDN>
DNS.3=<VM-Hostname>
EOF
```

#### 使用v3.ext文件為Harbor生成憑證  

```
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in <YourFQDN>.com.csr -out <YourFQDN>.com.crt
```

#### 將憑證轉換為Docker所需要的cert格式  
```
openssl x509 -inform PEM -in <YourFQDN>.com.crt -out <YourFQDN>.com.cert
```

### Harbor安裝  

#### 使用離線安裝包  

版本為2.2.3  
解壓縮之後進入資料夾
```
wget https://github.com/goharbor/harbor/releases/download/v2.2.3/harbor-offline-installer-v2.2.3.tgz
tar -zxvf harbor-offline-installer-v2.2.3.tgz
cd harbor/
```

#### 複製及編輯設定檔  

需要修改兩個部分  
hostname  
https的certificate跟private_key  
```
cp harbor.yml.tmpl harbor.yml
vim harbor.yml 
```
編輯完成之後如圖  
我測試用的FQDN為resinharbor.com  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Harbor/harbor%E8%A8%AD%E5%AE%9A.PNG)   

#### 安裝  

```
sudo ./install.sh --with-notary --with-trivy --with-chartmuseum  
```

#### 網頁連線測試
接下來就可以透過FQDN連線進去  
<https://yourdomain.com/>  
(需要設定DNS連線，或是設定hosts指向此FQDN對應的IP)
預設帳號`amdin` 密碼  `Harbor12345`  
此組帳號密碼可以在harbor.yml內設定  

#### 掃描功能bug修復  
原因是因為掃描功能的image的DNS解析有問題  
所以會造成掃描失敗  
參考以下步驟解決DNS問題  

```
$ sudo docker exec -u 0 -it trivy-adapter bash
root [ / ]# echo "nameserver 127.0.0.11
> nameserver 78.129.140.65
> options edns0 ndots:0" > /etc/resolv.conf
```


## 測試步驟  

### Docker login  

可以在其他主機登入此組harbor  
登入所需要的憑證為  
`resinharbor.com.cert`  
`ca.crt`  
`resinharbor.com.key`   

#### 將登入憑證放入目標機器  

目標機器也需要  
先在目標機器產生資料夾  
```
sudo mkdir /etc/docker/certs.d
sudo mkdir /etc/docker/certs.d/<YourFQDN>.com
```
將`resinharbor.com.cert` `ca.crt` `resinharbor.com.key` 放入此資料夾內

進行docker login
```
sudo docker login <YourFQDN>.com
```

### Push images

#### 建立project

需要先建立一個`project`  
建立方式  
登入Harbor頁面之後  
點選`新建項目`  
依序輸入  
`項目名稱`      : demo  
`訪問級別`      :選擇公開  
`Proxy Cache`   : 開啟  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/Harbor/harborNewProject.PNG)   
   

#### 下載images  

下載images，這邊使用ubutnu當作範例  
```
sudo docker pull ubuntu
```

#### 推送images

先將images打上FQDN的tag之後  
執行push  
```
sudo docker tag ubuntu:latest <YourFQDN>.com/demo/ubuntu:latest
sudo docker push <YourFQDN>.com/demo/ubuntu:latest
```

### Pull images

再Pull Images的時候也需要執行登入指令   
包含登入以及放入憑證  


### 準備NFS  


[參考網站](https://linuxhint.com/install-and-configure-nfs-server-ubuntu-22-04/ "link")  

輸入以下指令，創建NFS的資料夾  
```
cd
mkdir /nfsshare
sudo vim /etc/exports
```

加入  
```
/home/ubuntu/nfsshare    *(rw,sync,no_root_squash,no_all_squash)
```
