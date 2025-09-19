#!/bin/bash

# Example script to create docker network and add route to the host network.

# please define your external interface
ext_if="wlp1s0"

# subnet you plan to use and its gateway
subnet="172.16.157.0/24"
gateway="172.16.157.1"

# docker network name
name="zimbranet"

# tear down
if [ -n "$1" -a "$1" == "-d" ]; then
  sudo iptables -D DOCKER-USER -i $ext_if -o ${name}0 -j ACCEPT >/dev/null 2>&1
  sudo docker network inspect ${name} >/dev/null 2>&1 &&
  sudo docker network rm ${name}
  exit
fi

# create ${name} (interface ${name}0)
sudo docker network inspect ${name} >/dev/null 2>&1 ||
sudo docker network create -d bridge \
  --subnet=${subnet} \
  --gateway=${gateway} \
  -o "com.docker.network.bridge.enable_icc"="true" \
  -o "com.docker.network.bridge.enable_ip_masquerade"="false" \
  -o "com.docker.network.bridge.name"="${name}0" \
  -o "com.docker.network.driver.mtu"="1500" \
  ${name}

# allow passthru in iptables
sudo iptables -C DOCKER-USER -i $ext_if -o ${name}0 -j ACCEPT >/dev/null 2>&1 ||
sudo iptables -I DOCKER-USER -i $ext_if -o ${name}0 -j ACCEPT >/dev/null 2>&1
