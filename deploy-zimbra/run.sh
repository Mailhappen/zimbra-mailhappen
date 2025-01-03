#!/bin/bash

# Start the container this way to use it.
#docker run -d -h mail.example.com yeak/zimbraimage-rl9

# Testing use
#docker run --rm \
docker run -d \
	-h zmail.example.com \
	-v data:/data \
	-e DEFAULT_ADMIN=mailadmin \
	-e DEFAULT_PASSWORD=Zimbra \
	-e TIMEZONE=Asia/Kuala_Lumpur \
	-e MAX_MEMORY_GB=8 \
	yeak/zimbraimage-rl9
exit

# Testing use
docker run --rm \
	-h mail.example.com \
	-v history:/opt/zimbra/.install_history \
	-v conf:/opt/zimbra/conf \
	-v ssh:/opt/zimbra/.ssh \
	-v ssl:/opt/zimbra/ssl \
	-v rsyslog:/etc/rsyslog.conf \
	-v crontab:/var/spool/cron/zimbra \
	-v etc:/opt/zimbra/common/etc \
	-v store:/opt/zimbra/store \
	-v index:/opt/zimbra/index \
	-v redolog:/opt/zimbra/redolog \
	-v db:/opt/zimbra/db \
	-v data:/opt/zimbra/data \
	-v logger:/opt/zimbra/logger \
	-v zimlets:/opt/zimbra/zimlets-deployed \
	-v jettyetc:/opt/zimbra/jetty_base/etc \
	-v maincf:/opt/zimbra/common/conf/main.cf \
	-v mastercf:/opt/zimbra/common/conf/master.cf \
	yeak/zimbraimage-rl9
