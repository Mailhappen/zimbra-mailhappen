#!/bin/bash

# Alternative way to run docker using command.

# Build
docker build -t yeak/singleserver .

# Create volume to keep your data
my_volume_name="my_optzimbra_data"
docker volume create $my_volume_name
docker run --rm \
	--mount src=$my_volume_name,dst=/mnt \
	yeak/singleserver /usr/bin/mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,zimletsdeployed,store,index,redolog,backup}

# Run
docker run -d \
	--restart=unless-stopped \
	--stop-timeout=180 \
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
