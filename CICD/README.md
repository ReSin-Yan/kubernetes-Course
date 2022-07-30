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

### Jenkins基本設置    

#### 環境準備  
第一步需要建立放置Jenkins啟動之後  
放置一些相關文件及記錄檔的位置  
```
mkdir jenkins_home
```

接著需要將此資料夾進行設定  
分別設置此資料夾的權限  
以及誰可以讀取(jenkins的images是預設跑root權限，所以在設定時要root權限給此資料夾)  
```
sudo chmod +777 jenkins_home
sudo chown -R 1000:1000 jenkins_home/
```

接著執行部屬指令  
注意這邊是需要jdk8版本的jenkins，因為此環境預計與gitlab連結，所以會需要jdk8版本  
如果連結其它環境則不需要  
- ![#f03c15](https://via.placeholder.com/15/f03c15/000000?text=+) 
注意路徑/home/ubuntu/jenkins_home，請改成自己環境的路徑  
  
```
sudo docker run --name jenkins -p 8080:8080 -p 50000:50000 -v /home/ubuntu/jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts-jdk8
```
#### 開啟網頁&基礎設置  
接下來可以透過此網頁的IP:8080進入到jenkins環境  
<http://ThisVMIP:8080/>  
靜待服務開啟  

接著會請您輸入啟動的token  
啟動token可以在兩個地方找到  
第一種方式如下圖，可以在執行的地方視窗找到  
圖片  

第二種方式需要另外開ssh連線  
```
cat jenkins_home/secrets/initialAdminPassword
```

如果連線視窗關閉，網頁會關閉(因為容器會一起關掉)  
此時開啟新的連線輸入以下即可  
```
sudo docker start jenkins
```

將獲得到的Token輸入  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/input%20token.PNG)   

接著選擇左邊安裝建議插件(之後會再補其它的插件)  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/install%20suggested%20plugin.PNG)   

等待安裝完成

建立admin帳號  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/creat%20admin.PNG)   

設定URL  
保持預設即可  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/set%20URL.PNG)   

以上到這邊基本安裝完成  

### Jenkins準備連結gitlab  

Jenkins基本安裝完成之後  
還需要額外設定  
分別為  
`插件安裝`  
跟  
`加入節點`


#### 插件安裝  

`Dashboard` >  `Manage Jenkins` > `Manage Plugins` > `Available`
依序搜尋這些套件並勾起  
之後點選Install without restart  
Gitlab  
Gitlab Webhook  
Gitlab authentication  
generic webhook trigger  

ssh  
Public over ssh  
ssh agent  
ssh pipline steps  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/plugin.PNG)   

#### 新增節點

`Dashboard` >  `Manage Jenkins` > `Manage Nodes and Clouds` 左邊點選 `New Node`  
輸入Node name  
選擇Permanent Agent  

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/addnode1.PNG)   



 | 項目 | 輸入資訊 | 
|-------|-------|
| Name | 好分辨的即可 |
| Remote root directory | /home/ubuntu/jenkins/  (如果其他節點的安裝步驟有按照其它的安裝步驟) |
| labels | 目前此node的角色，會影響之後在寫pipline的設定 |
| launch method | Launch agents via ssh |
| Host | 連線機器的IP |

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/addnode2.PNG)   


Credentials 點選Add  
選擇使用Username 跟 Password  
並且輸入  
在Jenkins內，是以憑證方式儲存，如果其它node的帳號密碼相同  
那可以透過同一組憑證來使用  

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/addnode4.PNG)   



 | 項目 | 輸入資訊 | 
|-------|-------|
| Host Key Verofocatopn Strategy | Non verifiying Verification Strategy |

其它項目保持預設就可以了  

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/addnode3.PNG)   

