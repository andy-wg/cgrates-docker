FROM debian:9
MAINTAINER Lorenzo Mangani, lorenzo.mangani@gmail.com

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV GOROOT /root/go
ENV GOPATH /root/code

ENV MYSQL_MAJOR 5.7

# set mysql password
RUN echo "Installing... " \

# install golang
&& apt update && apt install -y wget curl gnupg2 \
&& wget -qO- https://storage.googleapis.com/golang/go1.13.linux-amd64.tar.gz | tar xzf - -C /root/ \

# MySQL
&& groupadd -r mysql && useradd -r -g mysql mysql \
&& mkdir /docker-entrypoint-initdb.d \
&& apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 \
&& echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list \
&& apt-get update && apt-get install -y default-mysql-server libmysqlclient-dev \
	&& sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
	&& echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
	&& mv /tmp/my.cnf /etc/mysql/my.cnf \

# install cgrates
&& wget -O - http://apt.cgrates.org/apt.cgrates.org.gpg.key | apt-key add - \
&& echo "deb http://apt.cgrates.org/debian/ nightly main" | tee /etc/apt/sources.list.d/cgrates.list \
&& apt-get update && apt-get install -y cgrates redis-server \

# cleanup
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

EXPOSE 2012 

# set start command
ENTRYPOINT ["/opt/entrypoint.sh"]
