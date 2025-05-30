#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Edit as needed
LOGO=logo.svg
LOGOURL=https://github.com/Mailhappen/
LOGODIR=/opt/zimbra/jetty/webapps/zimbra/logos

# If this folder exist we quit
[ -d $LOGODIR ] && exit 0

# Install logo
mkdir -p $LOGODIR
chmod 755 $LOGODIR

/usr/bin/cp -f $LOGO $LOGODIR/$LOGO
chmod 644 $LOGODIR/$LOGO

tmp="/tmp/logo.$$"
cat > $tmp <<EOT
mcf zimbraSkinLogoLoginBanner /logos/$LOGO
mcf zimbraSkinLogoAppBanner /logos/$LOGO
mcf zimbraSkinLogoURL $LOGOURL
fc skin
EOT
su - zimbra -c "zmprov -f $tmp"
rm -f $tmp

