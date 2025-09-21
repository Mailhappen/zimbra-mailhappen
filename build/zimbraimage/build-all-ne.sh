#!/bin/bash

for dir in all-in-one-ne ldap-ne logger-ne mailbox-ne mta-ne proxy-ne onlyoffice-ne; do
	pushd $dir
	bash build.sh
	popd
done
