# Quickstart

This guide show you how to quickly run Zimbra 10.1.x in docker.

## Prepare a Virtual Machine

You need a server to run the container. You could use an existing VM that already have the docker installed.

For minimum setup, consider this:

- CPU Core: 4
- Memory: 8GB
- Hard Disk: 50GB for /, 100GB for /var/lib/docker. Or just one disk with 100GB for /.
- Operating System: We prefer Debian, RockyLinux and Ubuntu (not in particular order)

## Install Docker Engine

Refer to [INSTALL DOCKER](INSTALL-DOCKER.md).

## Run Zimbra Docker

Clone our repository and run it.

```
git clone https://github.com/Mailhappen/zimbra-mailhappen.git
cd zimbra-mailhappen
cd Deploy
cp compose-aio.yaml compose.yaml
cp container-aio.conf container.conf
cp env-sample .env
bash scripts/create-volume.sh my-aio-vol
docker compose build
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

If the new version such as `yeak/zimbraimage:10.1.8` become available, you can simply edit Dockerfile to change to the new image version. Then rebuild.

```
vi Docker
docker compose build
docker compose down
docker compose up -d
```

