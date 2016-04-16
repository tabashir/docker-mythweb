FROM phusion/baseimage:0.9.16

# Set correct environment variables
ENV DEBIAN_FRONTEND=noninteractive HOME="/root" TERM=xterm LANG=en_GB.UTF-8 LANGUAGE=en_GB:en LC_ALL=en_GB.UTF-8 APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data APACHE_LOG_DIR="/var/log/apache2" APACHE_LOCK_DIR="/var/lock/apache2" APACHE_PID_FILE="/var/run/apache2.pid"
CMD ["/sbin/my_init"]


# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Expose ports
EXPOSE 50050

# Add local files
ADD src/ /root/

# set volumes
VOLUME /home/mythtv 

# chfn workaround - Known issue within Dockers
RUN ln -s -f /bin/true /usr/bin/chfn

# Set the locale
RUN locale-gen en_GB.UTF-8


# mv startup file(s) and make executable
RUN mv /root/001-fix-the-time.sh /etc/my_init.d/001-fix-the-time.sh
RUN mv /root/002-fix-the-config-etc.sh /etc/my_init.d/002-fix-the-config-etc.sh
RUN mv /root/006-bring-up-mythweb.sh /etc/my_init.d/006-bring-up-mythweb.sh
RUN chmod +x /etc/my_init.d/*

# add repos
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list


# install dependencies
RUN apt-get update -qq
RUN apt-get install -qy \
wget \
mysql-client-5.5 \
pwgen \
sed

# RUN apt-get install -qy --ignore-missing mythtv-common 
RUN apt-get install -qy mythweb

# Configure apache
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini
RUN mv /root/ports.conf /etc/apache2/ports.conf
RUN mv /root/000-default-mythbuntu.conf /etc/apache2/sites-available/000-default-mythbuntu.conf
RUN mv /root/mythweb.conf /etc/apache2/sites-available/mythweb.conf 
RUN mv /root/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf 

# set mythtv to uid99 and gid100
RUN usermod -u 99 mythtv
RUN usermod -g 100 mythtv

# create/place required files/folders
RUN mkdir -p /home/mythtv/.mythtv /var/lib/mythtv /var/log/mythtv /root/.mythtv

# set a password for user mythtv and add to required groups
RUN echo "mythtv:mythtv" | chpasswd
RUN usermod -s /bin/bash -d /home/mythtv -a -G users,mythtv,adm,sudo mythtv

# set permissions for files/folders
RUN chown -R mythtv:users /var/lib/mythtv /var/log/mythtv

# clean up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))
