#!/bin/bash

for dir in all-in-one ldap logger mta mailbox proxy; do
	pushd $dir
	bash build.sh
	popd
done
