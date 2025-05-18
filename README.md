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

You are welcomed to build your own zcs tgz file. Please refer to `build-images/build-10.*.sh` for details.

Example to build Zimbra FOSS 10.1.7,

```
$ cd build-images
$ bash build-10.1.7.sh
$ bash make-zimbraimage
```

This will take a while to complete. You will get a tgz in ./data directory. This is the usual zcs installer you used to install Zimbra FOSS. You will also get a docker image named `yeak/zimbraimage:10.1.7` for container deployment.

NOTE: You can skip the building steps and use the images we have made and published in Docker Hub. Refer to [QUICKSTART](QUICKSTART.md) for guide.

## Test run Zimbra

When deploying Zimbra, decide if you want to run *singleserver* or *multiserver*. Note, at this moment only singleserver is ready to try.

### Singleserver

Go into `singleserver` directory and build the docker image that run as singleserver.

```
$ cd singleserver
$ vi Dockerfile
$ docker build .
```

Check and update the ZIMBRAIMAGE version to the version you wanted. The build command will create `yeak/singleserver` using the version you specified.

Now you can run it.

```
$ bash create-local-volume.sh
$ cp compose-local.yaml compose.yaml
$ vi compose.yaml
$ docker compose up -d
```

- Edit `hostname:` to suit your need.
- Edit other environment variable to set the default password.
- Leave the `volumes:` section as is.

For day-to-day operation, if you need to stop Zimbra, simply do this:

```
$ docker compose stop
$ docker compose start
```

When there is new Zimbra version released, there will be new build script available and you just recreate the new zimbraimage. Then update Dockerfile to use the new version to build your `yeak/singleserver` again.

One example is to use what we built and published at Docker Hub.

```
$ docker pull yeak/zimbraimage:10.1.8
$ docker build --build-arg ZIMBRAIMAGE=yeak/zimbraimage:10.1.8 .
$ docker compose down
$ docker compose up -d
```

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
