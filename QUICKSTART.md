# Quickstart

This guide show you how to quickly run Zimbra in docker.

## Prepare a Virtual Machine

You need a server to run the container. You could also try it on your Linux desktop.

For minimum setup, consider this:

- CPU Core: 4
- Memory: 8GB
- Hard Disk: 50GB for /, 100GB for /var/lib/docker. Or just one disk with 100GB for everything.
- Operating System: Debian, Rocky Linux or Ubuntu (not in particular order)

Production environment should have 6CPU and 16GB RAM.

## Install Docker Engine

Refer to [INSTALL DOCKER](INSTALL-DOCKER.md).

## Run Zimbra in Docker

Clone our repository and run it.

```
git clone https://github.com/Mailhappen/zimbra-mailhappen.git
cd zimbra-mailhappen
cd deploy
cp compose-aio.yaml compose.yaml
cp container-aio.conf container.conf
cp env-sample .env
bash scripts/create-volume.sh my-aio-vol
docker compose build
docker compose up -d
docker compose logs -f
```

Once the container is up, you can access Zimbra WebClient at https://yourserver/ and Admin Console at https://yourserver:7071/.

The default login is `mailadmin` and the password is `Zimbra`.

To customize for your deployment, edit:
1. Change `DEFAULT_DOMAIN` in `.env` file.
2. Change password in `secrets/admin_password`.
3. Optionally change password in `secrets/{ldap_admin_pass,ldap_root_pass}`.

## Useful info to manage the container

### Stop and start container

```
docker compose stop
docker compose start
```

This stop the container like poweroff your server.

### Upgrade to the new Zimbra version

When the new version is available, edit the file `.env` and change `VERSION` to the new one. Then rebuild and restart.

```
docker compose build
docker compose down
docker compose up -d
```

### What about down/up instead of stop/start?

You can also do this to bring down container and up.

```
docker compose down
docker compose up -d
```

The command `down` will remove the container, like delete the entire server away. When you `up` again later, a new container is started from scratch. We have handled this automatically so you can safely down and up the container with data intact. However we recommend to do this only during the upgrade process.

### What about commit?

You can do this to save your running container data back into image.

```
docker compose config --services
docker compose config --images
docker compose commit zimbra-aio mail.zimbra.lab
```

The output of `--services` show you the running containers. The `--images` show you the images. Then the `docker compose commit <service> <image>` tells the compose to save the running container back into the given image file.

This way, all data is saved and the next time you bring up the container, it will have all your changes retained.

Take note when you rebuild your images using `docker compose build`, your saved image will be overriden (it is still there, just no label given). To save another copy, simple run this:

```
docker compose commit zimbra-aio mail.zimbra.lab:bak2025
```

This save the running container into a new name `mail.zimbra.lab:bak2025`.

## Learn More

1. https://docs.docker.com/get-started/
2. https://docs.docker.com/compose/
3. https://docs.docker.com/engine/install/

We offer Docker lesson. Do contact us.

