###################################
# NGINX from Source on Alpine Linux
###################################

# base
FROM alpine:latest

# maintainer
MAINTAINER Marcus Schuh <mschuh@meo-tech.de>

# change to /tmp
WORKDIR /tmp

# environment
ENV NGINX_VER nginx-1.13.6

# update & install essentials
RUN apk --update add wget build-base pcre-dev zlib-dev openssl-dev

# NGINX Source
RUN wget http://nginx.org/download/${NGINX_VER}.tar.gz && \
    tar -zxvf ${NGINX_VER}.tar.gz && \
    rm -rf ${NGINX_VER}.tar.gz && \
    cd ${NGINX_VER} && \
    ./configure \
    	--with-http_ssl_module \
    	--with-http_gzip_static_module \
    	--with-http_v2_module \
    	--prefix=/etc/nginx \
    	--http-log-path=/var/log/nginx/access.log \
    	--error-log-path=/var/log/nginx/error.log \
    	--sbin-path=/usr/local/sbin/nginx && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/${NGINX_VER} && \
    rm -rf /var/cache/apk/*

# additional Files
ADD nginx.conf /etc/nginx/conf/nginx.conf

# adding webroot 
RUN mkdir /www && chown -R nobody:nogroup /www
COPY www /www

# add volume for external mounting
VOLUME /www

# forward logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# expose ports
EXPOSE 80 443

# start NGINX
CMD ["nginx"]
