#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

volume="$1"

if [ -z "$volume" ]; then
  if [ -f .env ]; then
    echo "These volumes are found in your .env file:"
    echo
    grep _VOL= .env | awk -F= '{print " ",$2}' | tr -d '"'
    echo
    echo -n "Name of the volume to create? "
    read volume
  else
    echo -n "Name of the volume to create? "
    read volume
  fi
fi

docker volume create $volume
docker run --rm \
  --mount src=$volume,dst=/mnt \
  alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup,license,oodata}
docker run --rm \
  --mount src=$volume,dst=/mnt \
  alpine ls -l /mnt/
