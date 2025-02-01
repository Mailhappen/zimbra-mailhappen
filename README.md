# Deploy Zimbra in Docker

Deploying Zimbra in Docker has these benefits:
1. Able to test the deployment before going live.
2. The deployment will be consistent with what we have tested.
3. Easier to train new team member to learn Zimbra.

This project covers the following:
1. Compile the latest zcs installer from the Zimbra official github.
2. Create the Zimbra docker image.
3. Easy upgrade to a newer vesion by simply redeploying the container.

Basically we try to simplify the Zimbra deployment so that you don't have to worry about OS preparation, Zimbra installation, tuning and troubleshooting. We also put in customizations whenever possible to ensure consistent result after upgrade.

## How to build your own Zimbra FOSS installer and images

The `build-images` contains scripts to make your own Zimbra FOSS.

- `zm-base-os` prepares the RockyLinux9 build environment for compiling Zimbra FOSS
- `baseimage` is the RockyLinux9 OS image for running Zimbra
- `zimbraimage` is the Zimbra FOSS image designed to run as container.

You are encouraged to build your own zcs tgz file. Please refer to `build-images/build-10.*.sh` for details.

Example to build Zimbra FOSS 10.1.5,

```
$ cd build-images
$ bash build-10.1.5.sh
```

This will take a while to complete. You will get a docker image called `yeak/zimbraimage:10.1.5` in your images list.

You can skip the building steps and use the images we have made and published in Docker Hub. Refer to [QUICKSTART](QUICKSTART.md) for guide.

## Test run Zimbra

Create a `compose.yaml` file from the sample given.

```
$ cp compose-sample.yaml compose.yaml
$ vi compose.yaml
$ docker compose up -d
```

- Edit `image:` section to specify the zcs version you want to deploy. We currently have 10.1.5 only
- Edit `container-name:` section for your `hostname` and `environment`
- Leave the `volumes:` section as is. You can enhance it later with external volumes.

For day-to-day operation, if you need to stop Zimbra, simply do this:

```
$ docker compose stop
$ docker compose start
```

When there is new image available, you simply do this:

```
$ docker compose pull
$ docker compose down
$ docker compose up -d
```

Everytime when you down and up the container, it will take a while to start up because it needs to reconfigure itself.

To view any progress when container is starting, type:

```
$ docker compose logs -f
```

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
