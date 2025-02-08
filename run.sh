#!/bin/bash

# Alternative way to run docker using command.

# Testing
#docker run --rm \
docker run -d \
	-h mail.example.com \
	-v zimbra:/data \
	-v data:/opt/zimbra/data \
	-v mysql:/opt/zimbra/db/data \
	-v store:/opt/zimbra/store \
	-v index:/opt/zimbra/index \
	-v redolog:/opt/zimbra/redolog \
	-v backup:/opt/zimbra/backup \
	-v ./customize.d:/customize.d \
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
	-p 993:993 \
	-p 995:995 \
	-p 7071:7071 \
	-p 9071:9071 \
	yeak/zimbraimage:10.1.5
