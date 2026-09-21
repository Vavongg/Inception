FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

COPY tools/nginx_start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx_start.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx_start.sh"]