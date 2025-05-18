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

function backup_config() {
  # backup post setup files so that we can restore and start up ourselves
  mkdir -p /zmsetup/backup
  # zimbra config files
  /usr/bin/cp -af /opt/zimbra/conf/localconfig.xml    /zmsetup/backup/localconfig.xml
  /usr/bin/cp -af /opt/zimbra/conf/dhparam.pem        /zmsetup/backup/dhparam.pem
  /usr/bin/cp -af /opt/zimbra/jetty_base/etc/keystore /zmsetup/backup/keystore
  /usr/bin/cp -af /opt/zimbra/conf/my.cnf             /zmsetup/backup/my.cnf
  /usr/bin/cp -af /opt/zimbra/conf/zimbra.ldif        /zmsetup/backup/zimbra.ldif
  /usr/bin/cp -af /opt/zimbra/conf/zmssl.cnf          /zmsetup/backup/zmssl.cnf
  # postinstall files
  /usr/bin/cp -af /var/spool/cron/zimbra              /zmsetup/backup/cron.zimbra
  /usr/bin/cp -af /etc/logrotate.d/zimbra             /zmsetup/backup/logrotate.zimbra
  /usr/bin/cp -af /etc/rsyslog.conf                   /zmsetup/backup/rsyslog.conf
}

function restore_config() {
  # restore zimbra config files
  cp -af /zmsetup/backup/localconfig.xml             /opt/zimbra/conf/localconfig.xml
  cp -af /zmsetup/backup/dhparam.pem                 /opt/zimbra/conf/dhparam.pem
  cp -af /zmsetup/backup/keystore                    /opt/zimbra/jetty_base/etc/keystore
  cp -af /zmsetup/backup/my.cnf                      /opt/zimbra/conf/my.cnf
  cp -af /zmsetup/backup/zimbra.ldif                 /opt/zimbra/conf/zimbra.ldif
  cp -af /zmsetup/backup/zmssl.cnf                   /opt/zimbra/conf/zmssl.cnf
  # postinstall files
  cp -af /zmsetup/backup/cron.zimbra                 /var/spool/cron/zimbra
  cp -af /zmsetup/backup/logrotate.zimbra            /etc/logrotate.d/zimbra
  cp -af /zmsetup/backup/rsyslog.conf                /etc/rsyslog.conf
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

<<<<<<< HEAD
dosetup=0
containerstarted=0
=======
dosetup=1
cleanstart=0
>>>>>>> 49bbdca (New improved start.sh.)

# Container stop and start back up
if [ -e /var/spool/cron/zimbra ]; then
  su - zimbra -c "zmcontrol start"
<<<<<<< HEAD
  containerstarted=1
=======
  cleanstart=1
  dosetup=0
>>>>>>> 49bbdca (New improved start.sh.)
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
<<<<<<< HEAD
  dosetup=1
=======
>>>>>>> 49bbdca (New improved start.sh.)

# New image version
else
  v=$(sed -nE 's/.*zimbra-core-([0-9.]+_.*)\.rpm$/\1/p' /opt/zimbra/.install_history | tail -1)
  grep -q "zimbra-core-$v" /zmsetup/install_history
  RS=$?
  if [ $RS -ne 0 ]; then
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    cat /opt/zimbra/.install_history >> /zmsetup/install_history
<<<<<<< HEAD
    /usr/bin/rsync -av -u --exclude localconfig.xml /upgrade/conf/ /opt/zimbra/conf/
    /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
    /usr/bin/rsync -av -u /upgrade/jettyetc/ /opt/zimbra/jetty_base/etc/
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
  su - zimbra -c "zmcertmgr deploycrt self"
  su - zimbra -c "ldap start"
=======
  else
    dosetup=0
  fi
fi 

# Restore config if backup exist
if [ -e /zmsetup/backup/localconfig.xml -a $cleanstart -ne 1 ]; then
  restore_config
  # put back SSL (for LDAP to start)
  su - zimbra -c "zmcertmgr deploycrt self"
fi

# Adjust and start it our way
if [ $dosetup -eq 0 -a $cleanstart -ne 1 ]; then
  su - zimbra -c "ldap start"
  su - zimbra -c "libexec/zmmtainit"
  su - zimbra -c "libexec/zmproxyconfgen"
>>>>>>> 49bbdca (New improved start.sh.)
  cd /opt/zimbra/common/jetty_home/resources && ln -sf /opt/zimbra/jetty_base/etc/jetty-logging.properties && cd -
  /opt/zimbra/common/sbin/newaliases
  su - zimbra -c "libexec/zmloggerinit"
  su - zimbra -c "zmcontrol restart"
<<<<<<< HEAD
fi

# Do setup for new install and upgrade
if [ $dosetup -eq 1 ]; then
  # keep track of .install_history
=======
  copyln /zmsetup/install_history /opt/zimbra/.install_history
fi

# Do setup for new install or upgraded image
if [ $dosetup -eq 1 ]; then
  # save and keep track of .install_history
>>>>>>> 49bbdca (New improved start.sh.)
  copyln /zmsetup/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -c /zmsetup/config.zimbra

  # keep results after configure
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/config.zimbra
  /usr/bin/cp -af /opt/zimbra/log/zmsetup.*.log /zmsetup/
<<<<<<< HEAD
 
  # save OS files for quick restore
  /usr/bin/cp -af /var/spool/cron/zimbra /zmsetup/cron.zimbra
  /usr/bin/cp -af /etc/logrotate.d/zimbra /zmsetup/logrotate.zimbra
  /usr/bin/cp -af /etc/rsyslog.conf /zmsetup/rsyslog.conf

=======

  backup_config
>>>>>>> 49bbdca (New improved start.sh.)
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
  su - zimbra -c "zmcontrol stop"
  exit 0
}

trap stop_zimbra SIGINT SIGTERM

while true
do
  sleep 60
done

