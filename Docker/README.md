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

## 相關指令操作   

### 實際建立服務(nginx service)  

利用-p建立port連結  
8080代表Ubuntu的8080 port(地端)  
80代表容器端的80port(容器端)  
透過這種方式來把服務做一個mapping  
```
sudo docker run -it -d -p 8080:80 --name web nginx
```
打開網頁<http://ThisVMIP:8080/>    

```
sudo docker rm -f web
```

### 實際建立服務(filebrowser)  

利用-v建立儲存空間的連結  
容器本身的執行階段是短暫的  
所以如果是需要長期存放的資料須要透過掛階儲存空間(volumes)的方式  
將容器產生出來的資料進行存放  
```
cd 
mkdir test
sudo docker run -d --name filebrowser  -v /home/ubuntu/test:/data -p 8080:8080 hurlenko/filebrowser
```
打開網頁<http://ThisVMIP:8080/>    
隨意上傳檔案

```
cd /home/ubuntu/test
ls
```

```
sudo docker rm -f filebrowser
```

### Dockerfile  

建立Dockerfile  
```
cd
mkdir dockerfile


sudo tee Dockerfile <<EOF
FROM centos:7
MAINTAINER NewstarCorporation
RUN yum -y install httpd
COPY index.html /var/www/html/
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
EXPOSE 80
EOF
```

建立index.html  
```
sudo tee index.html <<EOF
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Hello world!!!</title>
    </head>
    <body bgcolor="blue">
      <h1>Hello workd</h1>
    </body>
</html>
EOF
```
