# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbra-logger:10.1.10
FROM $ZIMBRAIMAGE

# Our startup scripts
COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/

# Adjust container for our use
RUN sed -i 's/systemctl restart rsyslog.service/supervisorctl restart rsyslog/' /opt/zimbra/libexec/zmsyslogsetup

# Prepare files for upgrade use (don't rely on image mount yet)
RUN mkdir -p /upgrade \
  && /usr/bin/tar cf - /opt/zimbra/conf /opt/zimbra/common/conf /opt/zimbra/data | tar -C /upgrade -xf -

# zmsetup
VOLUME /zmsetup
# all
VOLUME /opt/zimbra/.ssh
VOLUME /opt/zimbra/ssl
VOLUME /opt/zimbra/conf
VOLUME /opt/zimbra/data
# mailbox
VOLUME /opt/zimbra/db/data
VOLUME /opt/zimbra/zimlets-deployed
VOLUME /opt/zimbra/store
VOLUME /opt/zimbra/index
VOLUME /opt/zimbra/redolog
# backup
VOLUME /opt/zimbra/backup

EXPOSE 7071

HEALTHCHECK --interval=5m --timeout=30s \
  CMD su - zimbra -c 'zmmailboxdctl status' || exit 1
