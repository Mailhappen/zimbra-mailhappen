# Deploy Zimbra in Docker

Deploying Zimbra in Docker has these benefits:

1. Able to test the deployment before going live.
2. The deployment will be consistent with what we have built.
3. Start using Zimbra quickly.

This project covers:

1. Create the latest zcs installer from the source.
2. Create the Rocky Linux docker image for Zimbra use.
3. Create the Zimbra image.
4. Deploying Zimbra AIO or Multiserver in Docker.

## Build your own Zimbra FOSS installer and images

The `Build` folder contains scripts used to build your own Zimbra FOSS until the Docker images.

- `zcs` - create the zcs-10.1.x...tgz from the source
- `osimage` - create the Rocky Linux 9 OS image for running Zimbra
- `zimbraimage` - create Zimbra image with `--softwareonly`

NOTE: You can skip the building and just use the images we have published in Docker Hub. Refer to [QUICKSTART](QUICKSTART.md).

## Deploy Zimbra

When deploying Zimbra, decide if you want to run *singleserver* (AIO) or *multiserver*. Most site should just stick to AIO.

Refer to [QUICKSTART](QUICKSTART.md) for deployment.

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
