#!/bin/bash
#
# This script is modified to migrate any Zimbra to your latest version.
# eg: Zimbra 8815 on CentOS 7.9 to Zimbra 10.1 on RockyLinux 9
# 
# 1. Prepare your new VM and install your preferred OS
# 2. Download new Zimbra 10.1 NE or FOSS for your OS
# 3. Run ./install.sh -s
# 4. The component to install should match your current one
# 5. Backup fresh /opt/zimbra to /opt/zimbra.bak
# 6. Edit this script, change `source_zimbra` IP address
# 7. Run this script. Follow instruction to install the ssh.key to the source
# 8. You can keep running this script
# 9. To start over, run ./install.sh -u and also remove /opt/zimbra.bak
#
# This script only copy data from the source server to the new server. You can
# test the new server upgrade to see if it can upgrade successfully.
#
# Please setup SSH with key based access
source_zimbra=172.16.2.10
source_sshport=22
source_sshuser=root
source_sshkey=./ssh.key

# Help to create the ssh key and give instruction.
if [ ! -f $source_sshkey ]; then
    echo "Generating new ssh.key for migration use"
    ssh-keygen -q -t rsa -N '' -f $source_sshkey
    echo "Please run below to add ssh key to the source server"
    echo "    ssh-copy-id -i $source_sshkey.pub -p $source_sshport $source_sshuser@$source_zimbra"
    echo "Or manually append the $source_sshkey.pub into $source_sshuser@$source_zimbra:.ssh/.authorized_keys"
    echo "Once it is done, run this script again."
    exit
fi

if [ ! -d /opt/zimbra.bak ]; then
  echo "Please cp -a /opt/zimbra to /opt/zimbra.bak"
  echo "It should be a clean install from --softwareonly"
  exit
fi

# command
_ssh="/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no"

function _rsync() {
  from=$1; shift
  to=$1; shift
  opt=$*
  /usr/bin/rsync -e "/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no" -avH $source_zimbra:$from $to $opt
}

echo
echo -n "## STEP 1: Copy /opt/zimbra from source (skip store, index, backup). Proceed? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

# make a copy of data.mdb to /tmp at the source first
echo "copy data.mdb to /tmp"
$_ssh $source_sshuser@$source_zimbra \
  "su - zimbra -c 'rm -f /tmp/data.mdb; mdb_copy data/ldap/mdb/db /tmp'"

# copy the latest config.*
echo "copy latest config.xxx to /tmp"
config=`$_ssh $source_sshuser@$source_zimbra "ls -1t /opt/zimbra/config.* | head -1"`
$_ssh $source_sshuser@$source_zimbra \
  "/usr/bin/cp -f $config /tmp/config.zimbra"

# copy data over
_rsync /tmp/config.zimbra /root/config.zimbra
_rsync /opt/zimbra/.install_history /root/install_history
_rsync /opt/zimbra/common/etc/java/cacerts /opt/zimbra/common/etc/java/cacerts
_rsync /opt/zimbra/mailboxd/etc/keystore /opt/zimbra/mailboxd/etc/keystore
_rsync /opt/zimbra/.ssh/ /opt/zimbra/.ssh/
_rsync /opt/zimbra/ssl/ /opt/zimbra/ssl/ --delete
_rsync /opt/zimbra/conf/ /opt/zimbra/conf/
_rsync /opt/zimbra/common/conf/ /opt/zimbra/common/conf/
_rsync /opt/zimbra/zimlets-deployed/ /opt/zimbra/zimletdeployed/ --delete
_rsync /opt/zimbra/redolog/ /opt/zimbra/redolog/ --delete
_rsync /opt/zimbra/data/ /opt/zimbra/data/ --exclude data.mdb --exclude mailboxd/imap-* --exclude amavisd/tmp/ --delete
/usr/bin/rm -f /opt/zimbra/data/ldap/mdb/db/data.mdb
_rsync /tmp/data.mdb /opt/zimbra/data/ldap/mdb/db/data.mdb

echo
echo "### Copy DB data..."
echo
echo "You can suspend mysql at source: flush tables with read lock"
echo "Or stop mysql:         mysql.server stop"
echo "And start again later: mysql.server start"
echo
echo "For initial copy, just proceed first."
echo
echo "!!! NOTE !!! It is best to do this at maintenance or low peak time!"
echo
echo -n "Press Enter to continue "
read ignore
_rsync /opt/zimbra/db/data/ /opt/zimbra/db/data/

echo
echo "### Done copying DB. You may release the DB lock..."
echo
echo -n "Press Enter to continue "
read ignore
fi

echo
echo "## STEP 2: Copy store and index."
echo "Skip this to do quick upgrade testing. Run this to do full migration."
echo
echo -n "Copy NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

_rsync /opt/zimbra/store/ /opt/zimbra/store/ --delete
_rsync /opt/zimbra/index/ /opt/zimbra/index/ --delete
fi

echo
echo -n "## STEP 3: Copy backup."
echo "Skip this to do quick upgrade testing. This is optional."
echo
echo -n "Copy NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

_rsync /opt/zimbra/backup/ /opt/zimbra/backup/ --delete
fi

echo
echo -n "## STEP 4: Adjust data for upgrade. Proceed? [y/N] "
echo
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

echo "Adjusting .install_history"
sed 's/INSTALLED/UPGRADED/g' /opt/zimbra.bak/.install_history > /tmp/install_history
cat /root/install_history /tmp/install_history > /opt/zimbra/.install_history

echo "Copying upgraded files"
/usr/bin/rsync -av -u /opt/zimbra.bak/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
/usr/bin/rsync -av -u /opt/zimbra.bak/data/ /opt/zimbra/data/
[ -d /opt/zimbra/common/conf ] && /usr/bin/rsync -av -u /opt/zimbra.bak/common/conf/ /opt/zimbra/common/conf/
[ -d /opt/zimbra/license ] && /usr/bin/rsync -av -u /opt/zimbra.bak/license/ /opt/zimbra/license/

echo "Fix permission"
uid=`id -u zimbra`
gid=`id -g zimbra`
chown $uid:$gid /opt/zimbra/conf/localconfig.xml
chown -R $uid:$gid /opt/zimbra/.ssh
su - zimbra -c "zmlocalconfig -e zimbra_uid=$uid; zmlocalconfig -e zimbra_gid=$gid"
$_cmd /opt/zimbra/libexec/zmfixperms -e -v
fi

echo
echo "Done. Please run command below to complete the setup/upgrade."
echo
echo "  /opt/zimbra/libexec/zmsetup.pl -c /root/config.zimbra"
echo
