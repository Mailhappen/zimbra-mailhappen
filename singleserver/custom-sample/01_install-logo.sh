#!/bin/bash
# set -x Enable debugging
set -x

# Must run in the dirname of the script
cd $(dirname $0)

# Write your script below

# Edit as needed
LOGO_LOGIN=logo.svg
LOGO_APP=logo.svg
LOGO_URL=https://github.com/Mailhappen/
LOGO_DIR=/opt/zimbra/jetty/webapps/zimbra/logos

# If this folder exist we quit
[ -d $LOGO_DIR ] && exit 0

# Install logo
mkdir -p $LOGO_DIR
chmod 755 $LOGO_DIR

/usr/bin/cp -f $LOGO_LOGIN $LOGO_DIR/$LOGO_LOGIN
/usr/bin/cp -f $LOGO_APP $LOGO_DIR/$LOGO_APP
chmod 644 $LOGO_DIR/$LOGO_LOGIN
chmod 644 $LOGO_DIR/$LOGO_APP

tmp="/tmp/logo.$$"
cat > $tmp <<EOT
mcf zimbraSkinLogoLoginBanner /logos/$LOGO_LOGIN
mcf zimbraSkinLogoAppBanner /logos/$LOGO_APP
mcf zimbraSkinLogoURL $LOGO_URL
fc skin
EOT
su - zimbra -c "zmprov -f $tmp"
rm -f $tmp

