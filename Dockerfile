FROM minio/mc:RELEASE.2019-09-20T00-09-55Z as mc
FROM php:7.3.9-fpm-alpine3.10

MAINTAINER ngineered <support@ngineered.co.uk>

ENV php_conf /etc/php7/php.ini
ENV fpm_conf /etc/php7/php-fpm.d/www.conf

COPY --from=mc /usr/bin/mc /usr/bin/mc

RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && apk update && \
    apk add --no-cache bash \
    openssh-client \
    wget \
    nginx \
    supervisor \
    curl \
    git \
    php7-fpm \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqlnd \
    php7-mysqli \
    php7-mcrypt \
    php7-ctype \
    php7-zlib \
    php7-gd \
    php7-intl \
    php7-memcached \
    php7-sqlite3 \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-xml \
    php7-xsl \
    php7-curl \
    php7-openssl \
    php7-iconv \
    php7-json \
    php7-phar \
    php7-soap \
    php7-dom

ADD conf/supervisord.conf /etc/supervisord.conf

# Copy our nginx config
# RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/php-fpm.conf /etc/php7/php-fpm.conf

# nginx site conf
RUN mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /app && \
    mkdir -p /run/nginx && \
    mkdir -p /etc/nginx/sites-enabled/

ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
  sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
  sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
  sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} && \
  sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf} && \
  sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} && \
  sed -i -e "s/pm.max_children = 4/pm.max_children = 4/g" ${fpm_conf} && \
  sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" ${fpm_conf} && \
  sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" ${fpm_conf} && \
  sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" ${fpm_conf} && \
  sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} && \
  sed -i -e "s/user = nobody/user = nginx/g" ${fpm_conf} && \
  sed -i -e "s/group = nobody/group = nginx/g" ${fpm_conf} && \
  sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" ${fpm_conf} && \
  sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_conf} && \
  sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_conf} && \
  sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf} && \
  sed -i -e "s/;clear_env = no/clear_env = no/g" ${fpm_conf} && \
  ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini && \
  find /etc/php7/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# Add Scripts
ADD scripts/start.sh /start.sh
RUN chmod 755 /start.sh

VOLUME /app
EXPOSE 80

CMD ["/start.sh"]
