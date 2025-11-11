#!/bin/bash
#
cat <<EOT

This script help you to migrate old Zimbra to the latest version, including OS.

NOTE: Please run this script at the new Zimbra server.
NOTE: Ensure you are able to SSH into old server as root with password.

Your Tasks:

1. Create a new VM and install your preferred OS
2. Download Zimbra 10.1 NE or Maldua's FOSS
3. Run ./install.sh --softwareonly
4. Install the Zimbra components that match the old server
5. Run this script to take care the rest

Shall we begin?
EOT

echo
echo -n "Press Enter to continue "
read ignore

# create config file to keep our info
if [ ! -f ./config ]; then
    echo -n "What is the IP or Hostname of the old Zimbra server? "
    read oldzimbra
    cat <<EOT > ./config
# Old Zimbra IP or Hostname
source_zimbra=$oldzimbra

# SSH Port
source_sshport=22

# SSH User (support root only)
source_sshuser=root

# SSH Key name for pubkey login
source_sshkey=./sshkey
EOT
fi

echo
echo "Using this config: ./config"
source ./config
echo

# Help to create the ssh key and give instruction.
if [ ! -f $source_sshkey ]; then
    echo -n "Generating new ssh.key for migration use..."
    ssh-keygen -q -t rsa -N '' -f $source_sshkey
    echo "done"
    echo
    echo "Please run below to add ssh key to the source server"
    echo "    ssh-copy-id -i $source_sshkey.pub -p $source_sshport $source_sshuser@$source_zimbra"
    echo "Or manually append the $source_sshkey.pub into $source_sshuser@$source_zimbra:.ssh/.authorized_keys"
    echo
    echo "Once it is done, run this script again."
    exit
fi

# Check if we are fresh installed
if [ ! -f /opt/zimbra/.install_history ]; then
    echo "Have you done install Zimbra with -s flag?"
    echo "Refer to step 3"
    exit
fi
grep -q 'CONFIGURED' /opt/zimbra/.install_history
RS=$?
if [ $RS -eq 0 ]; then
    echo "Zimbra is configured. Please uninstall and install with -s flag"
    exit
fi

# Make sure we have /opt/zimbra.bak 
if [ ! -d /opt/zimbra.bak ]; then
    echo "We will copy /opt/zimbra to /opt/zimbra.bak"
    echo -n "Press Enter to continue "
    read ignore
    /usr/bin/cp -a /opt/zimbra /opt/zimbra.bak
fi

# Make sure the /opt/zimbra.bak is a clean setup
grep -q 'CONFIGURED' /opt/zimbra.bak/.install_history
RS=$?
if [ $RS -eq 0 ]; then
    echo "/opt/zimbra.bak isn't clean. We can't proceed, sorry!"
    exit
fi

# make sure we have rsync
if [ ! /usr/bin/rsync ]; then
    echo "Rsync is required; please install."
    exit
fi

# Testing SSH login
cat <<EOT

### Looking good! ###

We are going to test SSH login with this command:

  /usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no $source_zimbra df -h

It should login without password and show the output of "df -h"

Press Enter to continue
EOT
read ignore
/usr/bin/ssh -i $source_sshkey -p $source_sshport -o StrictHostKeyChecking=no $source_zimbra df -h

echo
echo "Done. Please proceed to the next step."
