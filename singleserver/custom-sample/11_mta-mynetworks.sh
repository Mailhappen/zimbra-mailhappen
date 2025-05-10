#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Put extra network or host into this list
# Keep this to minimal. Try get sender to do SMTP AUTH instead.

EXTRA_MYNETWORKS=""

# restarting container may change to new IP
echo "Reconfigure mynetworks"
mynetworks="$(/opt/zimbra/libexec/zmserverips -n | xargs)"

# check first before making changes
# NOTE about Bash variable expansion
# OK:  su - zimbra -c 'zmprov gs `zmhostname`'
# NOK: su - zimbra -c "zmprov gs `zmhostname`"

current=$(su - zimbra -c 'postconf -h mynetworks')
[ "$current" == "$mynetworks" ] && exit 0

zmhostname=$(su - zimbra -c zmhostname)
cmd=/tmp/cmd.$$

cat <<EOT > $cmd
zmconfigdctl stop
zmprov ms $zmhostname zimbraMtaMyNetworks "$mynetworks"
postfix reload
zmamavisdctl reload
zmconfigdctl start
EOT

su - zimbra -c "bash $cmd"
rm -f $cmd

