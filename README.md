# Deploy Zimbra Mailhappen

## Description
Deploying Zimbra in Docker manner has these benefits:
1. Able to test the deployment before going live.
2. The deployment will be consistent with what we have packaged.
3. Easily train new team to pick up Zimbra.

This docker covers the following:
1. Compile the latest zcs installer from the Zimbra official github.
2. Create the Zimbra docker image for container deployment.
3. Make it easy to upgrade to newer vesion by simply redeploying it.

Basically we simplify the Zimbra deployment so that you don't need to worry about OS preparation, Zimbra installation, post tuning and troubleshooting.

## How to build

The `build-images` contain scripts to make your own Zimbra FOSS.

- **zm-base-os**. This prepares the RockyLinux9 build environment for compiling Zimbra FOSS. It will create the zcs installer that you normally download from zimbra.com website.
- **baseimage**. This is the OS image to run Zimbra in production.
- **zimbraimage**. This is Zimbra image for you to deploy Zimbra in container.

You are encouraged to build your own zcs tgz file. Please refer to `build-images/build-10.*.sh` for details.

Example to build Zimbra FOSS 10.1.5,

```
cd build-images
bash build-10.1.5.sh
```

It will take a while to complete the building. The result will be a docker image called **yeak/zimbraimage:10.1.5** in your own computer.

You can ignore this step. Just continue reading below to use what we have published to Docker Hub.

## Test run Zimbra

Create a `compose.yaml` file from the sample given. Our sample is a working sample.

```
cp compose-sample.yaml compose.yaml
vi compose.yaml
```

NOTE:
1. Edit *image* to use the zcs version you want to deploy.
2. Edit *container-name*, *hostname*, and *environment* to your site.
3. Leave the *volumes* as is. You can enhance it later with external volumes.

This is all you need to run Zimbra normally:

1. `docker compose up -d`
2. `docker compose stop`
3. `docker compose start`

When there is new image available, you simply do this:

1. `docker compose pull`
2. `docker compose down`
3. `docker compose up -d`

NOTE:
Everytime when you `down` and `up` the container, it will take a while to start up because it needs to reconfigure itself. This is similar to process of downloading new zcs release and run install.sh to upgrade your Zimbra. Now it is all automated.

To view any progress when container is starting, type `docker compose logs -f`.

## Support
Use the Github issue to open case.

## Roadmap
We will continue to keep up with new updates from Zimbra Github.

## Contributing
We accept contribution. You can reach out to yeak at mailhappen dot com to state your intention.

## Authors and acknowledgment
Kudos to Zimbra for having FOSS available in Github.

## License
See LICENSE file.

## Project status
This is always on-going.
