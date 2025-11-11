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
  /usr/bin/rsync -e "/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no" -vaH $source_zimbra:$from $to $opt
}

echo
cat <<EOT
## STEP 1: Copy /opt/zimbra from source (exclude store, index, backup).

EOT
echo -n "Proceed? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

echo "Make a copy of data.mdb to /tmp"
$_ssh $source_sshuser@$source_zimbra \
  "su - zimbra -c 'rm -f /tmp/data.mdb; mdb_copy data/ldap/mdb/db /tmp'"

echo "Choose the latest config.xxx to use"
config=`$_ssh $source_sshuser@$source_zimbra "ls -1t /opt/zimbra/config.* | head -1"`
$_ssh $source_sshuser@$source_zimbra \
  "/usr/bin/cp -f $config /tmp/config.zimbra"

echo "### Copying the data over now..."
sleep 5
_rsync /tmp/config.zimbra /root/config.zimbra
_rsync /opt/zimbra/.install_history /root/install_history
_rsync /opt/zimbra/common/etc/java/cacerts /opt/zimbra/common/etc/java/cacerts
_rsync /opt/zimbra/mailboxd/etc/keystore /opt/zimbra/mailboxd/etc/keystore
_rsync /opt/zimbra/.ssh/ /opt/zimbra/.ssh/
_rsync /opt/zimbra/ssl/ /opt/zimbra/ssl/ --delete
_rsync /opt/zimbra/conf/ /opt/zimbra/conf/
_rsync /opt/zimbra/common/conf/ /opt/zimbra/common/conf/
_rsync /opt/zimbra/zimlets-deployed/ /opt/zimbra/zimlets-deployed/ --delete
_rsync /opt/zimbra/redolog/ /opt/zimbra/redolog/ --delete
_rsync /opt/zimbra/data/ /opt/zimbra/data/ --exclude data.mdb --exclude mailboxd/imap-* --exclude amavisd/tmp/ --delete
/usr/bin/rm -f /opt/zimbra/data/ldap/mdb/db/data.mdb
_rsync /tmp/data.mdb /opt/zimbra/data/ldap/mdb/db/data.mdb

echo
echo "### Copying DB data..."
cat <<EOT

You can copy the DB data while the Zimbra server is still running. Open another
terminal and login to the source server.

As zimbra user, run "mysql" and then type "flush tables with read lock;". Come
back to this screen to continue. After the copying is done, you must quit
mysql from the source server to release the lock.

Or simply stop mysql:     mysql.server stop
And start after copying:  mysql.server start

For initial copy, just press Enter to proceed first.

EOT

echo -n "Press Enter to continue "
read ignore
_rsync /opt/zimbra/db/data/ /opt/zimbra/db/data/

echo
echo "Done. Please proceed to the next step."
fi
