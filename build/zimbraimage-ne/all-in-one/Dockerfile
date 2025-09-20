FROM yeak/osimage:rl9

ARG DOWNLOAD=$URL
ARG ZCS=$ZCS

WORKDIR /root

COPY keystrokes ./

RUN cat keystrokes | cut -d' ' -f1 > /tmp/keystrokes \
  && curl -LO ${DOWNLOAD} \
  && tar xf ${ZCS}.tgz \
  && cd ${ZCS} \
  && sed -i '/checkRequired/d' install.sh \
  && sed -i '/checkLicenseDaemonServiceRunning $LICENSE_DAEMON_SELECTED/d' util/utilfunc.sh \
  && yum install -y libreoffice libreoffice-core \
  && ./install.sh -s < /tmp/keystrokes \
  && cp -a /var/log/zimbra.log /var/log/zimbra-stats.log \
  && mv /tmp/install.log.* /opt/zimbra/log/ \
  && rm -f /tmp/install.log \
  && cd .. \
  && rm -rf ${ZCS} \
  && rm -f ${ZCS}.tgz \
  && rm -f /tmp/keystrokes

RUN sed -i 's/@@BUILD_PLATFORM@@/RHEL9_64/' /opt/zimbra/.platform

# Run Zimbra update (when VERSION is changed, a new layer is built)
ARG VERSION=1
RUN yum makecache && yum -y --disablerepo=\* --enablerepo=zimbra\* update
