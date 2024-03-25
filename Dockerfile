# syntax=docker/dockerfile:1
FROM debian:11 as builder
ARG SETUP_1C_FILE=setup-full-8.3.23.2040-x86_64.run # Установочный файл платфоры 1c для linux
WORKDIR /tmp
COPY $SETUP_1C_FILE $SETUP_1C_FILE
RUN apt-get update && apt-get upgrade -y && \
  chmod +x /tmp/$SETUP_1C_FILE && \
  echo "install 1c" && \
	echo "/tmp/$SETUP_1C_FILE --installer-language en --mode unattended --enable-components ws" && \
	/tmp/$SETUP_1C_FILE --installer-language en --mode unattended --enable-components ws

FROM debian:11
ARG USER=1000 # UID пользователя с полными правами доступа к директории с базами 1C
ARG GROUP=1000 # GUID пользователя с полными правами доступа к директории с базами 1C
WORKDIR /tmp
COPY --from=builder /opt /opt
COPY publish1c.sh /opt/
COPY nethasp.ini /opt/
ENV APACHE_RUN_DIR=/var/apache/rundir
ENV APACHE_RUN_USER=root
ENV APACHE_RUN_GROUP=root
ENV APACHE_LOG_DIR=/var/apache/log
ENV APACHE_PID_FILE=/var/apache/httpd.pid
RUN apt-get update && apt-get upgrade -y && \
	apt-get install software-properties-common -y && \
	apt-add-repository contrib -y && \
	apt-add-repository non-free -y && \
	apt-get update && \
  apt install python3-certbot-apache -y && \
	apt install ttf-mscorefonts-installer -y && \
  apt install fontconfig -y && \
  fc-cache -fv && \
	apt-get install -y apache2 && \
	rm -rf /var/lib/apt/lists/* && \
	usermod -u $USER www-data && \
	groupmod -g $GROUP www-data
CMD ["/opt/publish1c.sh"]
EXPOSE 80
