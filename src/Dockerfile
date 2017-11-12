#
# Docker file for running Diladele Web Safety in one container
# Use buster (testing) as base
FROM arm32v7/debian:buster

MAINTAINER support@diladele.com

# set configuration variables
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# install apt-utils (not part of the base image) and enable source repository for Squid installation
RUN echo "deb-src http://security.debian.org jessie/updates main" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils 
# install python libs and apache with modwsgi
RUN apt-get install -y --no-install-recommends apache2 \
            libapache2-mod-wsgi \
            python-ldap	\
            sudo \
            python-openssl \
            krb5-user \
            sqlite \ 
	    wget && \
    a2dissite 000-default 
    
# installk GPG keys
RUN wget http://packages.diladele.com/diladele_pub.asc -O diladele_pub.asc && apt-key add diladele_pub.asc && rm diladele_pub.asc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install reportlab and pillow via updated binary packages
RUN apt-get update && apt-get install -y --no-install-recommends python-pip python-pil python-reportlab
RUN pip install --upgrade pip && \
    pip install django==1.8.17 && \
    pip install pytz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
RUN apt-get update && apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev python-dev

# install build tools
RUN apt-get -y install devscripts build-essential fakeroot debhelper dh-autoreconf cdbs

RUN apt-get remove -y --auto-remove python-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install build tools and build squid

# install build dependences for squid
RUN apt-get -y build-dep squid

# install additional packages for squid 3.5.23 (see http://squid-web-proxy-cache.1019090.n4.nabble.com/Build-errors-with-Squid-3-5-24-under-Debian-td4681637.html)
RUN apt-get -y install libdbi-perl libssl1.0-dev

# drop squid3 build folder
RUN rm -R /tmp/build/squid3

# we will be working in a subfolder make it
RUN mkdir -p /tmp/build/squid3

# copy the patch to the working folder
COPY contents/rules.patch build/squid3/rules.patch

# decend into working directory
RUN pushd /tmp/build/squid3

# get squid3 from debian stretch
RUN wget http://http.debian.net/debian/pool/main/s/squid3/squid3_3.5.23-5.dsc
RUN wget http://http.debian.net/debian/pool/main/s/squid3/squid3_3.5.23.orig.tar.gz
RUN wget http://http.debian.net/debian/pool/main/s/squid3/squid3_3.5.23-5.debian.tar.xz

# unpack the source package
RUN dpkg-source -x squid3_3.5.23-5.dsc

# modify configure options in debian/rules, add --enable-ssl --enable-ssl-crtd and --with-openssl
RUN patch squid3-3.5.23/debian/rules < rules.patch

# build the package
RUN cd squid3-3.5.23 && dpkg-buildpackage -rfakeroot -b

# and revert
RUN popd

RUN apt-get update && apt-get install -y --no-install-recommends \
            libecap3 && \
    rm -rf /var/run/squid.pid && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install some more required packages
RUN apt-get -y install squid-langpack

# decend into working directory
RUN pushd /tmp/build/squid3

# install squid packages
RUN dpkg --install squid-common_3.5.23-5_all.deb
RUN dpkg --install squid_3.5.23-5_${ARCH}.deb
RUN dpkg --install squidclient_3.5.23-5_${ARCH}.deb

# and revert
RUN popd

# put the squid on hold to prevent updating
RUN apt-mark hold squid squid-common
# Get latest web safety and install it
# Update the DDWS_VER if needed
ENV DDWS_VER 5.2.0.210A
ENV ARCH armhf

RUN wget http://packages.diladele.com/websafety/${DDWS_VER}/amd64/release/ubuntu16/websafety-${DDWS_VER}_$ARCH.deb -O websafety-${DDWS_VER}_$ARCH.deb  && \
	dpkg --install websafety-${DDWS_VER}_$ARCH.deb && \
	rm -f websafety-${DDWS_VER}_$ARCH.deb && \
	a2ensite websafety && \
	mkdir -p /var/log/websafety

# too many hardlinks in phusion-basimage for crontab
RUN touch /etc/crontab

# make runit service directories
RUN mkdir /etc/service/squid /etc/service/apache2 /etc/service/wsicap /etc/service/wsmgr /etc/service/wssyncw/ /opt/websafety/bin/certmgr

# copy required files
COPY contents/squid.conf /etc/squid/squid.conf
COPY contents/websafety_update /etc/cron.daily
COPY contents/wsicap /etc/service/wsicap/run
COPY contents/wsmgr /etc/service/wsmgr/run
COPY contents/wssyncw /etc/service/wssyncw/run
COPY contents/squid /etc/service/squid/run
COPY contents/apache2 /etc/service/apache2/run
COPY contents/reload.sh /opt/websafety/bin/reload.sh
COPY contents/restart.sh /opt/websafety/bin/restart.sh
COPY contents/system.json /opt/websafety/etc/system.json
COPY contents/license.pem /opt/websafety/etc/license.pem
COPY contents/firstrun.sh /usr/local/bin/firstrun.sh

# reset owner of installation path
RUN chown -R websafety:websafety /opt/websafety && \
    chmod +x /opt/websafety/bin/* && \
    chmod +x /usr/local/bin/firstrun.sh && \
    chmod +x /etc/cron.daily/websafety_update && \
    chmod u+s /opt/websafety/bin/* && \
    chmod 755 /opt/websafety/bin/certmgr && \
    chmod 755 /opt/websafety/bin/report && \
    chmod +x /etc/service/squid/run \
		/etc/service/wsmgr/run \
		/etc/service/wssyncw/run \
		/etc/service/wsicap/run \
		/etc/service/apache2/run

# expose ports
EXPOSE 80 3126 3127 3128 18889 18999

# assign volumes
VOLUME ["/opt/websafety/etc"]
VOLUME ["/opt/websafety/var/spool"]
VOLUME ["/opt/websafety/var/console"]
VOLUME ["/opt/websafety/var/db"]
VOLUME ["/opt/websafety/var/log"]
VOLUME ["/opt/websafety/var/reports"]
VOLUME ["/etc/squid"]
VOLUME ["/var/spool"]
VOLUME ["/var/log/squid"]

CMD ["/sbin/my_init"]
