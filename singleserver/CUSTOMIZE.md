# Customize Zimbra

The compose.yaml file has helped to ease deploying Zimbra in consistent manner. However many sites have their own post deployment setup. For example, logo, zimlets, MTA config, spamassassin and more. This is where `custom` folder is for.

You can copy `custom-sample` to `custom` and begin modifying to suit your needs.

The default given is based on one of our production servers. You can just start up the container to see the complete of it.

## How to write scripts

The script should be written such that it can be run multiple time against the running container. You may take this as post-install scripts.

If you have special requirement you can reach out to us to help creating it.

The scripts will only be executed if it is set to executable (chmod +x). We skip folders. So you can use folder to organize your scripts.

## Folder permission of `custom`

The folder may be owned by root user if you didn't create it in the first place. You can simply change the ownership to yourself.

