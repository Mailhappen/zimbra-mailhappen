#!/bin/bash
#set -x

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
  # we copy what we don't have
  # and always override what we have to the target
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" ] && return
  [ ! -e $source ] && /usr/bin/cp -a $target $source
  rm -rf $target && ln -s $source $target
}

function init_data() {
  # setup container to use data from our volumes
  # in case volume not attached, we create it
  [ ! -d /data ] && mkdir /data
  # items we shall keep track in /data volume
  copyln /data/conf             /opt/zimbra/conf
  copyln /data/ssh              /opt/zimbra/.ssh
  copyln /data/ssl              /opt/zimbra/ssl
  copyln /data/logger           /opt/zimbra/logger
  copyln /data/zimlets-deployed /opt/zimbra/zimlets-deployed
  copyln /data/jetty-etc        /opt/zimbra/jetty_base/etc
  #copyln /data/common-jetty     /opt/zimbra/common/jetty_home
  #copyln /data/common-conf      /opt/zimbra/common/conf

  # done initialize
  touch /init_data.done
}

function adjust_memory_size() {
  # size must be 4 and above. Default 8
  size=$1
  [ -z $size ] && size=8
  [ $size -lt 4 ] && size=4
  if [ $size -ge 16 ]; then
    memory=$(($size*1024/5))
  else
    memory=$(($size*1024/4))
  fi
  su - zimbra -c "zmlocalconfig -e mailboxd_java_heap_size=$memory"
  # mysql always use 30 percent
  memKB=$(($size * 1024 * 1024))
  ((bufferPoolSize=memKB * 1024 * 30 / 100))
  sed -i "s/^innodb_buffer_pool_size.*/innodb_buffer_pool_size = $bufferPoolSize/" /opt/zimbra/conf/my.cnf
}

function zmstat_cleanup_crontab() {
  crontab -u zimbra -l > /tmp/cron.zimbra
  grep -q zmstat-cleanup /tmp/cron.zimbra
  RS=$?
  [ $RS -eq 0 ] && return 0
  cat >> /tmp/cron.zimbra <<EOT
#
# zmstat_cleanup
#
15 0 * * 7 /opt/zimbra/libexec/zmstat-cleanup -k 30
EOT
  crontab -u zimbra /tmp/cron.zimbra
}

# Pause for debugging
if [ "$DEV_MODE" = "y" ]; then
  while true
  do
    echo "Dev Mode."
    sleep 30
  done
  exit 0
fi

# Set system timezone
set_timezone

# Prepare /data volume
if [ ! -f /init_data.done ]; then
  init_data
fi

# Totally new install
if [ ! -e /data/install_history ]; then
  copyln /data/install_history /opt/zimbra/.install_history
fi

# New config for new setup
if [ ! -e /data/config.zimbra ]; then
  cat <<EOT > /data/config.zimbra
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
fi

#
# Ready to setup Zimbra
# 

if [ ! -e /var/spool/cron/zimbra ]; then

  # check if the SAME or NEW image is used
  diff -DNAME /data/install_history /opt/zimbra/.install_history | awk '!/NAME/' > /tmp/c
  cmp -s /data/install_history /tmp/c
  RS=$?
  if [ $RS -ne 0 ]; then
    # New image. This will be an UPGRADE; Merge it into our install_history
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    diff -DNAME /data/install_history /opt/zimbra/.install_history | awk '!/NAME/' > /tmp/c
    /usr/bin/cp -f /tmp/c /data/install_history
  fi

  # save and keep track of .install_history
  copyln /data/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -d -c /data/config.zimbra

  # tune the container RAM usage to 8GB by default
  adjust_memory_size ${MAX_MEMORY_GB:=8}

  # add zmstat cleanup crontab
  zmstat_cleanup_crontab

  # keep results after configure
  /usr/bin/cp -f /opt/zimbra/config.* /data/
  /usr/bin/cp -f /opt/zimbra/config.* /data/config.zimbra
  /usr/bin/cp -f /opt/zimbra/log/zmsetup.*.log /data/

  # Apply customizations

  # If this dir exist mean we got scripts to run (inspired by run-parts)
  if [ -d /custom ]; then
    for i in $(LC_ALL=C; echo /custom/*[^~,]); do
      [ -d ${i} ] && continue
      # Don't run *.{rpmsave,rpmorig,rpmnew,swp,cfsaved} scripts
      [ "${i%.cfsaved}" != "${i}" ] && continue
      [ "${i%.rpmsave}" != "${i}" ] && continue
      [ "${i%.rpmorig}" != "${i}" ] && continue
      [ "${i%.rpmnew}" != "${i}" ] && continue
      [ "${i%.swp}" != "${i}" ] && continue
      [ "${i%,v}" != "${i}" ] && continue

      if [ -x ${i} ]; then
        echo "starting $(basename ${i})"
        ${i} 2>&1
        echo "finished $(basename ${i})"
      fi
    done
  fi

else
  # existing container that was stopped; simply start up zimbra
  su - zimbra -c "zmcontrol start"
fi

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

