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

# Deploy undosend zimlet
<<<<<<< HEAD
if [ ! -d /opt/zimbra/zimlets-deployed/com_zimbra_undosend ]; then
  && curl --max-time 30 -L https://gallery.zetalliance.org/extend/items/download/92 -o /tmp/com_zimbra_undosend.zip \
  && su - zimbra -c 'zmzimletctl deploy /tmp/com_zimbra_undosend.zip'
=======
cd /tmp
if [ ! -d /opt/zimbra/zimlets-deployed/com_zimbra_undosend ]; then
  curl --max-time 30 -L https://gallery.zetalliance.org/extend/items/download/92 -o com_zimbra_undosend.zip
  su - zimbra -c 'zmzimletctl deploy /tmp/com_zimbra_undosend.zip'
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
fi
