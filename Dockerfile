FROM alpine:latest

LABEL maintainer="CodFrm <love@xloli.top>"

ENV NGINX_VERSION=1.14.0 \
    MIRROR=1

WORKDIR /home

EXPOSE 80

RUN CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--user=www \
		--group=www \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_dav_module \
		--with-http_gzip_static_module" \
	&& addgroup -S www \
	&& adduser -D -H -S www www \
    && v=$(cat /etc/alpine-release) \
    && v=$(echo ${v%.*}) \
    && if [ $MIRROR -eq 1 ] ; then echo -e "https://mirrors.aliyun.com/alpine/v${v}/main/\nhttps://mirrors.aliyun.com/alpine/v${v}/community" > /etc/apk/repositories ; fi\
    && apk add --no-cache \
		gcc \
		libc-dev \
		make \
		openssl-dev \
		pcre-dev \
		zlib-dev \
    && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-1.14.0.tar.gz \
    && mv nginx-${NGINX_VERSION} nginx \
    && cd nginx \
    && ./configure $CONFIG \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /var/www/html/ \
	&& cp html/index.html /var/www/html/ \
	&& cp html/50x.html /var/www/html/ \
    && cd .. \
	&& rm -rf nginx nginx-${NGINX_VERSION}.tar.gz \
	&& apk del gcc make libc-dev

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx.default.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]