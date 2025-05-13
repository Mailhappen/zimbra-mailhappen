#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

juicefs_volume="my_optzimbra_juicefs"

docker volume create -d juicedata/juicefs \
  -o name=<VOLUME_NAME> \
  -o metaurl=<META_URL> \
  -o storage=<STORAGE_TYPE> \
  -o bucket=<BUCKET_NAME> \
  -o access-key=<ACCESS_KEY> \
  -o secret-key=<SECRET_KEY> \
  $juicefs_volume

docker run --rm \
	--mount src=$juicefs_volume,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}

