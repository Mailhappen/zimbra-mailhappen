#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Deploy maldua 2fa
cd /tmp
curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-ose-2fa/releases/download/v0.8.0/zimbra-ose-2fa_0.8.0.tar.gz
tar xf zimbra-ose-2fa_0.8.0.tar.gz
cd zimbra-ose-2fa_0.8.0
./install.sh
su - zimbra -c 'zmmailboxdctl restart'
