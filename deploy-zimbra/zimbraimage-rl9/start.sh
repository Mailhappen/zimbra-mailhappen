#!/bin/bash
set -x

my_hostname="$(hostname -s)"
my_domain="$(hostname -d)"
[ -z "$my_domain" ] && my_domain="zimbra.lab"
my_fqdn="$my_hostname.$my_domain"
my_admin="${DEFAULT_ADMIN:=sysadmin}"
my_password="${DEFAULT_PASSWORD:=zimbra}"
my_timezone="${TIMEZONE:=Asia/Kuala_Lumpur}"

function set_timezone() {
  if [ -f /usr/share/zoneinfo/$my_timezone ]; then
    ln -sf /usr/share/zoneinfo/$my_timezone /etc/localtime
    echo $my_timezone > /etc/timezone
  fi
}

function copyln() {
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" ] && return
  [ ! -e $source ] && /usr/bin/cp -a $target $source
  rm -rf $target && ln -s $source $target
}

function init() {
  # setup container to use data from our volumes
  # in case volume not attached, we create it
  [ ! -d /data ] && mkdir /data
  # zimbra all
  copyln /data/conf             /opt/zimbra/conf
  copyln /data/ssh              /opt/zimbra/.ssh
  copyln /data/ssl              /opt/zimbra/ssl
  copyln /data/logger           /opt/zimbra/logger
  copyln /data/zimlets-deployed /opt/zimbra/zimlets-deployed
  copyln /data/jetty-etc        /opt/zimbra/jetty_base/etc
  #copyln /data/common-jetty     /opt/zimbra/common/jetty_home
  #copyln /data/common-conf      /opt/zimbra/common/conf

  # done initialize
  touch /init.done
}

# Pause for debugging
if [ "$DEV_MODE" = "y" ]; then
  set +x
  while true
  do
    echo "Dev Mode."
    sleep 30
  done
  exit 0
fi

# Set system timezone
set_timezone

# New container
if [ ! -f /init.done ]; then
  init
fi

# NEW INSTALL
if [ ! -e /data/install_history ]; then
  cat <<EOT > /data/defaultsfile
HOSTNAME="$my_fqdn"
LDAPHOST="$my_fqdn"
AVDOMAIN="$my_fqdn"
CREATEDOMAIN="$my_fqdn"
AVUSER="$my_admin@$my_fqdn"
CREATEADMIN="$my_admin@$my_fqdn"
SMTPDEST="$my_admin@$my_fqdn"
SMTPSOURCE="$my_admin@$my_fqdn"
CREATEADMINPASS="$my_password"
EOT

  # save install history
  copyln /data/install_history /opt/zimbra/.install_history

  # run zmsetup.pl
  /opt/zimbra/libexec/zmsetup.pl -d -c /data/defaultsfile

  # keep results after configure
  /usr/bin/cp -f /opt/zimbra/config.* /data/
  /usr/bin/cp -f /opt/zimbra/config.* /data/config.zimbra
  /usr/bin/cp -f /opt/zimbra/log/zmsetup.*.log /data/


# IT IS CONFIGURED
else

  # Check if SAME or NEW image is used to start this container
  diff -DNAME /data/install_history /opt/zimbra/.install_history | awk '!/NAME/' > /tmp/c
  cmp -s /data/install_history /tmp/c
  RS=$?
  if [ $RS -ne 0 ]; then # new image (will run upgrade)
    # Bring in new image as UPGRADED
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    diff -DNAME /data/install_history /opt/zimbra/.install_history | awk '!/NAME/' > /tmp/c
    /usr/bin/cp -f /tmp/c /data/install_history
  fi

  # save install history
  copyln /data/install_history /opt/zimbra/.install_history

  # Start Zimbra if it was only stopped
  if [ -e /var/spool/cron/zimbra ]; then
    su - zimbra -c "zmcontrol start"
  else
    # run zmsetup.pl
    /opt/zimbra/libexec/zmsetup.pl -d -c /data/config.zimbra
    # keep results after configure
    /usr/bin/cp -f /opt/zimbra/config.* /data/
    /usr/bin/cp -f /opt/zimbra/config.* /data/config.zimbra
    /usr/bin/cp -f /opt/zimbra/log/zmsetup.*.log /data/
  fi
fi

# Run customizations
if [ "$CUSTOMIZE" = "y" -o "$CUSTOMIZE" = "Y" ]; then
  /root/customize.sh
fi

# Done
set +x

# Restart rsyslog
supervisorctl restart rsyslog

# Trap signal to stop zimbra
stop_zimbra () {
  su - zimbra -c "zmcontrol stop"
  exit 0
}

trap stop_zimbra SIGINT SIGTERM

while true
do
  sleep 10
done
