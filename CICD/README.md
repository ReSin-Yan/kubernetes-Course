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
cd
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
mkdir jenkins
```

接著需要將此資料夾進行設定  
分別設置此資料夾的權限  
以及誰可以讀取(jenkins的images是預設跑root權限，所以在設定時要root權限給此資料夾)  
```
sudo chmod +777 jenkins_home
sudo chown -R 1000:1000 jenkins_home/
sudo chmod +777 jenkins/
```

接著執行部屬指令  
注意這邊是需要jdk8版本的jenkins，因為此環境預計與gitlab連結，所以會需要jdk8版本  
如果連結其它環境則不需要  
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
搜尋gitlab  
之後點選Install without restart  
Gitlab  
Gitlab authentication  
generic webhook trigger  

搜尋ssh  
Publi over ssh  
ssh agent  
ssh pipline steps  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/plugin.PNG)   

#### 新增節點

`Dashboard` >  `Manage Jenkins` > `Manage Nodes and Clouds` 左邊點選 `New Node`  
輸入Node name  
選擇Permanent Agent  

![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/Jenkins/cicd/addnode1.PNG)   



 | 項目 | 輸入資訊 | 說明 | 
|-------|-------|-------| 
| Name | 好分辨的即可 | 好分辨的即可 |
| Remote root directory | /home/ubuntu/jenkins/ | 在此範例請使用此路徑 |
| labels | worker | 目前此node的角色，會影響之後在寫pipline的設定 |
| launch method | Launch agents via ssh | 啟動此節點的方式 |
| Host | your VM IP | 連線機器的IP |

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


### Gitlab建立專案並且跟Jenkins設定連結    

#### Gitlab 建立新專案  
進到Gitlab頁面  
點選`New Project` >  `Create blank project`  
Project URL 選擇 root  
依序輸入`Project Name`並把Visibility Level調整成`Public`  > 點選`Create Project`  
[build folder](https://github.com/ReSin-Yan/NTUSTCourse/tree/main/CICD/build "link")  
並上傳此build資料夾內的全部資料(需要新建一個資料夾)  

#### Jenkins 建立新專案並且與Gitlab進行連結  
進到Jenkins頁面  .
點選`New Item` > `點選pipline並且輸入名稱` (名稱建議有意義)  `OK`  

建立之後再 Build Triggers打勾 
Build when a change is pushed to GitLab. GitLab webhook URL:xxxxxxxxxxxxx  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/img/jenkinsetting1.PNG)   
注意要將URL複製下來接下來會將此貼到Gitlab的設定內  
右下角 `Advanced` > 拉到最下面有一個 `Secret token` 點選Generate  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/img/jenkinsetting2.PNG)   
紀錄完以上兩筆資訊之後，點選儲存建立  

將以上兩個資訊記錄下來  
在Gitlab頁面，進入到project內後  
點選左邊`Setting` > `Webhooks` 依序輸入`URL` 和 `Secret token`  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/img/jenkinsetting3.PNG)   
`Add webhook`  
可以點選測試來測試看看連結是否成功  

回到jenkins 專案的Dashboard，如果可以看到左下角自動跑出build history及代表成功連結  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/img/jenkinsetting5.PNG)   

### 建立jenkinsfiles  

#### 決定Jenkins pipline是寫在Jenkins or Gitlab  
這段是可以自己決定的  
本篇使用的方式為將檔案一起放入Gitlab內  
所以需要額外設定兩個步驟  
1.將pipline檔案(Jenkinsfiles)放入Gitlab  
2.在jenkins內部設定預設執行的腳本從Gitlab內搜尋  


#### 在jenkins內部設定預設執行的腳本從Gitlab內搜尋  
回到Jenkins，點選 `Configure` > `pipeline`  
分別設定  
Definition > `pipeline script form SCM`  
SCM > `Git`  
Repository > `你的gitlab project URL`，要加.git(很重要，會考 Ricky說的)  
Branch specifier > `*/*`  
Script Path > `Jenkinsfile`  
![img](https://github.com/ReSin-Yan/Kubernetes-Opensource-Project/blob/main/CICD/img/jenkinsetting6.PNG)   


#### 將pipline檔案放入Gitlab  
在gitlab project內新增檔案  
點選檔案上的`+`  > `New file` > 名子輸入 `Jenkinsfile` (記住此名稱，需要跟在Jenkins那邊設定相同)  


接著貼上  

```
pipeline {
  agent none 
  stages {
    stage("CICD Connect Test"){
      agent {label "worker"}
      steps{
        sh """
          ls
        """
      }
    }
  }
}
```

接著可以在Gitlab測試是否連結成功  
隨便更改一下jenkinsfiles內部的指令  

#### 利用Jenkinsfile自動建立地端的容器服務  

[Jenkinsfilev2](https://github.com/ReSin-Yan/NTUSTCourse/blob/main/CICD/Jenkinsfile/Jenkinsfilev2 "link")  

```
pipeline{
  agent none 
  stages{
    stage("Build image"){
      agent{label "worker"}
      steps{
        sh """
          docker build . -t http:${BUILD_NUMBER}
        """
      }
    }
    stage('run web service') {
      agent {label "worker"}
      steps {
        script {
          try {
            sh """
            docker rm -f http
            """
        } finally {
            sh """
            docker run -d --name http -p 8888:80 http:${BUILD_NUMBER}
            """
          }
        }  
      }
    }

  }
}
```

### 利用jenkinsfiles來達成CICD  

#### 利用Jenkinsfile自動建立地端的容器服務  

[Jenkinsfilev2](https://github.com/ReSin-Yan/NTUSTCourse/blob/main/CICD/Jenkinsfile/Jenkinsfilev2 "link")  


也可以直接貼入以下內容  
需要修改[ntustxx] 成您的帳號  
```
pipeline{
  agent none 
  stages{
    stage("Build image"){
      agent{label "worker"}
      steps{
        sh """
          docker build build/ -t http:${BUILD_NUMBER}
        """
      }
    }
    stage("push image"){
      agent{label "worker"}
      steps{
        sh """
          docker login harbor.zeronetanzu.lab -u admin -p Harbor12345
          docker tag http:${BUILD_NUMBER} harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
          docker push harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
        """
      }
    }
    stage('Delete exist image') {
      agent {label "worker"}
      steps {
        sh """
          docker rmi harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
        """
      }  
    }
    stage('run web service') {
      agent {label "worker"}
      steps {
        script {
          try {
            sh """
            docker rm -f http
            """
        } finally {
            sh """
            docker run -d --name http -p 8888:80 harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
            """
          }
        }  
      }
    }

  }
}
```


#### 利用Jenkinsfile自動建立Kubernetes的容器服務  

[Jenkinsfilev3](https://github.com/ReSin-Yan/NTUSTCourse/blob/main/CICD/Jenkinsfile/Jenkinsfilev3 "link")  


也可以直接貼入以下內容  
需要修改[ntustxx] 成您的帳號  
輸入對應的vc帳號密碼，以及TKC名稱  
新增http.yaml 跟 webservice.yaml  
```
pipeline{
  agent none 
  stages{
    stage("Build image"){
      agent{label "worker"}
      steps{
        sh """
          docker build build/ -t http:${BUILD_NUMBER}
        """
      }
    }
    stage("push image"){
      agent{label "worker"}
      steps{
        sh """
          docker login harbor.zeronetanzu.lab -u admin -p Harbor12345
          docker tag http:${BUILD_NUMBER} harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
          docker push harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
        """
      }
    }
    stage('Delete exist image') {
      agent {label "worker"}
      steps {
        sh """
          docker rmi harbor.zeronetanzu.lab/[ntustxx]/http:${BUILD_NUMBER}
        """
      }  
    }
    stage('Tanzu developer login') {
            agent {label "worker"}
            steps {
                sh """
                    export KUBECTL_VSPHERE_PASSWORD=1qaz@WSX
                    kubectl vsphere login --insecure-skip-tls-verify --server 172.18.17.22 --vsphere-username ntust@vsphere.local --tanzu-kubernetes-cluster-name ntust-tkcxx
                    kubectl config use-context ntust-tkcxx
                """
            }
    }
    stage("deployhttp"){
            agent {label "worker"}
            steps {
                sh """
                    kubectl apply -f webservice.yaml
                    export NAME=${BUILD_NUMBER}
                    envsubst < http.yaml > check.yaml
                    cat check.yaml
                    kubectl apply -f check.yaml
                    kubectl delete -f check.yaml
                    kubectl apply -f check.yaml

                """
            }
    }
    stage("show Development service IP"){
            agent {label "worker"}
            steps {
                sh """
                    kubectl get svc | grep http
                """
            }
    }
  }
}
```
