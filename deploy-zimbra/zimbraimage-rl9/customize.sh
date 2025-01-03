#!/bin/bash
set -x

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

# 1. Adjust memory size
maxmem="${MAX_MEMORY_GB:=8}"
adjust_memory_size $maxmem

# 2. Install logo
function install_logo () {
  logo_banner="https://minio.mailhappen.com/downloads/mailhappen-docker.svg"
  logo_url="https://github.com/Mailhappen/"
  
  mkdir -p /opt/zimbra/jetty/webapps/zimbra/logos
  chmod 755 /opt/zimbra/jetty/webapps/zimbra/logos

  cd /opt/zimbra/jetty/webapps/zimbra/logos
  curl -L $logo_banner -o logo.svg
  chmod 644 logo.svg
  cp -f logo.svg ../modern/clients/default/assets/logo.svg

  cmd="/tmp/customlogo.??"
  cat > $cmd <<EOT
mcf zimbraSkinLogoLoginBanner /logos/logo.svg
mcf zimbraSkinLogoAppBanner /logos/logo.svg
mcf zimbraSkinLogoURL $logo_url
fc skin
EOT
  su - zimbra -c "zmprov -f $cmd"
  rm -f $cmd
}
install_logo


