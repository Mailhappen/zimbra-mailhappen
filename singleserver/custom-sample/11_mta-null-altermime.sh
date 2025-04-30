#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# When one domain uses mandatory signature, those not using have issue.
su - zimbra -c 'touch /opt/zimbra/data/altermime/.b64'
su - zimbra -c 'touch /opt/zimbra/data/altermime/.html'
su - zimbra -c 'touch /opt/zimbra/data/altermime/.txt'
