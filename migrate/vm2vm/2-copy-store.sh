#!/bin/bash
echo
echo "Using this config: ./config"
source ./config
echo

# command
_ssh="/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no"

function _rsync() {
  from=$1; shift
  to=$1; shift
  opt=$*
  /usr/bin/rsync -e "/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no" -avH $source_zimbra:$from $to $opt
}

echo
cat <<EOT
## STEP 2: Copy store and index.

This step is taking time. You can do it at later time, even after the upgrade.

EOT
echo -n "Copy NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then
_rsync /opt/zimbra/store/ /opt/zimbra/store/ --delete
_rsync /opt/zimbra/index/ /opt/zimbra/index/ --delete
fi

