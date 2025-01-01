#!/bin/bash

# Initializing sshd at startup
[ ! -s /etc/ssh/ssh_host_rsa_key ] && /usr/libexec/openssh/sshd-keygen rsa
[ ! -s /etc/ssh/ssh_host_ecdsa_key ] && /usr/libexec/openssh/sshd-keygen ecdsa
[ ! -s /etc/ssh/ssh_host_ed25519_key ] && /usr/libexec/openssh/sshd-keygen ed25519

# Start sshd
exec /usr/sbin/sshd -D
