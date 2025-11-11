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
## STEP 3: Copy /opt/zimbra/backup

You may keep some important data in /opt/zimbra/backup.

EOT
echo -n "Copy NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

_rsync /opt/zimbra/backup/ /opt/zimbra/backup/ --delete
fi

