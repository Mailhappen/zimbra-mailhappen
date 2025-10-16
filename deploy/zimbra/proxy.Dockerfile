# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbra-proxy:10.1.10
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
# backup
VOLUME /opt/zimbra/backup

EXPOSE 80 443 993 995 9071
