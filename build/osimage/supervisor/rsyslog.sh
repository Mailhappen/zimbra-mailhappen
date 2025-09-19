#!/bin/bash

# Make rsyslog run without systemd
sed --follow-symlinks -i 's/SysSock.Use="off"/SysSock.Use="on"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^module(load="imjournal"/#module(load="imjournal"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^\s*UsePid="system"/  #UsePid="system"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^\s*FileCreateMode="0644"/  #FileCreateMode="0644"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^\s*StateFile="imjournal.state"/  #StateFile="imjournal.state"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^#module(load="imudp"/module(load="imudp"/' /etc/rsyslog.conf
sed --follow-symlinks -i 's/^#input(type="imudp"/input(type="imudp"/' /etc/rsyslog.conf

# Tuning
umask 0066
ulimit -n 16384

# Start rsyslog
exec /usr/sbin/rsyslogd -n
