# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbra-aio-ne:10.1.11
FROM $ZIMBRAIMAGE

# Our startup scripts
COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/

# Adjust container for our use
RUN sed -i 's/systemctl restart rsyslog.service/supervisorctl restart rsyslog/' /opt/zimbra/libexec/zmsyslogsetup

# Prepare files for upgrade use (don't rely on image mount yet)
RUN mkdir -p /upgrade \
  && /usr/bin/tar cf - /opt/zimbra/conf /opt/zimbra/common/conf /opt/zimbra/data | tar -C /upgrade -xf -

# Extras

# logos
COPY --chmod=444 extras/LoginBanner.png /opt/zimbra/jetty/webapps/zimbra/skins/_base/logos/LoginBanner.png
COPY --chmod=444 extras/LoginBanner.png /opt/zimbra/jetty/webapps/zimbra/skins/_base/logos/LoginBanner_white.png
COPY --chmod=444 extras/AppBanner.png /opt/zimbra/jetty/webapps/zimbra/skins/_base/logos/AppBanner.png
COPY --chmod=444 extras/AppBanner.png /opt/zimbra/jetty/webapps/zimbra/skins/_base/logos/AppBanner_white.png

# zmstat-cleanup
COPY --chmod=444 extras/zmstat-cleanup.cron /tmp/zmstat-cleanup.cron
RUN cat /tmp/zmstat-cleanup.cron >> /opt/zimbra/conf/crontabs/crontab

# install acme script
RUN curl -sSL https://get.acme.sh | sh -

# install juicefs
RUN curl -sSL https://d.juicefs.com/install | sh -

# zmsetup
VOLUME /zmsetup
# all
VOLUME /opt/zimbra/.ssh
VOLUME /opt/zimbra/ssl
VOLUME /opt/zimbra/conf
VOLUME /opt/zimbra/data
# mta
VOLUME /opt/zimbra/common/conf
# mailbox
VOLUME /opt/zimbra/db/data
VOLUME /opt/zimbra/zimlets-deployed
VOLUME /opt/zimbra/store
VOLUME /opt/zimbra/index
VOLUME /opt/zimbra/redolog
# backup
VOLUME /opt/zimbra/backup
VOLUME /opt/zimbra/license
# onlyoffice App_Data
VOLUME /opt/zimbra/onlyoffice/documentserver/App_Data

EXPOSE 25 80 443 587 636 993 995 7071 9071
