#!/bin/bash

for dir in all-in-one ldap logger mailbox mta proxy; do
	pushd $dir
	bash build.sh
	popd
done
