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

dosetup=0
containerstarted=0

# Container stop and start back up
if [ -e /var/spool/cron/zimbra ]; then
  su - zimbra -c "zmcontrol start"
  containerstarted=1
fi

# New install
if [ ! -e /zmsetup/install_history ]; then
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
  dosetup=1

# New image version
else
  v=$(sed -nE 's/.*zimbra-core-([0-9.]+_.*)\.rpm$/\1/p' /opt/zimbra/.install_history | tail -1)
  grep -q "zimbra-core-$v" /zmsetup/install_history
  RS=$?
  if [ $RS -ne 0 ]; then
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    cat /opt/zimbra/.install_history >> /zmsetup/install_history
<<<<<<< HEAD
<<<<<<< HEAD
    /usr/bin/rsync -av -u /upgrade/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
    /usr/bin/rsync -av -u /upgrade/data/ /opt/zimbra/data/
    /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
=======
    /usr/bin/rsync -av -u --exclude localconfig.xml /upgrade/conf/ /opt/zimbra/conf/
    /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
    /usr/bin/rsync -av -u /upgrade/jettyetc/ /opt/zimbra/jetty_base/etc/
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======
    /usr/bin/rsync -av -u /upgrade/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
    /usr/bin/rsync -av -u /upgrade/data/ /opt/zimbra/data/
    /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
>>>>>>> 570229c (Just clean up and simplify a bit.)
    dosetup=1
  fi
fi 

# We start it our way
if [ $dosetup -eq 0 -a $containerstarted -ne 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history
  # restore OS files (note: changes will not get retain)
  /usr/bin/cp -af /zmsetup/cron.zimbra /var/spool/cron/zimbra
  /usr/bin/cp -af /zmsetup/logrotate.zimbra /etc/logrotate.d/zimbra
  /usr/bin/cp -af /zmsetup/rsyslog.conf /etc/rsyslog.conf 
<<<<<<< HEAD
<<<<<<< HEAD
  su - zimbra -c "zmcertmgr addcacert /opt/zimbra/conf/ca/ca.pem"
=======
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======
  su - zimbra -c "zmcertmgr addcacert /opt/zimbra/conf/ca/ca.pem"
>>>>>>> 62bd0da (Missing the addcacert)
  su - zimbra -c "zmcertmgr deploycrt self"
  su - zimbra -c "ldap start"
  cd /opt/zimbra/common/jetty_home/resources && ln -sf /opt/zimbra/jetty_base/etc/jetty-logging.properties && cd -
  /opt/zimbra/common/sbin/newaliases
  su - zimbra -c "libexec/zmloggerinit"
  su - zimbra -c "zmcontrol restart"
fi

# Do setup for new install and upgrade
if [ $dosetup -eq 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -c /zmsetup/config.zimbra

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
<<<<<<< HEAD
<<<<<<< HEAD
#adjust_memory_size ${MAX_MEMORY_GB:=8}
=======
adjust_memory_size ${MAX_MEMORY_GB:=8}
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======
#adjust_memory_size ${MAX_MEMORY_GB:=8}
>>>>>>> 3e77005 (Update changes include juicefs and cleanups)

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
  su - zimbra -c "zmcontrol stop"
  exit 0
}

trap stop_zimbra SIGINT SIGTERM

while true
do
  sleep 60
done

