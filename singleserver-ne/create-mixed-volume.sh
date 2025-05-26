#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

local_volume="my-optzimbra-local"
juicefs_volume="my-optzimbra-juicefs"
juicefs_prefix="$juicefs_volume" # only alphabet, number, - and 3 to 63 chars.

# create local volume
#
docker volume create $local_volume
docker run --rm \
	--mount src=$local_volume,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup,license,oodata}

# mailbox keep in juicefs
#
docker volume create -d juicedata/juicefs \
  -o name=$juicefs_prefix \
  -o metaurl=<META_URL> \
  -o storage=s3 \
  -o bucket=<BUCKET_NAME> \
  -o access-key=<ACCESS_KEY> \
  -o secret-key=<SECRET_KEY> \
  $juicefs_volume

docker run --rm \
	--mount src=$juicefs_volume,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup,license,oodata}

