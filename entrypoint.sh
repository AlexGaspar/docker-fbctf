#!/bin/bash

source "$CTF_PATH/extra/lib.sh"

# Make attachments folder world writable
chmod 777 "$CTF_PATH/src/data/attachments" \
    && chmod 777 "$CTF_PATH/src/data/attachments/deleted"

# Configure HHVM
chown -R www-data:www-data /etc/hhvm/*
cat "$CTF_PATH/extra/hhvm.conf" | sed "s|CTFPATH|$CTF_PATH/|g" | tee /etc/hhvm/server.ini > /dev/null

# Configure nginx
chown -R www-data:www-data /var/www/*
rm /etc/nginx/sites-enabled/*

if ${SSL_SELF_SIGNED:=true}; then
  echo "Generating self-signed certificate..."
  __country=${SSL_COUNTRY:-"UK"}
  __city=${SSL_CITY:-"London"}
  __url=${CTF_URL:-"example.com"}
  __email=${SSL_EMAIL:-"dev@$__url"}

  # Generating self signed cert
  mkdir -p /etc/nginx/certs/
  cd /etc/nginx/certs/
  openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
  openssl rsa -passin pass:x -in server.pass.key -out server.key
  rm server.pass.key
  openssl req -new -key server.key -out server.csr \
    -subj "/C=$__country/ST=NRW/L=$__city/O=My Inc/OU=DevOps/CN=www.$__url/emailAddress=$__email"
  openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
  openssl dhparam -out dhparam.pem 2048
  cd - > /dev/null # restore directory

  cat "/etc/nginx/sites-available/fbctf_ssl.tmpl.conf" | sed "s|CTFPATH|$CTF_PATH/src|g" | tee /etc/nginx/sites-available/fbctf-ssl.conf > /dev/null
  ln -s /etc/nginx/sites-available/fbctf-ssl.conf /etc/nginx/sites-enabled/fbctf-ssl.conf
else
  ln -s /etc/nginx/sites-available/fbctf.conf /etc/nginx/sites-enabled/fbctf.conf
  sed -i -r -e '/private static bool \$s_secure/ {s/true/false/}' $CTF_PATH/src/SessionUtils.php
fi

# Forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# Set linked mysql container as mysql host

echo -e "[client]\nhost=$MYSQL_HOST" > ~/.my.cnf

 # Wait for the mysql container to be ready
while ! mysqlshow -u$MYSQL_USER -p$MYSQL_PASSWORD > /dev/null 2>&1; do
  echo "Waiting for mysql to be ready";
  sleep 1;
done;

# Don't errase the database if it exists & has table
if [ $(mysql -N -s -u $MYSQL_USER --password=$MYSQL_PASSWORD -e \
    "select count(*) from information_schema.tables where \
        table_schema='$MYSQL_DATABASE';") -ge 1 ]; then
    echo "Database already created... skipping creation..."
else
echo "creating DB"
  import_empty_db "$MYSQL_USER" "$MYSQL_PASSWORD" "$MYSQL_DATABASE" "$CTF_PATH" "prod"
fi

# Configuring settings.ini
cat "$CTF_PATH/settings.tmpl.ini" \
  | sed "s/MYSQL_PORT/$MYSQL_PORT/g" \
  | sed "s/MYSQL_HOST/$MYSQL_HOST/g" \
  | sed "s/MYSQL_DATABASE/$MYSQL_DATABASE/g" \
  | sed "s/MYSQL_USER/$MYSQL_USER/g" \
  | sed "s/MYSQL_PASSWORD/$MYSQL_PASSWORD/g" \
  | sed "s/MEMCACHED_HOST/$MEMCACHED_HOST/g" \
  | sed "s/MEMCACHED_PORT/$MEMCACHED_PORT/g" \
  > "$CTF_PATH/settings.ini"

sudo -u www-data hhvm --config /etc/hhvm/server.ini --mode daemon

exec "$@"
