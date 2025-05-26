#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Header modification
# capture Subject: into the log file
# hide all localhost routes
if [ ! -f /opt/zimbra/conf/custom_header_checks ]; then
  cat <<EOT > /opt/zimbra/conf/custom_header_checks
/^Subject:/                 INFO
/^Received: .*localhost.*/  IGNORE
EOT
fi
su - zimbra -c 'zmprov mcf zimbraMtaBlockedExtensionWarnRecipient FALSE'
su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaHeaderChecks "pcre:/opt/zimbra/conf/postfix_header_checks pcre:/opt/zimbra/conf/custom_header_checks"'

# Sender Restrictions
if [ ! -f /opt/zimbra/conf/postfix_reject_sender -o ! -f /opt/zimbra/conf/slm-exceptions-db ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/postfix_reject_sender'
  su - zimbra -c 'touch /opt/zimbra/conf/slm-exceptions-db'
  su - zimbra -c 'postmap /opt/zimbra/conf/postfix_reject_sender'
  su - zimbra -c 'postmap /opt/zimbra/conf/slm-exceptions-db'
fi
su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaSmtpdSenderLoginMaps "lmdb:/opt/zimbra/conf/slm-exceptions-db, proxy:ldap:/opt/zimbra/conf/ldap-slm.cf"'
su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaSmtpdSenderRestrictions "reject_authenticated_sender_login_mismatch check_sender_access lmdb:/opt/zimbra/conf/postfix_reject_sender"'

# Add our custom postfix transport
if [ ! -f /opt/zimbra/conf/postfix_transport ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/postfix_transport'
  su - zimbra -c 'postmap /opt/zimbra/conf/postfix_transport'
fi
su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaTransportMaps "lmdb:/opt/zimbra/conf/postfix_transport, proxy:ldap:/opt/zimbra/conf/ldap-transport.cf"'

# Use native Lmtp Host Lookup
cur=$(su - zimbra -c 'postconf -h lmtp_host_lookup' )
if [ "$cur" != "native" ]; then
  su - zimbra -c 'zmprov ms `zmhostname` zimbraMtaLmtpHostLookup native'
fi

