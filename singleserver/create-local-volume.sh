#!/bin/bash

# To ensure data safety, create our own volume and use it externally.
# Then we store paths in a single volume for easy handling.

<<<<<<< HEAD
<<<<<<< HEAD
local_volume="my-optzimbra-local"
docker volume create $local_volume
=======
local_volume="my_optzimbra"
docker volume create $my_volume_name
>>>>>>> 3e77005 (Update changes include juicefs and cleanups)
=======
local_volume="my-optzimbra"
docker volume create $local_volume
>>>>>>> f61fb77 (Corrected _ to - for juicefs prefix)
docker run --rm \
	--mount src=$local_volume,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}

