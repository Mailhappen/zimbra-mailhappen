#!/bin/bash
set -x

my_hostname="$(hostname -s)"
my_domain="$(hostname -d)"
[ -z "$my_domain" ] && my_domain="zimbra.lab"
my_fqdn="$my_hostname.$my_domain"
my_admin="${DEFAULT_ADMIN:=sysadmin}"
my_password="${DEFAULT_PASSWORD:=zimbra}"
my_timezone="${TIMEZONE:=Asia/Kuala_Lumpur}"
my_maxmem="${MAX_MEMORY_GB:=8}"

source /root/functions.sh

# Set system timezone
set_timezone

# New container requires init.
if [ ! -f /init.done ]; then

  init
  
  # Setup Zimbra
  #
  grep -q "CONFIGURED" /opt/zimbra/.install_history
  RS=$?

  # New install
  if [ $RS -ne 0  ]; then

      cat <<EOT > /tmp/defaultsfile
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

    # show it for debug purpose
    cat /tmp/defaultsfile

    # run zmsetup.pl
    /opt/zimbra/libexec/zmsetup.pl -c /tmp/defaultsfile

    # keep results after configure
    cp -a /opt/zimbra/config.* /data/
    cp -a /opt/zimbra/log/zmsetup.*.log /data/

  # Existing system. Run zmsetup.pl to localize or upgrade
  else
    /opt/zimbra/libexec/zmsetup.pl
  fi

# Otherwise just start up Zimbra
#
else
  su - zimbra -c "zmcontrol start"
fi

# Restart rsyslog
supervisorctl restart rsyslog

stop_zimbra () {
  su - zimbra -c "zmcontrol stop"
  exit 0
}

# Wait for supervisor to stop script
trap stop_zimbra SIGINT SIGTERM

while true
do
  sleep 1
done
