# Introduction

Dockerfile to build a [facebook CTF](https://github.com/facebook/fbctf) container image.


# Work in progress

To be done :
 * Provisioning mysql
 * run on port 443? (Do we really want the container to take care of the SSL termination?)

# Quick Start

Using docker-compose

```bash
docker-compose up
```

 Step 1. Launch a mysql container

 ```bash
 docker run --name fbctf-mysql -d \
     --env MYSQL_ROOT_PASSWORD=root \
     mysql:5.6
 ```

 Step 2. Launch a memcached container

 ```bash
 docker run --name fbctf-memcached -d memcached
 ```

 Step 3. Launch the fbctf container

 ```bash
 docker run --name fbctf -d \
    --link my-memcache:memcache --link fbctf-mysql:mysql
     --publish 10080:80 --publish 10443:443 \
     alexgaspar/fbctf:latest
 ```
