# Quickstart

This guide show you how to quickly run your own Zimbra 10.1.x in container, with style...

## Prepare a Virtual Machine

You need a server to run the container. You could use an existing VM that already have the docker installed.

For minimum setup, consider this:

- CPU Core: 4
- Memory: 8GB
- Hard Disk: 50GB for /, 100GB for /var/lib/docker. Or everything in / also work.
- Operating System: We prefer Debian, RockyLinux and Ubuntu (not in particular order)

## Install Docker Engine if not yet done

Refer to [INSTALL DOCKER](INSTALL-DOCKER.md) for info.

## Run Zimbra Docker

Clone our repository and run it.

```
git clone https://github.com/Mailhappen/zimbra-mailhappen.git
cd zimbra-mailhappen
cd singleserver
bash create-local-volume.sh
cp compose-local.yaml compose.yaml
cp config.secrets.sample config.secrets
docker compose build .
docker compose up -d
docker compose logs -f
```

You may edit `compose.yaml` and `config.secrets` to set your preferences.

The default admin will be `mailadmin` and password is `Zimbra`.

The container is running and you can visit the Zimbra Admin Console at https://your-vm:7071/.

## Other useful commands

### Stop and start container

```
docker compose stop
docker compose start
```

### Upgrade to newer Zimbra release

If the new version to upgrade is `yeak/zimbraimage:10.1.8`,

```
docker pull yeak/zimbraimage:10.1.8
docker build --build-arg ZIMBRAIMAGE=yeak/zimbraimage:10.1.8 .
docker compose down
docker compose up -d
```

