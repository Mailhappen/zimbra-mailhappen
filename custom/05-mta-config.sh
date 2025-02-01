#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# header modification
if [ ! -f /opt/zimbra/conf/custom_header_checks ]; then
  cat <<EOT > /opt/zimbra/conf/custom_header_checks
/^Subject:/                 WARN
/^Received: .*localhost.*/  IGNORE
EOT
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaHeaderChecks "pcre:/opt/zimbra/conf/postfix_header_checks pcre:/opt/zimbra/conf/custom_header_checks"'
fi

echo "Sender Restrictions"
if [ ! -f /opt/zimbra/conf/postfix_reject_sender -o ! -f /opt/zimbra/conf/slm-exceptions-db ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/postfix_reject_sender'
  su - zimbra -c 'postmap /opt/zimbra/conf/postfix_reject_sender'
  su - zimbra -c 'touch /opt/zimbra/conf/slm-exceptions-db'
  su - zimbra -c 'postmap /opt/zimbra/conf/slm-exceptions-db'
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaSmtpdSenderLoginMaps "lmdb:/opt/zimbra/conf/slm-exceptions-db, proxy:ldap:/opt/zimbra/conf/ldap-slm.cf"'
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaSmtpdSenderRestrictions "reject_authenticated_sender_login_mismatch check_sender_access lmdb:/opt/zimbra/conf/postfix_reject_sender"'
fi

echo "Manual postfix transport"
if [ ! -f /opt/zimbra/conf/postfix_transport ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/postfix_transport'
  su - zimbra -c 'postmap /opt/zimbra/conf/postfix_transport'
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaTransportMaps "lmdb:/opt/zimbra/conf/postfix_transport, proxy:ldap:/opt/zimbra/conf/ldap-transport.cf"'
fi

echo "Change Lmtp Host Lookup to native"
cur=$(su - zimbra -c 'postconf -h lmtp_host_lookup' )
if [ "$cur" != "native" ]; then
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaLmtpHostLookup native'
fi
