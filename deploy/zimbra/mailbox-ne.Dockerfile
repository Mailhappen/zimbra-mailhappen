# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbra-mailbox-ne:10.1.11
FROM $ZIMBRAIMAGE

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
# mailbox
VOLUME /opt/zimbra/db/data
VOLUME /opt/zimbra/zimlets-deployed
VOLUME /opt/zimbra/store
VOLUME /opt/zimbra/index
VOLUME /opt/zimbra/redolog
# backup
VOLUME /opt/zimbra/backup

EXPOSE 7071
