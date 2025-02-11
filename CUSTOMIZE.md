# Customize Zimbra

The compose.yaml file has helped to ease deploying Zimbra in consistent manner. However many sites have their own post deployment setup. For example, logo, zimlets, MTA config, spamassassin and more. This is where `custom` folder is for.

You can copy `custom-sample` to `custom` and begin modifying to suit your needs.

The default given is based on one of our production servers. You can just start up the container to see the complete of it.

## How to write scripts

The script should be written such that it can be run multiple time against the running container. You may take this as post-install scripts.

If you have special requirement you can reach out to us to help creating it.

The scripts will only be executed if it is set to executable (chmod +x). We skip folders. So you can use folder to organize your scripts.

## Information about the scripts

1. 00_template.sh - template to copy to create a new script
1. 01_install-logo.sh - set your own Zimbra logo. Require included logo.svg
1. 01_zmstat-cleanup.sh - add crontab to auto clean up zmstat
1. 10_zimlet-maldua-2fa.sh - install Maldua-2FA zimlet
1. 10_zimlet-undosend.sh - install Undosend zimlet for Classic UI
1. 11_mta-alternatives.sh - set Zimbra as preferred MTA so that `mailq` work
1. 11_mta-postconf.sh - postfix main.cf customization
1. 11_mta-zmconfigd.sh - mta configuration managed by zmconfigd
1. 11_mta-mynetworks.sh - customize my own mynetworks
1. 11_mta-null-altermime.sh - workaround for altermime with null content
1. 11_mta-sauser.sh - my custom spamassassin rules
1. 20_acme.sh - generate letsencrypt cert
1. logo.svg - used by install-logo script

More to come as we learn along the way.

