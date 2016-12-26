FROM php:fpm-alpine

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN apk add --update --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
    && apk add --update --no-cache \
        curl-dev \
        freetype-dev \
        icu-dev \
        imap-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libxslt-dev \
        openldap-dev \
        zlib-dev \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j${NPROC} \
        bcmath \
        calendar \
        gd \
        imap \
        intl \
        ldap \
        mcrypt \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        phar \
        soap \
        sockets \
        xsl \
        zip \
    && pecl install redis-3.1.0 xdebug-2.5.0 \
    && docker-php-ext-enable redis xdebug \
    && apk del .build-deps

ADD symfony.ini /usr/local/etc/php/conf.d/
ADD symfony.pool.conf /usr/local/etc/php/pool.d/

RUN apk add --update --no-cache \
    bash \
    curl \
    git \
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
