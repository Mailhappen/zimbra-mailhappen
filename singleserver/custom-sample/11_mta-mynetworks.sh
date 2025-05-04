#!/bin/bash
<<<<<<< HEAD
<<<<<<< HEAD
# set -x Enable debugging
set -x
=======
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======
# set -x Enable debugging
set -x
>>>>>>> 6985041 (Notice set -e not good for us)

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Put extra network or host into this list
# Keep this to minimal. Try get sender to do SMTP AUTH instead.

EXTRA_MYNETWORKS=""

<<<<<<< HEAD
# restarting container may change to new IP
echo "Reconfigure mynetworks"
mynetworks="$(/opt/zimbra/libexec/zmserverips -n | xargs)"
=======
echo "Configure mynetworks"
mynetworks="127.0.0.0/8 [::1]/128 $(hostname -i)/32"
[ -n "$EXTRA_MYNETWORKS" ] && mynetworks="$mynetworks $EXTRA_MYNETWORKS"
>>>>>>> 41d753a (Separate out zimbraimage and deployment)

# check first before making changes
# NOTE about Bash variable expansion
# OK:  su - zimbra -c 'zmprov gs `zmhostname`'
# NOK: su - zimbra -c "zmprov gs `zmhostname`"

current=$(su - zimbra -c 'postconf -h mynetworks')
<<<<<<< HEAD
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
=======
if [ "$current" != "$mynetworks" ]; then
  zmhostname=$(su - zimbra -c zmhostname)
  su - zimbra -c 'zmconfigdctl stop'
  su - zimbra -c "zmprov ms $zmhostname zimbraMtaMyNetworks \"$mynetworks\""
  su - zimbra -c 'postfix reload'
  su - zimbra -c 'zmamavisdctl reload'
  su - zimbra -c 'zmconfigdctl start'
fi
>>>>>>> 41d753a (Separate out zimbraimage and deployment)

