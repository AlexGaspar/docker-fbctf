# Introduction

Dockerfile to build a [facebook CTF](https://github.com/facebook/fbctf) container image.

# Quick Start

fbctf needs to be server over https, so by default it would generate a self-signed certificate, if you want to use your own certificate you can turn this off by setting `$SSL` to `false`, then fbctf container will only server request over :80, so you can do the SSL termination where ever you prefer.

Using docker-compose

```bash
docker-compose up
```

 Step 1. Launch a mysql container

 ```bash
 docker run --name fbctf-mysql -d \
     --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=fbctf \
     --env MYSQL_USER=fbctf --env MYSQL_PASSWORD=fbctf \
     --volume /opt/docker/fbctf/mysql:/var/lib/mysql \
     mysql:5.5
 ```

 Step 2. Launch a memcached container

 ```bash
 docker run --name fbctf-memcached -d memcached
 ```

 Step 3. Launch the fbctf container

 ```bash
 docker run --name fbctf -d \
     --link fbctf-memcached:memcached --link fbctf-mysql:mysql \
     --publish 10080:80 \
     --env MYSQL_USER=fbctf --env MYSQL_PASSWORD=fbctf \
     --env MYSQL_PORT=3306 --env MYSQL_DATABASE=fbctf \
     --env MEMCACHED_PORT=11211 \
     alexgaspar/fbctf:latest
 ```
