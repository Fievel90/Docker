FROM alpine:latest

MAINTAINER Filippo Andrighetti <filippo.andrighetti@facile.it>

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache \
        curl \
        git \
        tar \
        unzip \
        vim \
        wget \
        zip \
        zsh

ENV SHELL=/bin/zsh
ENV TERM=xterm

RUN curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

COPY .zshrc ~/.zshrc

RUN rm -rf /tmp/* /etc/apk/cache/*

CMD ["zsh"]
