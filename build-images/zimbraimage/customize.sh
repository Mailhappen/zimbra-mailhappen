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
  curl --max-time 30 -L $banner -o logo.svg
  RS=$?
  if [ $RS -ne 0 ]; then
    rm -f logo.svg
    return 1
  fi
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

# 3. Deploy maldua 2fa
function deploy_maldua_2fa() {
  cd /tmp
  curl --max-time 30 -LO https://github.com/maldua-suite/zimbra-ose-2fa/releases/download/v0.8.0/zimbra-ose-2fa_0.8.0.tar.gz
  RS=$?
  if [ $RS -ne 0 ]; then
    rm -f zimbra-ose-2fa_0.8.0.tar.gz
    return 1
  fi
  tar xf zimbra-ose-2fa_0.8.0.tar.gz
  cd zimbra-ose-2fa_0.8.0
  ./install.sh
  su - zimbra -c 'zmmailboxdctl restart'
}
deploy_maldua_2fa

# 4. zmstat-cleanup
function zmstat_cleanup_crontab() {
  crontab -u zimbra -l > /tmp/cron.zimbra
  grep -q zmstat-cleanup /tmp/cron.zimbra
  RS=$?
  [ $RS -eq 0 ] && return 0
  cat >> /tmp/cron.zimbra <<EOT
#
# zmstat_cleanup
#
15 0 * * 7 /opt/zimbra/libexec/zmstat-cleanup -k 30
EOT
  crontab -u zimbra /tmp/cron.zimbra
}
zmstat_cleanup_crontab
