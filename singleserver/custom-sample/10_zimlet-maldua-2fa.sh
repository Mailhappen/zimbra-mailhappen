#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

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
fi
