FROM nginx:alpine

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN apk add --update \
    bash

ADD upstream.conf /etc/nginx/conf.d/
ADD vhost/* /etc/nginx/conf.d/
