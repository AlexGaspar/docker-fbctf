#!/bin/bash

source "$CTF_PATH/extra/lib.sh"

# Set linked container as host
echo -e "[client]\nhost=mysql" > ~/.my.cnf

 # Database creation
while ! nc -z mysql 3306; do
  echo "Waiting for mysql to start";
  sleep 3;
done;

import_empty_db "$MYSQL_USER" "$MYSQL_PASSWORD" "$MYSQL_DATABASE" "$CTF_PATH" "prod"

# Configuring settings.ini
cat "$CTF_PATH/settings.env.ini" \
  | sed "s/MYSQL_PORT/$MYSQL_PORT/g" \
  | sed "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
  | sed "s/MYSQL_USER/$MYSQL_USER/g" \
  | sed "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
  | sed "s/MEMCACHED_HOST/$MEMCACHED_HOST/g" \
  | sed "s/MEMCACHED_PORT/$MEMCACHED_PORT/g" \
  > "$CTF_PATH/settings.ini"

service hhvm restart > /dev/null

exec "$@"
