#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# TLS hardening
su - zimbra -c "postconf -e fast_flush_domains=''"
su - zimbra -c "postconf -e smtpd_etrn_restrictions=reject"
su - zimbra -c "postconf -e disable_vrfy_command=yes"
su - zimbra -c "postconf -e tls_medium_cipherlist=$(/opt/zimbra/common/bin/openssl ciphers)"
su - zimbra -c "postconf -e tls_preempt_cipherlist=no"

# Disable DSN on delivered mail
#su - zimbra -c 'postconf -e smtpd_discard_ehlo_keywords=silent-discard,dsn'

# Configure catchall-domains
if [ ! -f /opt/zimbra/conf/catchall-domains ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/catchall-domains'
  su - zimbra -c 'postmap /opt/zimbra/conf/catchall-domains'
fi
su - zimbra -c 'postconf -e recipient_bcc_maps=lmdb:/opt/zimbra/conf/catchall-domains'
su - zimbra -c 'postconf -e sender_bcc_maps=lmdb:/opt/zimbra/conf/catchall-domains'

# Configure sender dependent relayhost
if [ ! -f /opt/zimbra/conf/sender-dependent-relayhost ]; then
  su - zimbra -c 'touch /opt/zimbra/conf/sender-dependent-relayhost'
  su - zimbra -c 'postmap /opt/zimbra/conf/sender-dependent-relayhost'
fi
su - zimbra -c 'postconf -e sender_dependent_relayhost_maps=lmdb:/opt/zimbra/conf/sender-dependent-relayhost'

