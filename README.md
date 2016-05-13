# Introduction

Dockerfile to build a [facebook CTF](https://github.com/facebook/fbctf) container image.

# Work in progress

To be done :
 * run on port 443? (Do we really want the container to take care of the SSL termination? Sessions won't work if we don't use SSL though)

# Quick Start

Using docker-compose

```bash
docker-compose up
```

 Step 1. Launch a mysql container

 ```bash
 docker run --name fbctf-mysql -d \
     --env MYSQL_ROOT_PASSWORD=root --env MYSQL_DATABASE=fbctf \
     --env MYSQL_USER=fbctf --env MYSQL_PASSWORD=fbctf \
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
