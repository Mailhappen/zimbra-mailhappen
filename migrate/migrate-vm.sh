#!/bin/bash
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

# Container configuration
target_local="my-optzimbra-local"
target_juicefs="my-optzimbra-juicefs"
docker_image="yeak/singleserver"

# command
_cmd="docker run --rm -v $source_sshkey:/key -v $target_local:/local -v $target_juicefs:/juicefs $docker_image"
_ssh="/usr/bin/ssh -i /key -p $source_sshport -o StrictHostKeyChecking=no"

function _rsync() {
  from=$1; shift
  to=$1; shift
  opt=$*
  $_cmd /usr/bin/rsync -e "/usr/bin/ssh -i /key -p $source_sshport -o StrictHostKeyChecking=no" -avH $source_zimbra:$from $to $opt
}

echo
echo -n "## STEP 1: Copy everything except store, index, backup. OK? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

# make a copy of data.mdb to /tmp at the source first
echo "copy data.mdb to /tmp"
$_cmd $_ssh $source_sshuser@$source_zimbra \
  "su - zimbra -c 'rm -f /tmp/data.mdb; mdb_copy data/ldap/mdb/db /tmp'"

# copy the latest config.*
echo "copy latest config.xxx to /tmp"
config=`$_cmd $_ssh $source_sshuser@$source_zimbra "ls -1t /opt/zimbra/config.* | head -1"`
$_cmd $_ssh $source_sshuser@$source_zimbra \
  "/usr/bin/cp -f $config /tmp/config.zimbra"

# copy to juicefs
_rsync /tmp/config.zimbra /juicefs/zmsetup/
_rsync /opt/zimbra/.install_history /juicefs/zmsetup/install_history
_rsync /opt/zimbra/common/etc/java/cacerts /juicefs/zmsetup/
_rsync /opt/zimbra/mailboxd/etc/keystore /juicefs/zmsetup/
_rsync /opt/zimbra/.ssh/ /juicefs/dotssh/
_rsync /opt/zimbra/ssl/ /juicefs/ssl/ --delete
_rsync /opt/zimbra/conf/ /juicefs/conf/
_rsync /opt/zimbra/common/conf/ /juicefs/commonconf/
_rsync /opt/zimbra/zimlets-deployed/ /juicefs/zimletdeployed/ --delete
_rsync /opt/zimbra/redolog/ /juicefs/redolog/ --delete

echo
echo -n "### Going to copy DB data. Press Enter to continue. "
read ignore
_rsync /opt/zimbra/db/data/ /juicefs/dbdata/

echo
echo -n "### Done DB copying. You may release the DB lock..."
sleep 5

# copy to local
_rsync /opt/zimbra/data/ /local/data/ --exclude data.mdb --exclude mailboxd/imap-* --exclude amavisd/tmp/ --delete
/usr/bin/rm -f /local/data/ldap/mdb/db/data.mdb
_rsync /tmp/data.mdb /local/data/ldap/mdb/db/data.mdb
fi

echo
echo -n "## STEP 2: Copy store and index NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

# copy to juicefs also
#
_rsync /opt/zimbra/store/ /juicefs/store/ --delete
_rsync /opt/zimbra/index/ /juicefs/index/ --delete
fi

echo
echo -n "## STEP 3: Copy backup NOW? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

_rsync /opt/zimbra/backup/ /juicefs/backup/ --delete
fi

echo
echo -n "## STEP 4: Will attempts to setup/upgrade. OK? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

_cmd="docker run --rm \
--mount type=volume,src=$target_juicefs,volume-subpath=zmsetup,dst=/zmsetup \
--mount type=volume,src=$target_juicefs,volume-subpath=dotssh,dst=/opt/zimbra/.ssh \
--mount type=volume,src=$target_juicefs,volume-subpath=ssl,dst=/opt/zimbra/ssl \
--mount type=volume,src=$target_juicefs,volume-subpath=conf,dst=/opt/zimbra/conf \
--mount type=volume,src=$target_local,volume-subpath=data,dst=/opt/zimbra/data \
--mount type=volume,src=$target_juicefs,volume-subpath=commonconf,dst=/opt/zimbra/common/conf \
--mount type=volume,src=$target_juicefs,volume-subpath=dbdata,dst=/opt/zimbra/db/data \
--mount type=volume,src=$target_juicefs,volume-subpath=zimletsdeployed,dst=/opt/zimbra/zimlets-deployed \
--mount type=volume,src=$target_juicefs,volume-subpath=store,dst=/opt/zimbra/store \
--mount type=volume,src=$target_juicefs,volume-subpath=index,dst=/opt/zimbra/index \
--mount type=volume,src=$target_juicefs,volume-subpath=redolog,dst=/opt/zimbra/redolog \
--mount type=volume,src=$target_juicefs,volume-subpath=backup,dst=/opt/zimbra/backup \
$docker_image"

uid=`$_cmd id -u zimbra`
gid=`$_cmd id -g zimbra`
$_cmd chown $uid:$gid /opt/zimbra/conf/localconfig.xml
$_cmd chown -R $uid:$gid /opt/zimbra/.ssh
$_cmd su - zimbra -c "zmlocalconfig -e zimbra_uid=$uid; zmlocalconfig -e zimbra_gid=$gid"
$_cmd /opt/zimbra/libexec/zmfixperms -e -v
fi

echo
echo "Done. Try to start up: docker compose up -d; docker compose logs -f"

