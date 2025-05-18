#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

juicefs_volume="my-optzimbra-juicefs"
juicefs_prefix="myjfs" # only alphabet, number, - and 3 to 63 chars.

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
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}

