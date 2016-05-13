FROM brunoric/hhvm:deb-hhvm

ENV CTF_PATH /var/www/fbctf
ENV DEBIAN_FRONTEND noninteractive
ENV CTF_REPO https://github.com/facebook/fbctf.git

RUN apt-get update && apt-get install -y --force-yes curl language-pack-en git npm nodejs-legacy nginx

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p $CTF_PATH
WORKDIR $CTF_PATH

# Install CTF
RUN git clone --depth 1 $CTF_REPO .

# Install Vendors
RUN composer install

# Make attachments folder world writable
RUN chmod 777 "$CTF_PATH/src/data/attachments" \
    && chmod 777 "$CTF_PATH/src/data/attachments/deleted"

RUN npm install && npm install -g grunt && npm install -g flow-bin
RUN grunt

# Configure HHVM
RUN cat "$CTF_PATH/extra/hhvm.conf" | sed "s|CTFPATH|$CTF_PATH/|g" | tee /etc/hhvm/server.ini

# Update permissions
RUN chown -R www-data:www-data /var/www/*

# Configure nginx
#RUN cat "$CTF_PATH/extra/nginx.conf" | sed "s|CTFPATH|$CTF_PATH/src|g" | tee /etc/nginx/sites-available/fbctf.conf
COPY fbctf.conf /etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/* \
    && ln -s /etc/nginx/sites-available/fbctf.conf /etc/nginx/sites-enabled/fbctf.conf

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Configure FBCTL
COPY settings.env.ini .

# Launch HHVM
RUN service hhvm start

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["./entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
