#!/bin/bash
<<<<<<< HEAD
# set -x Enable debugging
set -x
=======
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex
>>>>>>> 41d753a (Separate out zimbraimage and deployment)

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

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
cd /tmp
if grep -E 'TwoFactor_qr.js' /opt/zimbra/jetty/webapps/zimbra/public/TwoFactorSetup.jsp > /dev/null 2>&1 ; then
   :
else
    curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-ose-2fa/releases/download/v0.8.0/zimbra-ose-2fa_0.8.0.tar.gz
    tar xf zimbra-ose-2fa_0.8.0.tar.gz
    cd zimbra-ose-2fa_0.8.0
    ./install.sh
    su - zimbra -c 'zmmailboxdctl restart'
fi

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
