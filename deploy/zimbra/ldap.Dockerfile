# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbra-ldap:10.1.10
FROM $ZIMBRAIMAGE

# Prepare for upgrade files
RUN mkdir -p /upgrade \
  && /usr/bin/cp -a /opt/zimbra/conf        /upgrade/conf \
  && /usr/bin/cp -a /opt/zimbra/data        /upgrade/data

# Our startup scripts
COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/

# Adjust container for our use
RUN sed -i 's/systemctl restart rsyslog.service/supervisorctl restart rsyslog/' /opt/zimbra/libexec/zmsyslogsetup

# zmsetup
VOLUME /zmsetup
# all
VOLUME /opt/zimbra/.ssh
VOLUME /opt/zimbra/ssl
VOLUME /opt/zimbra/conf
VOLUME /opt/zimbra/data
# backup
VOLUME /opt/zimbra/backup

EXPOSE 636
