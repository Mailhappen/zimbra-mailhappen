FROM rockylinux/rockylinux:9

# Objective is to ensure all required packages are preinstalled from OS image
# so that Zimbra could use local repository

## We need Minimal Install package but this introduced back systemd
#RUN yum -y groupinstall "Minimal Install" --allowerasing
## We remove leftover systemd files which we don't need
#RUN sed -i 's/^\(-session.*pam_systemd.so.*\)/#\1/' /etc/pam.d/system-auth
#RUN rm -f /var/log/README
## We need packages from epel
#RUN yum -y install epel-release
#RUN yum -y install supervisor p7zip-plugins
## These are from OS
#RUN yum -y install chkconfig libaio libicu libnsl2 libtirpc perl-Socket6 net-tools nmap-ncat dnsutils perl sysstat sqlite tmux rsync socat
## Update to the latest
#RUN yum -y update
## Clean up
#RUN yum clean all

# Optimize result image
RUN  yum -y groupinstall "Minimal Install" --allowerasing \
  && sed -i 's/^\(-session.*pam_systemd.so.*\)/#\1/' /etc/pam.d/system-auth \
  && rm -f /var/log/README \
  && yum -y install epel-release \
  && yum -y install supervisor p7zip-plugins \
  && yum -y install chkconfig libaio libicu libnsl2 libtirpc perl-Socket6 net-tools nmap-ncat dnsutils perl sysstat sqlite tmux rsync socat \
  && yum -y update \
  && yum clean all

COPY --chmod=644 supervisord.conf /etc/supervisord.conf
COPY --chmod=644 default.ini /etc/supervisord.d/default.ini
COPY --chmod=755 supervisor/ /supervisor/
COPY --chmod=644 sysstat.cron /etc/cron.d/sysstat
COPY --chmod=755 logrotate /etc/cron.daily/logrotate
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
