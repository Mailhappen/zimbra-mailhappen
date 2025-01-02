#!/bin/bash

function set_timezone() {
  if [ -f /usr/share/zoneinfo/$my_timezone ]; then
    ln -sf /usr/share/zoneinfo/$my_timezone /etc/localtime
    echo $my_timezone > /etc/timezone
  fi
}

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
  sed -i --follow-symlinks "s/^innodb_buffer_pool_size.*/innodb_buffer_pool_size        = $bufferPoolSize/" /opt/zimbra/conf/my.cnf
}

function copyln() {
  source=$1
  target=$2
  [ -z "$source" -o -z "$target" ] && return
  [ ! -e $source ] && cp -a $target $source
  rm -rf $target && ln -s $source $target
}

function init() {
  # setup container to use data from our volumes
  # in case volume not attached, we create it
  [ ! -d /data ] && mkdir /data
  # do the job

  # zimbra all
  copyln /data/conf             /opt/zimbra/conf
  copyln /data/install_history  /opt/zimbra/.install_history
  copyln /data/ssh              /opt/zimbra/.ssh
  copyln /data/ssl              /opt/zimbra/ssl

  # ldap and misc
  copyln /data/data             /opt/zimbra/data

  # mailbox
  copyln /data/db               /opt/zimbra/db
  copyln /data/store            /opt/zimbra/store
  copyln /data/index            /opt/zimbra/index
  copyln /data/redolog          /opt/zimbra/redolog
  copyln /data/logger           /opt/zimbra/logger
  copyln /data/zimlets-deployed /opt/zimbra/zimlets-deployed
  copyln /data/jetty-etc        /opt/zimbra/jetty_base/etc
  #copyln /data/common-jetty     /opt/zimbra/common/jetty_home

  # mta
  #copyln /data/common-conf      /opt/zimbra/common/conf

  # done initialize
  touch /init.done
}

