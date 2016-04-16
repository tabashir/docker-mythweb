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
VOLUME /home/mythtv /etc/apache2/sites-enabled

# chfn workaround - Known issue within Dockers
RUN ln -s -f /bin/true /usr/bin/chfn && \

# Set the locale
locale-gen en_GB.UTF-8 && \


# mv startup file(s) and make executable
mv /root/001-fix-the-time.sh /etc/my_init.d/001-fix-the-time.sh && \
mv /root/002-fix-the-config-etc.sh /etc/my_init.d/002-fix-the-config-etc.sh && \
mv /root/006-bring-up-mythweb.sh /etc/my_init.d/006-bring-up-mythweb.sh && \
chmod +x /etc/my_init.d/* && \

# add repos
echo "deb http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list && \
echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty multiverse" >> /etc/apt/sources.list && \
echo "deb http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list && \
echo "deb-src http://archive.ubuntu.com/ubuntu/ trusty-updates multiverse" >> /etc/apt/sources.list && \


# install dependencies
apt-get update -qq && \
apt-get install -qy \
wget \
mysql-client-5.5 \
pwgen \
sed

# RUN apt-get install -qy --ignore-missing mythtv-common 
RUN apt-get install -qy --no-install-recommends mythweb

# Configure apache
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini && \
sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini && \
mv /root/ports.conf /etc/apache2/ports.conf && \
mv /root/000-default-mythbuntu.conf /etc/apache2/sites-available/000-default-mythbuntu.conf && \
mv /root/mythweb.conf /etc/apache2/sites-available/mythweb.conf  && \

# set mythtv to uid99 and gid100
usermod -u 99 mythtv && \
usermod -g 100 mythtv && \

# create/place required files/folders
mkdir -p /home/mythtv/.mythtv /var/lib/mythtv /var/log/mythtv /root/.mythtv && \

# set a password for user mythtv and add to required groups
echo "mythtv:mythtv" | chpasswd && \
usermod -s /bin/bash -d /home/mythtv -a -G users,mythtv,adm,sudo mythtv && \

# set permissions for files/folders
chown -R mythtv:users /var/lib/mythtv /var/log/mythtv && \

# clean up
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))
