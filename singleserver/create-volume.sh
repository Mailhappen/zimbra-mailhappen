#!/bin/bash

optzimbra="${MY_DATA:=my_optzimbra}"

docker volume create $optzimbra

docker run --rm \
	--mount src=$optzimbra,dst=/mnt \
	yeak/singleserver /usr/bin/mkdir -p /mnt/{zmsetup,dotssh,ssl,conf,data,commonconf,dbdata,jettyetc,zimletsdeployed,store,index,redolog,backup}
