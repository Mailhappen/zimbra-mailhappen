#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

crontab -u zimbra -l > /tmp/cron.zimbra
grep -q zmstat-cleanup /tmp/cron.zimbra
RS=$?
[ $RS -eq 0 ] && exit 0
cat >> /tmp/cron.zimbra <<EOT
#
# zmstat_cleanup
#
15 0 * * 7 /opt/zimbra/libexec/zmstat-cleanup -k 30
EOT
crontab -u zimbra /tmp/cron.zimbra
