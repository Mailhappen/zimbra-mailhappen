#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Put extra network or host into this list
# Keep this to minimal. Try get sender to do SMTP AUTH instead.

EXTRA_MYNETWORKS=""

echo "Configure mynetworks"
mynetworks="127.0.0.0/8 [::1]/128 $(hostname -i)/32"
[ -n "$EXTRA_MYNETWORKS" ] && mynetworks="$mynetworks $EXTRA_MYNETWORKS"

# check first before making changes
# NOTE about Bash variable expansion
# OK:  su - zimbra -c 'zmprov gs `zmhostname`'
# NOK: su - zimbra -c "zmprov gs `zmhostname`"

current=$(su - zimbra -c 'postconf -h mynetworks')
if [ "$current" != "$mynetworks" ]; then
  zmhostname=$(su - zimbra -c zmhostname)
  su - zimbra -c 'zmconfigdctl stop'
  su - zimbra -c "zmprov ms $zmhostname zimbraMtaMyNetworks \"$mynetworks\""
  su - zimbra -c 'postfix reload'
  su - zimbra -c 'zmamavisdctl reload'
  su - zimbra -c 'zmconfigdctl start'
fi

