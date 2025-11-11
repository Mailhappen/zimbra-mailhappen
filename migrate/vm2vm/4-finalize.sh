#!/bin/bash
echo
echo "Using this config: ./config"
source ./config
echo

echo
cat <<EOT
## STEP 4: Finalize what we have copied for upgrade."

We need to massage the data that we have copied over to prepare for upgrade.

EOT
echo -n "Proceed? [y/N] "
read answer
if [ "$answer" == "Y" -o "$answer" == "y" ]; then

echo "Adjusting .install_history"
sed 's/INSTALLED/UPGRADED/g' /opt/zimbra.bak/.install_history > /tmp/install_history
cat /root/install_history /tmp/install_history > /opt/zimbra/.install_history

echo "Copying upgraded files"
/usr/bin/rsync -au /opt/zimbra.bak/conf/ /opt/zimbra/conf/ --exclude localconfig.xml
/usr/bin/rsync -au /opt/zimbra.bak/data/ /opt/zimbra/data/
[ -d /opt/zimbra/common/conf ] && /usr/bin/rsync -au /opt/zimbra.bak/common/conf/ /opt/zimbra/common/conf/
[ -d /opt/zimbra/license ] && /usr/bin/rsync -au /opt/zimbra.bak/license/ /opt/zimbra/license/

echo "Fix permission"
uid=`id -u zimbra`
gid=`id -g zimbra`
chown $uid:$gid /opt/zimbra/conf/localconfig.xml
chown -R $uid:$gid /opt/zimbra/.ssh
su - zimbra -c "zmlocalconfig -e zimbra_uid=$uid; zmlocalconfig -e zimbra_gid=$gid"
/opt/zimbra/libexec/zmfixperms -e -v

echo
echo "Done. Please run command below to complete the setup/upgrade."
echo
echo "  /opt/zimbra/libexec/zmsetup.pl -c /root/config.zimbra"
echo
fi
