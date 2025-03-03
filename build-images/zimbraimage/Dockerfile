FROM yeak/baseimage

ARG ZCS=$ZCS

WORKDIR /root

COPY keystrokes ${ZCS}.tgz ./

RUN cat keystrokes | cut -d' ' -f1 > /tmp/keystrokes \
  && tar xf ${ZCS}.tgz \
  && cd ${ZCS} \
  && sed -i '/checkRequired/d' install.sh \
  && ./install.sh -s < /tmp/keystrokes \
  && cp -a /var/log/zimbra.log /var/log/zimbra-stats.log \
  && mv /tmp/install.log.* /opt/zimbra/log/ \
  && rm -f /tmp/install.log \
  && cd .. \
  && rm -rf ${ZCS} \
  && rm -f ${ZCS}.tgz \
  && rm -f /root/keystrokes \
  && rm -f /tmp/keystrokes

COPY --chmod=644 zimbra.ini /etc/supervisord.d/
COPY --chmod=755 start.sh /supervisor/

VOLUME /zmsetup
VOLUME /opt/zimbra/.ssh
VOLUME /opt/zimbra/conf
VOLUME /opt/zimbra/ssl
VOLUME /opt/zimbra/data
VOLUME /opt/zimbra/db/data
VOLUME /opt/zimbra/jetty_base/etc
VOLUME /opt/zimbra/zimlets-deployed
VOLUME /opt/zimbra/store
VOLUME /opt/zimbra/index
VOLUME /opt/zimbra/redolog
VOLUME /opt/zimbra/backup

EXPOSE 25
EXPOSE 80
EXPOSE 443
EXPOSE 465
EXPOSE 587
EXPOSE 993
EXPOSE 995
EXPOSE 7071
EXPOSE 9071
