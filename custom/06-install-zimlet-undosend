#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Deploy maldua 2fa
cd /tmp
curl --max-time 30 -L https://gallery.zetalliance.org/extend/items/download/92 -o com_zimbra_undosend.zip
su - zimbra -c 'zmzimletctl deploy /tmp/com_zimbra_undosend.zip'
