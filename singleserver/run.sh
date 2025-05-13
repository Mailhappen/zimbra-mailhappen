#!/bin/bash

# Alternative way to run docker using command.

# Build
docker build -t yeak/singleserver .

# Create volume to keep your data
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD

local_volume="my-optzimbra-local"
docker volume create $local_volume

<<<<<<< HEAD
juicefs_volume="my-optzimbra-juicefs"
=======
juicefs_volume="my_optzimbra_juicefs"
>>>>>>> b8a6971 (Update the docs and minor typo.)
docker volume create -d juicedata/juicefs \
  -o name=$juicefs_volume \
  -o metaurl=<META_URL> \
  -o storage=s3 \
  -o bucket=<BUCKET_NAME> \
  -o access-key=<ACCESS_KEY> \
  -o secret-key=<SECRET_KEY> \
  $juicefs_volume

# Populate the structure
for v in $local_volume $juicefs_volume; do
docker run --rm \
	--mount src=$v,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}
done

# Run it
docker run -d \
	--restart=unless-stopped \
	--stop-timeout=180 \
	--mount type=volume,src=$local_volume,volume-subpath=zmsetup,dst=/zmsetup \
	--mount type=volume,src=$local_volume,volume-subpath=dotssh,dst=/opt/zimbra/.ssh \
	--mount type=volume,src=$local_volume,volume-subpath=ssl,dst=/opt/zimbra/ssl \
	--mount type=volume,src=$local_volume,volume-subpath=conf,dst=/opt/zimbra/conf \
	--mount type=volume,src=$local_volume,volume-subpath=data,dst=/opt/zimbra/data \
	--mount type=volume,src=$local_volume,volume-subpath=commonconf,dst=/opt/zimbra/common/conf \
	--mount type=volume,src=$juicefs_volume,volume-subpath=dbdata,dst=/opt/zimbra/db/data \
	--mount type=volume,src=$juicefs_volume,volume-subpath=zimletsdeployed,dst=/opt/zimbra/zimlets-deployed \
	--mount type=volume,src=$juicefs_volume,volume-subpath=store,dst=/opt/zimbra/store \
	--mount type=volume,src=$juicefs_volume,volume-subpath=index,dst=/opt/zimbra/index \
	--mount type=volume,src=$juicefs_volume,volume-subpath=redolog,dst=/opt/zimbra/redolog \
	--mount type=volume,src=$juicefs_volume,volume-subpath=backup,dst=/opt/zimbra/backup \
=======
optzimbra="my_optzimbra_data"
docker volume create $optzimbra
=======
my_volume_name="my_optzimbra_data"
docker volume create $my_volume_name
>>>>>>> 570229c (Just clean up and simplify a bit.)
docker run --rm \
	--mount src=$my_volume_name,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}
=======
>>>>>>> 3e77005 (Update changes include juicefs and cleanups)

local_volume="my_optzimbra_data"
docker volume create $local_volume

juicefs_volume="my_optzimbra_jfs"
docker volume create -d juicedata/juicefs \
  -o name=<VOLUME_NAME> \
  -o metaurl=<META_URL> \
  -o storage=<STORAGE_TYPE> \
  -o bucket=<BUCKET_NAME> \
  -o access-key=<ACCESS_KEY> \
  -o secret-key=<SECRET_KEY> \
  $juicefs_volume

# Populate the structure
for v in $local_volume $juicefs_volume; do
docker run --rm \
	--mount src=$v,dst=/mnt \
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}
done

# Run it
docker run -d \
	--restart=unless-stopped \
	--stop-timeout=180 \
<<<<<<< HEAD
	--mount type=volume,src=$optzimbra,volume-subpath=zmsetup,dst=/zmsetup \
	--mount type=volume,src=$optzimbra,volume-subpath=dotssh,dst=/opt/zimbra/.ssh \
	--mount type=volume,src=$optzimbra,volume-subpath=ssl,dst=/opt/zimbra/ssl \
	--mount type=volume,src=$optzimbra,volume-subpath=conf,dst=/opt/zimbra/conf \
	--mount type=volume,src=$optzimbra,volume-subpath=data,dst=/opt/zimbra/data \
	--mount type=volume,src=$optzimbra,volume-subpath=commonconf,dst=/opt/zimbra/common/conf \
	--mount type=volume,src=$optzimbra,volume-subpath=dbdata,dst=/opt/zimbra/db/data \
	--mount type=volume,src=$optzimbra,volume-subpath=zimletsdeployed,dst=/opt/zimbra/zimlets-deployed \
	--mount type=volume,src=$optzimbra,volume-subpath=store,dst=/opt/zimbra/store \
	--mount type=volume,src=$optzimbra,volume-subpath=index,dst=/opt/zimbra/index \
	--mount type=volume,src=$optzimbra,volume-subpath=redolog,dst=/opt/zimbra/redolog \
	--mount type=volume,src=$optzimbra,volume-subpath=backup,dst=/opt/zimbra/backup \
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======
	--mount type=volume,src=$local_volume,volume-subpath=zmsetup,dst=/zmsetup \
	--mount type=volume,src=$local_volume,volume-subpath=dotssh,dst=/opt/zimbra/.ssh \
	--mount type=volume,src=$local_volume,volume-subpath=ssl,dst=/opt/zimbra/ssl \
	--mount type=volume,src=$local_volume,volume-subpath=conf,dst=/opt/zimbra/conf \
	--mount type=volume,src=$local_volume,volume-subpath=data,dst=/opt/zimbra/data \
	--mount type=volume,src=$local_volume,volume-subpath=commonconf,dst=/opt/zimbra/common/conf \
	--mount type=volume,src=$juicefs_volume,volume-subpath=dbdata,dst=/opt/zimbra/db/data \
	--mount type=volume,src=$juicefs_volume,volume-subpath=zimletsdeployed,dst=/opt/zimbra/zimlets-deployed \
	--mount type=volume,src=$juicefs_volume,volume-subpath=store,dst=/opt/zimbra/store \
	--mount type=volume,src=$juicefs_volume,volume-subpath=index,dst=/opt/zimbra/index \
	--mount type=volume,src=$juicefs_volume,volume-subpath=redolog,dst=/opt/zimbra/redolog \
	--mount type=volume,src=$juicefs_volume,volume-subpath=backup,dst=/opt/zimbra/backup \
>>>>>>> 3e77005 (Update changes include juicefs and cleanups)
	-v ./custom:/custom \
	-h mail.example.com \
	-e DEFAULT_ADMIN=mailadmin \
	-e DEFAULT_PASSWORD=Zimbra \
	-e TIMEZONE=Asia/Kuala_Lumpur \
	-e MAX_MEMORY_GB=8 \
	-e DEV_MODE=n \
	-p 25:25 \
	-p 80:80 \
	-p 443:443 \
	-p 465:465 \
	-p 587:587 \
	-p 636:636 \
	-p 993:993 \
	-p 995:995 \
	-p 7071:7071 \
	-p 9071:9071 \
	yeak/singleserver
<<<<<<< HEAD
<<<<<<< HEAD

=======
>>>>>>> 41d753a (Separate out zimbraimage and deployment)
=======

>>>>>>> 3e77005 (Update changes include juicefs and cleanups)
