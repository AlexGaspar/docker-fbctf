#!/bin/bash

cat "$CTF_PATH/settings.env.ini" \
  | sed "s/MYSQL_HOST/$MYSQL_HOST/g" \
  | sed "s/MYSQL_PORT/$MYSQL_PORT/g" \
  | sed "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
  | sed "s/MYSQL_USER/$MYSQL_USER/g" \
  | sed "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
  | sed "s/MEMCACHED_HOST/$MEMCACHED_HOST/g" \
  | sed "s/MEMCACHED_PORT/$MEMCACHED_PORT/g" \
  > "$CTF_PATH/settings.ini"

service hhvm restart > /dev/null

exec "$@"
