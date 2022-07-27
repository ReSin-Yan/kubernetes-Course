# Docker  
  
[上課簡報下載](https://goharbor.io/docs/2.3.0/ "link")  


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

#### 環境準備  

環境更新及安裝基本套件  
```
sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y install vim build-essential curl ssh
sudo apt-get install net-tools
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

## 相關指令操作   

### 環境硬體配置(建議需求)  
