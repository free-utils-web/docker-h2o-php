FROM alpine:edge as fetcher
ENV URL https://github.com/h2o/h2o.git
ENV H2O_VERSION master
RUN apk update \
    && apk upgrade --available \
    && sync \
    && apk add -U git \
    && git clone --recursive $URL h2o -b $H2O_VERSION

FROM alpine:edge as builder
RUN apk update \
    && apk upgrade --available \
    && sync
RUN apk add -U build-base \
    ca-certificates \
    cmake \
    linux-headers \
    openssl-dev \
    perl \
    zlib-dev \
    ruby-dev \
    bison \
    wslay-dev \
    libuv-dev \
    ruby-rake \
    brotli-dev \
    libcap-dev \
    bcc-dev \
    libconfig-dev \
    gnu-libiconv-dev
COPY --from=fetcher /h2o /h2o
RUN mkdir /h2o/output
WORKDIR /h2o/output
# build h2o
RUN cmake -DWITH_BUNDLED_SSL=on -DWITH_MRUBY=on .. \
    && make -j$(($(nproc)*9/10)) \
    && make install \
    && h2o -v

FROM alpine:edge
LABEL authors="Lars K.W. Gohlke <lkwg82@gmx.de>, Tatsuya Fukata <tatsuya.fukata@gmail.com>"
RUN apk update \
    && apk upgrade --available \
    && sync
# need for ocsp stapling
RUN apk add -U --no-cache openssl perl libcap
# install php
RUN apk add -U --no-cache \
    libzip \
    libwebp \
    composer \
    php81-pecl-redis \
    php-pdo_mysql \
    php-pdo_pgsql \
    php81-pecl-memcached \
    php-dom \
    php-ctype \
    php-cgi \
    php-gd \
    php-intl \
    php-mysqli \
    php-opcache \
    php-posix \
    php-xml \
    php-fileinfo \
    php-xmlwriter \
    php-tokenizer
RUN mv /etc/php81/conf.d/00_iconv.ini /home/
RUN php -v
RUN addgroup h2o \
    && adduser -G h2o -D h2o
WORKDIR /home/h2o
USER h2o
COPY h2o/h2o.conf /home/h2o/
COPY refs/docker-image-h2o-php/examples/www /var/
COPY --from=builder /usr/local/bin/h2o /usr/local/bin
COPY --from=builder /usr/local/share/h2o /usr/local/share/h2o
EXPOSE 8012 8014
# some self tests
RUN h2o -v \
    && h2o --conf h2o.conf --test

CMD h2o -m master -c h2o.conf
