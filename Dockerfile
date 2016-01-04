###################################
# NGINX from Source on Alpine Linux
###################################

# Base Image
FROM alpine:3.1

# Maintainer Information
MAINTAINER Marcus Schuh <mschuh@meo-tech.de>

# Change to /tmp
WORKDIR /tmp

# Environment
ENV NGINX_VER nginx-1.9.9

# Clean and Update the System
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

# Webroot 
RUN mkdir /home/www && chown -R nobody:nogroup /home/www

# additional Files
ADD nginx.conf /etc/nginx/conf/nginx.conf
COPY www /www

# forward logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

# Expose Ports
EXPOSE 80 443

# Start NGINX
CMD ["nginx"]
