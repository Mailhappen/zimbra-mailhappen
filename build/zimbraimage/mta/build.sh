#!/bin/bash
#set -x

NAME="zimbra-mta"

ZCS_TGZ=$1
BUILD_NO=$2

[ -z "$ZCS_TGZ" ] && ZCS_TGZ=$(ls -v ../../zcs/data/zcs-*.tgz | tail -1)
[ -z "$BUILD_NO" ] && BUILD_NO=1040000

ZCS=$(basename $ZCS_TGZ)
ZCS=${ZCS%.tgz}
ver=$(echo $ZCS | sed -e 's/zcs-\(.*\..*\..*\)_GA_.*/\1/')

echo "TGZ:     $ZCS_TGZ"
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
	--label build_no=$BUILD_NO \
	--build-arg ZCS=$ZCS \
	--add-host=host.docker.internal:host-gateway \
	--build-arg DOWNLOAD=http://host.docker.internal:12312/$ZCS.tgz \
	.
docker rm -f `cat $cid`
rm -f $cid
