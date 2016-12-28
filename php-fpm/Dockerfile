FROM alpine:latest

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache \
        php7 \
        php7-amqp \
        php7-apache2 \
        php7-apcu \
        php7-ast \
        php7-bcmath \
        php7-bz2 \
        php7-calendar \
        php7-cassandra \
        php7-cgi \
        php7-common \
        php7-couchbase \
        php7-ctype \
        php7-curl \
        php7-dba \
        php7-dev \
        php7-doc \
        php7-dom \
        php7-embed \
        php7-enchant \
        php7-exif \
        php7-fpm \
        php7-ftp \
        php7-gd \
        php7-gettext \
        php7-gmagick \
        php7-gmp \
        php7-iconv \
        php7-imap \
        php7-inotify \
        php7-intl \
        php7-json \
        php7-ldap \
        php7-libsodium \
        php7-litespeed \
        php7-lzf \
        php7-mailparse \
        php7-mbstring \
        php7-mcrypt \
        php7-memcached \
        php7-mongodb \
        php7-msgpack \
        php7-mysqli \
        php7-mysqlnd \
        php7-oauth \
        php7-odbc \
        php7-opcache \
        php7-openssl \
        php7-pcntl \
        php7-pdo \
        php7-pdo_dblib \
        php7-pdo_mysql \
        php7-pdo_odbc \
        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-pear \
        php7-pgsql \
        php7-phar \
        php7-phpdbg \
        php7-posix \
        php7-pspell \
        php7-rdkafka \
        php7-redis \
        php7-session \
        php7-shmop \
        php7-snmp \
        php7-soap \
        php7-sockets \
        php7-solr \
        php7-sqlite3 \
        php7-ssh2 \
        php7-stats \
        php7-sysvmsg \
        php7-sysvsem \
        php7-sysvshm \
        php7-tidy \
        php7-timezonedb \
        php7-uuid \
        php7-wddx \
        php7-xdebug \
        php7-xml \
        php7-xmlreader \
        php7-xmlrpc \
        php7-xsl \
        php7-zip \
        php7-zlib \
        php7-zmq \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm

RUN apk add --update --no-cache \
        bash \
        curl \
        git \
        tar \
        unzip \
        vim \
        wget \
        zip

# SYMFONY
WORKDIR /tmp
RUN curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony \
    && chmod a+x /usr/local/bin/symfony

# COMPOSER
WORKDIR /tmp
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# PHPUnit
WORKDIR /tmp
RUN curl -LsS https://phar.phpunit.de/phpunit.phar -o /usr/local/bin/phpunit \
    && chmod a+x /usr/local/bin/phpunit

RUN rm -rf /tmp/* /etc/apk/cache/*

COPY symfony.ini /usr/local/etc/php/conf.d/
COPY symfony.pool.conf /usr/local/etc/php/pool.d/

EXPOSE 9000
CMD ["/usr/sbin/php-fpm7", "-F"]
