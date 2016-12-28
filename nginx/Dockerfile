FROM alpine:latest

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache \
        bash \
        nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY upstream.conf /etc/nginx/conf.d/upstream.conf
COPY vhost/* /etc/nginx/conf.d/

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
