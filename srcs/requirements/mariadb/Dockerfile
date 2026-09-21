FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mariadb_start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_start.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb_start.sh"]