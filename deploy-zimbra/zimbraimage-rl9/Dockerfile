FROM yeak/baseimage-rl9

ARG ZCS=zcs-10.1.4_GA_1000.RHEL9_64.20241230184123

WORKDIR /root

COPY keystrokes ./

RUN cat keystrokes | cut -d' ' -f1 > /tmp/keystrokes \
  && curl -LO -C - https://minio.mailhappen.com/downloads/${ZCS}.tgz \
  && tar xf ${ZCS}.tgz \
  && cd ${ZCS} \
  && sed -i '/checkRequired/d' install.sh \
  && ./install.sh -s < /tmp/keystrokes \
  && sed -i '/postinstall::notifyZimbra/d' /opt/zimbra/libexec/zmsetup.pl \
  && mv /tmp/install.log.* /opt/zimbra/log/ \
  && cp -a /var/log/zimbra.log /var/log/zimbra-stats.log \
  && cd .. \
  && rm -rf ${ZCS} \
  && rm -f ${ZCS}.tgz \
  && rm -f /tmp/keystrokes

COPY --chmod=775 functions.sh start.sh ./
COPY --chmod=644 zimbra.ini /etc/supervisord.d/

VOLUME /data

EXPOSE 22
EXPOSE 80
EXPOSE 443
EXPOSE 25
EXPOSE 465
EXPOSE 587
EXPOSE 110
EXPOSE 143
EXPOSE 993
EXPOSE 995
EXPOSE 7071
EXPOSE 9071
