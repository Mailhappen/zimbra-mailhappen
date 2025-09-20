#!/bin/bash

for dir in all-in-one ldap logger mailbox mta proxy onlyoffice; do
	pushd $dir
	bash build.sh
	popd
done
