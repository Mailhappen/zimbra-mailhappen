#!/bin/bash
#set -x

NAME="zimbra-proxy-ne"

URL=https://files.zimbra.com/downloads/10.1.0_GA/zcs-NETWORK-10.1.0_GA_4688.RHEL9_64.20240911074203.tgz
ZCS=zcs-NETWORK-10.1.0_GA_4688.RHEL9_64.20240911074203
ver=`curl -s https://wiki.zimbra.com/wiki/Zimbra_Releases | grep -oP 'Zimbra_Releases/\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1`

ZCS_TGZ=/tmp/$ZCS.tgz
[ ! -f $ZCS_TGZ ] && curl -L $URL -o $ZCS_TGZ

echo "ZCS:     $ZCS"
echo "Version: $ver"
echo "Name:    $NAME"

echo
echo "Wait 5 sec before continuing..."
sleep 5

# publish our tgz in a temp webserver
cid="/tmp/build.$$"
docker run -d -p 12312:80 --rm --cidfile $cid -v $ZCS_TGZ:/usr/share/nginx/html/$ZCS.tgz nginx
docker build -t yeak/$NAME:$ver \
	--label name=$NAME \
	--label version=$ver \
	--build-arg ZCS=$ZCS \
	--add-host=host.docker.internal:host-gateway \
	--build-arg DOWNLOAD=http://host.docker.internal:12312/$ZCS.tgz \
	--build-arg VERSION=$ver \
	.
docker rm -f `cat $cid`
rm -f $cid
