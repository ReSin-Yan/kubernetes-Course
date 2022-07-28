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

 | 指令 | 說明  | 範例 |
|-------|-------|-------|
| run | 	新建或啟動 |  docker run -d centos |
| start [Contain ID]	 | 啟動 |  docker start xx |
| stop [Contain ID]		 | 停止 |  docker stop xx |
| rm [Contain ID]	 | 刪除 |  docker rm xx |
| rmi [Images ID]	 | 刪除映像檔 |  docker rmi xx |
| ps -a	 | 啟動 |  docker start a469b9226fc8 |
| logs [Contain ID]	 | 查看容器內的資訊 |  		docker logs -f a4 |
| attach [Contain ID]		 | 進入容器 |  	docker attach  a4  |
| inspect	 | 查看 |  docker inspect a4 |
| images	 | 啟動 |  docker start a469b9226fc8 |
| start [Contain ID]	 | 啟動 |  docker start a469b9226fc8 |
| start [Contain ID]	 | 啟動 |  docker start a469b9226fc8 |


