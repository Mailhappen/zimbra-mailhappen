#!/bin/bash
set -x

# 1. Adjust memory size
function adjust_memory_size() {
  # size must be 4 and above. Default 8
  size=$1
  [ -z $size ] && size=8
  [ $size -lt 4 ] && size=4
  if [ $size -ge 16 ]; then
    memory=$(($size*1024/5))
  else
    memory=$(($size*1024/4))
  fi
  su - zimbra -c "zmlocalconfig -e mailboxd_java_heap_size=$memory"

  # mysql always use 30 percent
  memKB=$(($size * 1024 * 1024))
  ((bufferPoolSize=memKB * 1024 * 30 / 100))
  sed -i "s/^innodb_buffer_pool_size.*/innodb_buffer_pool_size = $bufferPoolSize/" /opt/zimbra/conf/my.cnf
}
maxmem="${MAX_MEMORY_GB:=8}"
adjust_memory_size $maxmem

# 2. Install logo
function install_logo () {
  banner=$1
  url=$2
  
  mkdir -p /opt/zimbra/jetty/webapps/zimbra/logos
  chmod 755 /opt/zimbra/jetty/webapps/zimbra/logos

  cd /opt/zimbra/jetty/webapps/zimbra/logos
  curl -L --max-time 30 $banner -o logo.svg
  RS=$?
  [ $RS -ne 0 ] && /usr/bin/cp -f /root/mailhappen-docker.svg logo.svg
  chmod 644 logo.svg

  tmp="/tmp/logo.$$"
  cat > $tmp <<EOT
mcf zimbraSkinLogoLoginBanner /logos/logo.svg
mcf zimbraSkinLogoAppBanner /logos/logo.svg
mcf zimbraSkinLogoURL $url
fc skin
EOT
  su - zimbra -c "zmprov -f $tmp"
  rm -f $tmp
}
logobanner="${LOGO_BANNER:=http://minio.mailhappen.com/downloads/mailhappen-docker.svg}"
logourl="${LOGO_URL:=https://github.com/Mailhappen/}"
install_logo $logobanner $logourl

