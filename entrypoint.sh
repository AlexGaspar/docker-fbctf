#!/bin/bash

source "$CTF_PATH/extra/lib.sh"

# Make attachments folder world writable
chmod 777 "$CTF_PATH/src/data/attachments" \
    && chmod 777 "$CTF_PATH/src/data/attachments/deleted"

# Configure HHVM
chown -R www-data:www-data /etc/hhvm/*
cat "$CTF_PATH/extra/hhvm.conf" | sed "s|CTFPATH|$CTF_PATH/|g" | tee /etc/hhvm/server.ini

# Configure nginx
chown -R www-data:www-data /var/www/*
# cat "$CTF_PATH/extra/nginx.conf" | sed "s|CTFPATH|$CTF_PATH/src|g" | tee /etc/nginx/sites-available/fbctf.conf
rm /etc/nginx/sites-enabled/* \
  && ln -s /etc/nginx/sites-available/fbctf.conf /etc/nginx/sites-enabled/fbctf.conf

# Forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# Set linked mysql container as mysql host
echo -e "[client]\nhost=mysql" > ~/.my.cnf

 # Wait for the mysql container to be ready
while ! nc -z mysql 3306; do
  echo "Waiting for mysql to start";
  sleep 1;
done;

# Don't errase the database if it exists
if $(mysqlshow -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE &> /dev/null); then
  echo "Database already created... skipping creation..."
else
  import_empty_db "$MYSQL_USER" "$MYSQL_PASSWORD" "$MYSQL_DATABASE" "$CTF_PATH" "prod"
fi

# Configuring settings.ini
cat "$CTF_PATH/settings.env.ini" \
  | sed "s/MYSQL_PORT/$MYSQL_PORT/g" \
  | sed "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
  | sed "s/MYSQL_USER/$MYSQL_USER/g" \
  | sed "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
  | sed "s/MEMCACHED_HOST/$MEMCACHED_HOST/g" \
  | sed "s/MEMCACHED_PORT/$MEMCACHED_PORT/g" \
  > "$CTF_PATH/settings.ini"

sudo -u www-data hhvm --config /etc/hhvm/server.ini --mode daemon

exec "$@"
