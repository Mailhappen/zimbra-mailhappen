#!/bin/bash
set -x

# FUNCTIONS

# Copy and link
copyln() {
  # we copy what we don't have
  # and always override what we have to the target
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" ] && return
  [ ! -e $source ] && /usr/bin/cp -a $target $source
  rm -rf $target && ln -s $source $target
}

# Save postinstall OS files
save_postinstall_os_files() {
  [ -f /var/spool/cron/zimbra ] && /usr/bin/cp -af /var/spool/cron/zimbra /zmsetup/cron.zimbra
  [ -f /etc/logrotate.d/zimbra ] && /usr/bin/cp -af /etc/logrotate.d/zimbra /zmsetup/logrotate.zimbra
  [ -f /etc/rsyslog.conf ] && /usr/bin/cp -af /etc/rsyslog.conf /zmsetup/rsyslog.conf
}

# Trap signal for stop or down 
stop_zimbra() {
  save_postinstall_os_files
  /etc/init.d/zimbra stop
  exit 0
}
trap stop_zimbra SIGTERM


# START WORK

# Set timezone
if [ -f /usr/share/zoneinfo/$timezone ]; then
  ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
  echo $timezone > /etc/timezone
fi

# Pause for debugging
if [ "$dev_mode" = "y" ]; then
  echo "Dev Mode"
  tail -f /dev/null &
  wait "$!"
  exit 0
fi

#
# Main
# 1. new install (up)
# 2. new container same version (down & up)
# 3. new container new version (pull; down & up; upgrade)
# 4. existing container (stop & start)
#

newinstall=0
runzmsetup=0
containerstarted=0

# Existing container stop and start back up
if [ -e /var/spool/cron/zimbra ]; then
  echo "### EXISTING CONTAINER STARTUP ###"
  /usr/bin/supervisorctl restart rsyslog
  /etc/init.d/zimbra start
  containerstarted=1
fi

# New container with new data - New Install
if [ ! -e /zmsetup/install_history ]; then
  echo "### NEW INSTALL ###"
  cat <<EOF > /tmp/temp.sh
export admin_password="$(<$admin_password_file)"
export ldap_admin_pass="$(<$ldap_admin_pass_file)"
export ldap_root_pass="$(<$ldap_root_pass_file)"
cat <<EOT
$(</run/secrets/zmsetup.in)
EOT
EOF
  bash /tmp/temp.sh > /zmsetup/config.zimbra
  rm -f /tmp/temp.sh
  runzmsetup=1
  newinstall=1

# New container with existing data
else
  # Check if the same or different image version is used
  v=$(sed -nE 's/.*zimbra-core-([0-9.]+_.*)\.rpm$/\1/p' /opt/zimbra/.install_history | tail -1)
  grep -q "zimbra-core-$v" /zmsetup/install_history
  RS=$?
  if [ $RS -ne 0 ]; then # different image version is used - assume Upgrade
    echo "### UPGRADE ###"
    sed -i 's/INSTALLED/UPGRADED/' /opt/zimbra/.install_history
    cat /opt/zimbra/.install_history >> /zmsetup/install_history
    /usr/bin/rsync -av -u /upgrade/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
    /usr/bin/rsync -av -u /upgrade/data/ /opt/zimbra/data/
    [ -d /opt/zimbra/common/conf ] && /usr/bin/rsync -av -u /upgrade/commonconf/ /opt/zimbra/common/conf/
    [ -d /opt/zimbra/license ] && /usr/bin/rsync -av -u /upgrade/license/ /opt/zimbra/license/
    runzmsetup=1
  fi
  # fix permission if required
  [ "$(id -nu zimbra)" != "zimbra" -o "$(id -ng zimbra)" != "zimbra" ] && /opt/zimbra/libexec/zmfixperms -e -v
fi 

