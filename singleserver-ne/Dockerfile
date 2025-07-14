# All-In-One

ARG ZIMBRAIMAGE=yeak/zimbraimage-ne:10.1.9
FROM $ZIMBRAIMAGE

# Prepare for upgrade files
RUN mkdir -p /upgrade \
  && /usr/bin/cp -a /opt/zimbra/conf        /upgrade/conf \
  && /usr/bin/cp -a /opt/zimbra/data        /upgrade/data \
  && /usr/bin/cp -a /opt/zimbra/common/conf /upgrade/commonconf \
  && /usr/bin/cp -a /opt/zimbra/license     /upgrade/license

# Our startup scripts
COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/
COPY --chmod=644 zmsetup.in /root/

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
# license
VOLUME /opt/zimbra/license
# onlyoffice App_Data
VOLUME /opt/zimbra/onlyoffice/documentserver/App_Data

EXPOSE 25 80 443 587 636 993 995 7071 9071
