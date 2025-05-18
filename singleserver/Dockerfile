# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbraimage:10.1.7
FROM $ZIMBRAIMAGE

# Prepare for upgrade files
RUN mkdir -p /upgrade \
  && /usr/bin/cp -a /opt/zimbra/conf        /upgrade/conf \
  && /usr/bin/cp -a /opt/zimbra/data        /upgrade/data \
  && /usr/bin/cp -a /opt/zimbra/common/conf /upgrade/commonconf

# Our startup scripts
COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/

# zmsetup
VOLUME /zmsetup
# all
VOLUME /opt/zimbra/.ssh
VOLUME /opt/zimbra/ssl
VOLUME /opt/zimbra/conf
# ldap
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

EXPOSE 25 80 443 465 587 636 993 995 7071 9071