# We start it our way for same image and existing data (quicker to start)
if [ $runzmsetup -eq 0 -a $containerstarted -ne 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history
  # restore OS files
  /usr/bin/cp -af /zmsetup/cron.zimbra /var/spool/cron/zimbra
  /usr/bin/cp -af /zmsetup/logrotate.zimbra /etc/logrotate.d/zimbra
  /usr/bin/cp -af /zmsetup/rsyslog.conf /etc/rsyslog.conf 
  /usr/bin/supervisorctl restart rsyslog
  # restore mailboxd certs
  [ -f /zmsetup/cacerts ] && copyln /zmsetup/cacerts /opt/zimbra/common/etc/java/cacerts
  [ -f /zmsetup/keystore ] && copyln /zmsetup/keystore /opt/zimbra/mailboxd/etc/keystore
  # fix permission if required
  [ "$(id -nu zimbra)" != "zimbra" -o "$(id -ng zimbra)" != "zimbra" ] && /opt/zimbra/libexec/zmfixperms -e -v
  # zimbra start up
  [ "$(su - zimbra -c 'zmlocalconfig -m nokey ldap_is_master')" == "true" ] && su - zimbra -c "ldap start"
  LOGHOST=$(su - zimbra -c 'zmprov -m -l gcf zimbraLogHostname' | awk '{print $2}');
  [ "$LOGHOST" == "$HOSTNAME" ] && su - zimbra -c "libexec/zmloggerinit"
  [ -d /opt/zimbra/common/jetty_home/resources ] &&
    cd /opt/zimbra/common/jetty_home/resources &&
    ln -sf /opt/zimbra/jetty_base/etc/jetty-logging.properties &&
    cd -
  [ -x /opt/zimbra/common/sbin/newaliases ] &&
    /opt/zimbra/common/sbin/newaliases
  [ -x /opt/zimbra/onlyoffice/bin/zmonlyofficeconfig ] &&
    /opt/zimbra/onlyoffice/bin/zmonlyofficeconfig
  [ "$(su - zimbra -c 'zmlocalconfig -m nokey ldap_is_master')" == "true" ] && su - zimbra -c "ldap stop"
  /etc/init.d/zimbra start
fi

# Run zmsetup for New Install or Upgrade
if [ $runzmsetup -eq 1 ]; then
  # keep track of .install_history
  copyln /zmsetup/install_history /opt/zimbra/.install_history

  # run zmsetup.pl to complete setup
  /opt/zimbra/libexec/zmsetup.pl -c /zmsetup/config.zimbra

  if [ $newinstall -eq 1 ]; then
    # setup ldap mmr
    if [ "$ldap_replication_type" == "mmr" ]; then
      if [ "$ldap_host" == "$HOSTNAME" ]; then # first ldap
        su - zimbra -c "libexec/zmldapenable-mmr -r 100 -s $ldap_server_id -m ldaps://$ldap_alternate_master:636/"
        su - zimbra -c "zmlocalconfig -e ldap_master_url='ldaps://$ldap_host:636 ldaps://$ldap_alternate_master:636'"
        su - zimbra -c "zmlocalconfig -e ldap_url='ldaps://$ldap_host:636 ldaps://$ldap_alternate_master:636'"
      else # for other mmr
	# enable mmr aleady done by zmsetup.pl
        su - zimbra -c "zmlocalconfig -e ldap_master_url='ldaps://$ldap_alternate_master:636 ldaps://$ldap_host:636'"
        su - zimbra -c "zmlocalconfig -e ldap_url='ldaps://$ldap_alternate_master:636 ldaps://$ldap_host:636'"
      fi
    elif [ -n "$ldap_alternate_master" ]; then # for multiserver only
      su - zimbra -c "zmlocalconfig -e ldap_master_url='ldaps://$ldap_host:636 ldaps://$ldap_alternate_master:636'"
      su - zimbra -c "zmlocalconfig -e ldap_url='ldaps://$ldap_host:636 ldaps://$ldap_alternate_master:636'"
    fi
  fi

  # onlyoffice App_Data
  [ -d /opt/zimbra/onlyoffice/documentserver/App_Data ] && install -o zimbra -g zimbra -m 750 -d /opt/zimbra/onlyoffice/documentserver/App_Data

  # keep track of mailboxd certs
  [ -f /opt/zimbra/common/etc/java/cacerts ] && copyln /zmsetup/cacerts /opt/zimbra/common/etc/java/cacerts
  [ -f /opt/zimbra/mailboxd/etc/keystore ] && copyln /zmsetup/keystore /opt/zimbra/mailboxd/etc/keystore

  # keep results after configure
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/
  /usr/bin/cp -af /opt/zimbra/config.* /zmsetup/config.zimbra
  /usr/bin/cp -af /opt/zimbra/log/zmsetup.*.log /zmsetup/

  save_postinstall_os_files

fi

# Post Setup

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

# Stay up like daemon
tail -f /dev/null &
wait "$!"
