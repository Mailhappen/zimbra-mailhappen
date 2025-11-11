# Zimbra Migration Script

We wrote this script to help migrate/upgrade old Zimbra to the latest version easily.

It is not the normal way Zimbra will recommend because it could be too hard to support. But you like challenges, don't you?

Do let us know if you find this script helpful. You could learn so much about Zimbra as a result of this.

## General migration objectives

We wanted to upgrade our Zimbra to the latest version and also change the OS at the same time. And don't touch the current server. By doing this way, it is safe and no downtime. Once we have done what we needed, we can plan on the actual migration.

We can also rebuild Zimbra cleanly using this method because we only copy the data over. No binary will be copied.

This upgrade process is fast because we do not copy /store and /index. We only copy over the LDAP and MySQL data. Once it is upgraded, you can copy in the /store and /index directly into the newly upgraded server.

## Prepare for upgrade

Normally you will create a new VM that is the same spec as the old one. You will use the same hostname but different IP address. Remember we are cloning data over, so both old and new server are supposed to be the same config.

You could test install new Zimbra in the new server to see if it is running correctly or not. Then uninstall it and begin our migration step.

## List of Zimbra to download

We tested our script on Rocky Linux 9 and the [Zimbra FOSS 10.1.10p3](https://github.com/maldua/zimbra-foss-builder/releases/download/zimbra-foss-build-rhel-9%2F10.1.10.p3/zcs-10.1.10_GA_4200003.RHEL9_64.20251107221239.tgz) by Maldua.

## References

1. [Maldua FOSS Release](https://github.com/maldua/zimbra-foss-builder/releases)
2. [Mailhappen Zimbra](https://github.com/mailhappen)

