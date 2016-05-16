# Introduction

Dockerfile to build a [facebook CTF](https://github.com/facebook/fbctf) container image.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/AlexGaspar/docker-fbctf/issues) they may encounter

# Quick Start

The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/).

Using docker-compose

```bash
docker-compose up
```

Alternatively, you can manually launch the `fbctl` container and the supporting `mysql` and `memcached` containers by following this three step guide.

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
 
# Configuration

## SSL
fbctf requires you to server the application over HTTPS (otherwise the sessions will not work properly). By default docker-fbctf will generate self signed certificate to meet this requirement, in this configuration, any requests made over the plain http protocol will automatically be redirected to use the https protocol. If you know your way arround SSL certificate, you can disable it by setting `SSL_SELF_SIGNED` to `false`.

