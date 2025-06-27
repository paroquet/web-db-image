# WEB + DB 的脚手架，拷贝即用

包含

1. db 服务
2. db 迁移
3. web 服务
4. docker 镜像


## 数据库备份 & 恢复

### 备份
使用 pg_dump 导出 dump 文件，再使用 gzip 压缩
``` 
// <container_name_or_id> 可以用 docker ps 找到，比如 yourproject_db_1
// -U 指定数据库用户名
// -F c 是使用 PostgreSQL 的自定义格式（适合用 pg_restore 恢复）
// -d 是数据库名，默认数据库可以是 postgres 或你自己建的
// > 用于导出为本地文件
docker exec -t <container_name_or_id> pg_dump -U postgres_username -F c -d postgres > db_backup.dump

// 得到 db_backup.dump.gz
gzip db_backup.dump
```

### 恢复
``` 
# 1. 拷贝备份文件进去
docker cp db_backup.dump.gz <container_name>:/db_backup.dump.gz
# 2. 创建数据库（如果还没有）
docker exec -it <container_name> psql -U postgres_username -c "CREATE DATABASE mydb;"
# 3. 恢复
gunzip -c db_backup.dump.gz | docker exec -i <container_name> pg_restore -U postgres -d mydb

```

### 清除挂载数据

``` 
docker volume ls
docker inspect <your_postgres_container>
docker volume rm <volume_name>
```

### 清除容器

删除所有的卷
``` 
docker-compose down -v

[+] Running 4/4
 ✔ Container web-db-image-app-1       Removed                                                                                                                                                                                 0.0s 
 ✔ Container web-db-image-db-1        Removed                                                                                                                                                                                 0.0s 
 ✔ Network web-db-image_default       Removed                                                                                                                                                                                 0.2s 
 ✔ Volume web-db-image_postgres_data  Removed
```

## 应用启动

```
// -p 表示 project name
docker compose -p myapp up -d

// 也可以单独启动某一个服务
docker compose up -d db

```

## 应用更新

使用容器编译 + 部署存在2个问题：

1. JDK app 的镜像实在太大（600MB+）即使各种瘦身，也远大于 jar 包的体积（60MB）
2. 容器中打包 gradle boot jar 太慢（本地编译 15s，容器编译 500s）

解决方案是：
使用 docker compose 只下载一次 prostgres 镜像和 JDK 镜像，之后每次 jar 升级，都通过 JDK 容器执行 jar 来启动 app

docker compose 挂载 app 目录，先把 jar 包 scp 到 app 目录，启动时再执行 `java -jar app.jar`

``` 
scp app.jar root@192.168.1.100:~/app/
```

``` 
  app:
    image: amazoncorretto:21-alpine
    volumes:
      - ~/app:/app
    working_dir: /app
    command: ["java", "-jar", "app.jar"]
```