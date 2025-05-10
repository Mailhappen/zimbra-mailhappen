#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Deploy zimbra maldua 2fa
if [ ! -e /opt/zimbra/lib/ext/twofactorauth/zetatwofactorauth.jar ]; then
  cd /tmp \
  && curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-maldua-2fa/releases/download/v0.9.4/zimbra-maldua-2fa_0.9.4.tar.gz \
  && tar xzf zimbra-maldua-2fa_0.9.4.tar.gz \
  && cd zimbra-maldua-2fa_0.9.4 \
  && ./install.sh \
  && su - zimbra -c 'zmmailboxdctl restart'
fi
