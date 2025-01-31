# Quickstart

This guide show you how to quickly run your own Zimbra 10.1.x in container with style...

## Prepare a Virtual Machine

You need a server to run the container. You could use an existing VM that already have the docker installed.

For minimum setup, consider this:

- CPU Core: 4
- Memory: 8GB
- Hard Disk: 50GB for /, 100GB for /var/lib/docker. Or everything in / also work.
- Operating System: We prefer Debian, RockyLinux and Ubuntu (not in particular order)

## Install Docker Engine if not yet done

Refer to (INSTALL-DOCKER.md) for info.

## Run Zimbra Docker

Clone our repository and run it.

```
git clone https://github.com/Mailhappen/zimbra-mailhappen.git
cd zimbra-mailhappen
cp compose-sample.yaml compose.yaml
docker compose up -d
docker compose logs -f
```

The container is running and you can visit the Zimbra Admin Console at https://your-vm:7071/.

## Other useful commands

```
# Stop the container
docker compose stop

# Start the container
docker compose start

# Upgrade container
docker compose pull
docker compose down
docker compose up -d
```

