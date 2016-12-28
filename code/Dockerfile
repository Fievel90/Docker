FROM alpine:latest

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache \
        bash

VOLUME /var/www

CMD ["/bin/bash"]
