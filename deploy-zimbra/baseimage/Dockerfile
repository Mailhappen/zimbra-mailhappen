FROM rockylinux/rockylinux:9

# Testing use
#RUN yum groupinstall -y "Minimal Install" --allowerasing
#RUN yum install -y chkconfig libaio libicu libnsl2 libtirpc perl-Socket6
#RUN yum install -y net-tools nmap-ncat dnsutils perl sysstat sqlite tmux
#RUN yum install -y epel-release
#RUN yum install -y supervisor
#RUN yum update -y
#RUN yum clean all

# For real to opimize image
RUN  yum groupinstall -y "Minimal Install" --allowerasing \
  && yum install -y chkconfig libaio libicu libnsl2 libtirpc perl-Socket6 \
  && yum install -y net-tools nmap-ncat dnsutils perl sysstat sqlite tmux \
  && yum install -y epel-release \
  && yum install -y supervisor p7zip-plugins \
  && yum update -y \
  && yum clean all

COPY --chmod=644 supervisord.conf /etc/supervisord.conf
COPY --chmod=644 default.ini /etc/supervisord.d/default.ini
COPY --chmod=775 supervisor/ /supervisor/
COPY --chmod=644 sysstat.cron /etc/cron.d/sysstat

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
