# Deploy Zimbra Mailhappen

## Description
Deploying Zimbra in Docker manner has these benefits:
1. Test the deployment in Lab environment before going live.
2. The deployment will be consistent with what we packaged.
3. Everything we do is properly recorded and able to pass down to new team.

## Build

The `build-installer` contain script to make your own Zimbra FOSS from Github.

The `deploy-zimbra` is using what we have compiled Zimbra FOSS to deploy Zimbra.

- **zm-base-os-rl9**. This prepare the RockyLinux9 build environment to run the compilation. See the script `build-10.*.sh` that actually carry out the making process.
- **baseimage**. This is the OS image that must include all rpms so that **zimbraimage** does not require to do any yum update task.
- **zimbraimage**. This is Zimbra image for you to deploy Zimbra.

## Usage
Create a `compose.yaml` file from the sample given.

NOTE:
You should only edit *container-name*, *hostname*, and all those in *environment* section.

Run Zimbra normally:

1. `docker compose up -d`
2. `docker compose stop`
3. `docker compose start`

Upgrade to newer version:

The method to upgrade Zimbra FOSS is to reconfigure it with the new image.

1. `docker compose pull`
2. `docker compose down`
3. `docker compose up -d`

NOTE:
Everytime when you do `down` and `up`, it will remove container and trigger a new reconfiguration process. This will take time.

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
