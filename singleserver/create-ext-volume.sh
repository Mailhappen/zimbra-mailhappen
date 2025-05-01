#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

my_volume_name=="my_optzimbra"
docker volume create $my_volume_name
docker run --rm \
	--mount src=$my_volume_name,dst=/mnt \
	yeak/singleserver /usr/bin/mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}

