#!/bin/bash
set -x

# Set OS timezone
timezone="${TIMEZONE:=Asia/Kuala_Lumpur}"
if [ -f /usr/share/zoneinfo/$timezone ]; then
  ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
  echo $timezone > /etc/timezone
fi

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
  echo "Dev Mode"
  while true; do sleep 60; done
  exit 0
fi

#
# Main
#

runzmsetup=0
containerstarted=0

# Existing container stop and start back up
if [ -e /var/spool/cron/zimbra ]; then
  /etc/init.d/zimbra start
  containerstarted=1
fi

# New container with new data - New Install
if [ ! -e /zmsetup/install_history ]; then
  source /run/secrets/config.secrets
  echo 'cat <<EOT'     >  /tmp/temp.sh
  cat /config.defaults >> /tmp/temp.sh
  echo 'EOT'           >> /tmp/temp.sh
  bash /tmp/temp.sh > /zmsetup/config.zimbra
  rm -f /tmp/temp.sh
  runzmsetup=1

# New container with existing data
else
  # Check if the same or different image version is used
  v=$(sed -nE 's/.*zimbra-core-([0-9.]+_.*)\.rpm$/\1/p' /opt/zimbra/.install_history | tail -1)
  grep -q "zimbra-core-$v" /zmsetup/install_history
  RS=$?
  if [ $RS -ne 0 ]; then # different image version is used - assume Upgrade
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    cat /opt/zimbra/.install_history >> /zmsetup/install_history
    /usr/bin/rsync -av -u /upgrade/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
    /usr/bin/rsync -av -u /upgrade/data/ /opt/zimbra/data/
    [ -d /opt/zimbra/common/conf ] && /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
    [ -d /opt/zimbra/license ] && /usr/bin/rsync -av -u /upgrade/license/ /opt/zimbra/license/
    runzmsetup=1
  fi
fi 

# We start it our way for same image and existing data (quicker to start)
if [ $runzmsetup -eq 0 -a $containerstarted -ne 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history
  # restore OS files (note: changes will not get retain)
  /usr/bin/cp -af /zmsetup/cron.zimbra /var/spool/cron/zimbra
  /usr/bin/cp -af /zmsetup/logrotate.zimbra /etc/logrotate.d/zimbra
  /usr/bin/cp -af /zmsetup/rsyslog.conf /etc/rsyslog.conf 
  su - zimbra -c "zmcertmgr addcacert /opt/zimbra/conf/ca/ca.pem"
  su - zimbra -c "zmcertmgr deploycrt self"
  su - zimbra -c "ldap start"
  LOGHOST=$(su - zimbra -c 'zmprov -m -l gcf zimbraLogHostname' | awk '{print $2}');
  [ "$LOGHOST" == "$HOSTNAME" ] && su - zimbra -c "libexec/zmloggerinit"
  [ -d /opt/zimbra/common/jetty_home/resources ] && \
    cd /opt/zimbra/common/jetty_home/resources && \
    ln -sf /opt/zimbra/jetty_base/etc/jetty-logging.properties && \
    cd -
  [ -x /opt/zimbra/common/sbin/newaliases ] && \
    /opt/zimbra/common/sbin/newaliases
  [ -x /opt/zimbra/onlyoffice/bin/zmonlyofficeconfig ] && \
    /opt/zimbra/onlyoffice/bin/zmonlyofficeconfig
  /etc/init.d/zimbra restart
fi

# Run zmsetup for New Install and Upgrade
if [ $runzmsetup -eq 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -c /zmsetup/config.zimbra

  # set public service hostname
  su - zimbra -c "zmprov mcf zimbraPublicServiceProtocol https zimbraPublicServiceHostname $PUBLIC_SERVICE_HOSTNAME zimbraPublicServicePort 443"

  # onlyoffice App_Data
  [ -d /opt/zimbra/onlyoffice/documentserver/App_Data ] && install -o zimbra -g zimbra -m 750 -d /opt/zimbra/onlyoffice/documentserver/App_Data

  # keep results after configure
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/config.zimbra
  /usr/bin/cp -af /opt/zimbra/log/zmsetup.*.log /zmsetup/
 
  # save OS files for quick restore
  /usr/bin/cp -af /var/spool/cron/zimbra /zmsetup/cron.zimbra
  /usr/bin/cp -af /etc/logrotate.d/zimbra /zmsetup/logrotate.zimbra
  /usr/bin/cp -af /etc/rsyslog.conf /zmsetup/rsyslog.conf

fi

# Post Setup

# tune the container RAM usage to 8GB by default
adjust_memory_size ${MAX_MEMORY_GB:=8}

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

# Restart rsyslog
supervisorctl restart rsyslog

# Trap signal to stop zimbra
stop_zimbra () {
  /etc/init.d/zimbra stop
  exit 0
}

trap stop_zimbra SIGINT SIGTERM

while true
do
  sleep 3600
done

