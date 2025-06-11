#!/bin/bash

# Alternative way to run docker using command.

# Build
docker build -t yeak/singleserver-ne .

# Create volume to keep your data

local_volume="my-optzimbra-local"
docker volume create $local_volume

juicefs_volume="my-optzimbra-juicefs"
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
	alpine mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup,license,oodata}
done

# Run it
docker run -d \
	--restart=unless-stopped \
	--stop-timeout=180 \
	--mount type=volume,src=$juicefs_volume,volume-subpath=zmsetup,dst=/zmsetup \
	--mount type=volume,src=$juicefs_volume,volume-subpath=dotssh,dst=/opt/zimbra/.ssh \
	--mount type=volume,src=$juicefs_volume,volume-subpath=ssl,dst=/opt/zimbra/ssl \
	--mount type=volume,src=$juicefs_volume,volume-subpath=conf,dst=/opt/zimbra/conf \
	--mount type=volume,src=$local_volume,volume-subpath=data,dst=/opt/zimbra/data \
	--mount type=volume,src=$juicefs_volume,volume-subpath=commonconf,dst=/opt/zimbra/common/conf \
	--mount type=volume,src=$juicefs_volume,volume-subpath=dbdata,dst=/opt/zimbra/db/data \
	--mount type=volume,src=$juicefs_volume,volume-subpath=zimletsdeployed,dst=/opt/zimbra/zimlets-deployed \
	--mount type=volume,src=$juicefs_volume,volume-subpath=store,dst=/opt/zimbra/store \
	--mount type=volume,src=$juicefs_volume,volume-subpath=index,dst=/opt/zimbra/index \
	--mount type=volume,src=$juicefs_volume,volume-subpath=redolog,dst=/opt/zimbra/redolog \
	--mount type=volume,src=$juicefs_volume,volume-subpath=backup,dst=/opt/zimbra/backup \
	--mount type=volume,src=$juicefs_volume,volume-subpath=license,dst=/opt/zimbra/license \
	--mount type=volume,src=$juicefs_volume,volume-subpath=oodata,dst=/opt/zimbra/onlyoffice/documentserver/App_Data \
	--mount type=bind,src=./config.defaults,dst=/config.defaults \
	--mount type=bind,src=./config.secrets,dst=/run/secrets/config.secrets \
	-v ./custom:/custom \
	-h mail.example.com \
	-e PUBLIC_SERVICE_HOSTNAME=mail.example.com \
	-e ADMIN_USERNAME=mailadmin \
	-e TIMEZONE=Asia/Kuala_Lumpur \
	-e MAX_MEMORY_GB=8 \
	-e DEV_MODE=n \
	-p 25:25 \
	-p 80:80 \
	-p 443:443 \
	-p 587:587 \
	-p 636:636 \
	-p 993:993 \
	-p 995:995 \
	-p 7071:7071 \
	-p 9071:9071 \
	yeak/singleserver-ne

