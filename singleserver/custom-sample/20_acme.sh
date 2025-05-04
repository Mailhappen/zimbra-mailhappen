#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# quit if already installed
[ -d /root/.acme.sh ] && exit 0

# download acme.sh
curl https://get.acme.sh | sh -s email=postmaster@${HOSTNAME}

# issue the cert for this host
/root/.acme.sh/acme.sh --issue \
  --standalone \
  --keylength 2048 \
  --server letsencrypt \
  -d ${HOSTNAME}

# prepare to deploy
/usr/bin/cp -f /root/.acme.sh/${HOSTNAME}/${HOSTNAME}.key /tmp/commercial.key
/usr/bin/cp -f /root/.acme.sh/${HOSTNAME}/${HOSTNAME}.cer /tmp/commercial.crt
/usr/bin/cp -f /root/.acme.sh/${HOSTNAME}/ca.cer /tmp/commercial_ca.crt
chown zimbra:zimbra /tmp/commercial.{key,crt} /tmp/commercial_ca.crt
# Append selfsign CA (Zimbra needs it)
curl -sL https://letsencrypt.org/certs/isrgrootx1.pem >> /tmp/commercial_ca.crt

# deploy
su - zimbra -c '/usr/bin/cp -f /tmp/commercial.key ssl/zimbra/commercial/'
su - zimbra -c 'zmcertmgr deploycrt comm /tmp/commercial.crt /tmp/commercial_ca.crt'

# restart service
su - zimbra -c 'zmcontrol restart'
