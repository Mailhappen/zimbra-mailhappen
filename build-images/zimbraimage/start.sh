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

# New install
if [ ! -e /zmsetup/install_history ]; then
  copyln /zmsetup/install_history /opt/zimbra/.install_history
fi

# New config for new setup
if [ ! -e /zmsetup/config.zimbra ]; then
  cat <<EOT > /zmsetup/config.zimbra
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
  v=$(sed -nE 's/.*zimbra-core-([0-9.]+_.*)\.rpm$/\1/p' /opt/zimbra/.install_history | tail -1)
  grep -q "zimbra-core-$v" /zmsetup/install_history
  RS=$?
  if [ $RS -ne 0 ]; then
    # New version. This will be an UPGRADE
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    cat /opt/zimbra/.install_history >> /zmsetup/install_history
  fi

  # save and keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -c /zmsetup/config.zimbra

  # tune the container RAM usage to 8GB by default
  adjust_memory_size ${MAX_MEMORY_GB:=8}

  # keep results after configure
  /usr/bin/cp -f /opt/zimbra/config.* /zmsetup/
  /usr/bin/cp -f /opt/zimbra/config.* /zmsetup/config.zimbra
  /usr/bin/cp -f /opt/zimbra/log/zmsetup.*.log /zmsetup/

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

