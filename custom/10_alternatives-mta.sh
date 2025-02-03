#!/bin/bash
# set -e Exit immediately if any command failed
# set -x Enable debugging
set -ex

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

alternatives --install /usr/sbin/sendmail mta /opt/zimbra/common/sbin/sendmail 100 \
--slave /usr/bin/mailq mta-mailq /opt/zimbra/common/sbin/mailq \
--slave /usr/bin/newaliases mta-newaliases /opt/zimbra/common/sbin/newaliases \
--slave /usr/lib/sendmail mta-sendmail /opt/zimbra/common/sbin/sendmail
alternatives --auto mta
alternatives --display mta
