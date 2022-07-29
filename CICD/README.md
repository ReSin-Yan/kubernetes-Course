# CICD簡述  

## 環境準備以及說明  

### Jenkins  
Jenkins是一種開源的CI&CD應用軟體，用於自動化各種任務，其中包括建置、測試和部屬應用。    
Jenkins支援各種運作方式，可以通過底層系統、Docker或著通過Java Program來運行。  


### Gitlab  
與本文所在的位置Github類似   
使用雲端平台的GitHub，需要將程式馬上傳，如果設為私有會需要額外收費。  
GitLab就是完全免費的(社群版免費，企業版需要定月)  
能夠瀏覽程式碼，管理BUG和註解，適合再團隊內部使用。  

### Harbor  
安裝步驟參考下列連結  
[Harbor](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/tree/main/Harbor "link")  

### Build-server  
在此環境設置中  
需要有一個環境用來建立容器images    
並且在建立完成之後將images推送到Harbor容器倉庫  

## 安裝步驟  

### Gitlab  

#### Gitlab建置   

建立存放資料的位置資料夾  
並將此資料夾設定環境變數  
```
mkdir gitlab
export GITLAB_HOME=/home/ubuntu/gitlab
```

接著執行docker指令來創建服務
```
sudo docker run -d   -p 443:443 -p 80:80 -p 2224:22   --name gitlab   --restart always   -v $GITLAB_HOME/config:/etc/gitlab   -v $GITLAB_HOME/logs:/var/log/gitlab   -v $GITLAB_HOME/data:/var/opt/gitlab   gitlab/gitlab-ee:latest
```

#### 開啟網頁&基礎設置  
接下來可以透過此網頁進入到Gitlab環境  
<http://ThisVMIP/>  
靜待服務開啟  
接著在指令介面輸入  
```
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```
取得登入用的密碼(預設帳號為root)
請記得再登入之後，記得去更改密碼  


#### 設定允許webhook  
Jenkins與Gitlab的連結透過webhook進行  
Gitlab新版本預設把local的功能關閉  
所以必須將此功能打開  
`Gitlab` > `Menu` > `Admin`  
左下角`Setting` > `Network` > `Outbound Request` > 將兩個都勾起  
