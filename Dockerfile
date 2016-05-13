FROM brunoric/hhvm:deb-hhvm

ENV CTF_PATH /var/www/fbctf
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --force-yes curl language-pack-en git npm nodejs-legacy

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p $CTF_PATH
ADD . $CTF_PATH
WORKDIR $CTF_PATH

# Install Vendors
RUN composer install

# Make attachments folder world writable
RUN chmod 777 "$CTF_PATH/src/data/attachments" && \
    chmod 777 "$CTF_PATH/src/data/attachments/deleted"

RUN npm install && npm install -g grunt && npm install -g flow-bin
RUN grunt

# Configure HHVM
RUN cat "$CTF_PATH/extra/hhvm.conf" | sed "s|CTFPATH|$CTF_PATH/|g" | tee /etc/hhvm/server.ini

# Update permissions
# RUN chown -R www-data:www-data /var/www/*

# Install nginx
#

EXPOSE 80 443
