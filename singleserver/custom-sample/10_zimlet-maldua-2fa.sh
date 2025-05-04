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

<<<<<<< HEAD
<<<<<<< HEAD
# Deploy zimbra maldua 2fa
if [ ! -e /opt/zimbra/lib/ext/twofactorauth/zetatwofactorauth.jar ]; then
  cd /tmp \
  && curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-maldua-2fa/releases/download/v0.9.5/zimbra-maldua-2fa_0.9.5.tar.gz \
  && tar xzf zimbra-maldua-2fa_0.9.5.tar.gz \
  && cd zimbra-maldua-2fa_0.9.5 \
  && ./install.sh \
  && su - zimbra -c 'zmmailboxdctl restart'
=======
# Deploy maldua 2fa
=======
# Deploy zimbra maldua 2fa
>>>>>>> 6985041 (Notice set -e not good for us)
cd /tmp
if [ ! -e /opt/zimbra/lib/ext/twofactorauth/zetatwofactorauth.jar ]; then
    curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-maldua-2fa/releases/download/v0.9.4/zimbra-maldua-2fa_0.9.4.tar.gz
    tar xzf zimbra-maldua-2fa_0.9.4.tar.gz
cd zimbra-maldua-2fa_0.9.4
    ./install.sh
    su - zimbra -c 'zmmailboxdctl restart'
fi
<<<<<<< HEAD

# Temp fix errorMessage showing
if grep -E '.twoFactorForm .errorMessage{' /opt/zimbra/jetty/webapps/zimbra/skins/_base/base3/skin.css > /dev/null 2>&1 ; then
    :
else
    cat <<EOT >> /opt/zimbra/jetty/webapps/zimbra/skins/_base/base3/skin.css
.twoFactorForm .errorMessage{
        display: none;
}
EOT
    su - zimbra -c 'zmprov fc skin'
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
fi
=======
>>>>>>> 6985041 (Notice set -e not good for us)
