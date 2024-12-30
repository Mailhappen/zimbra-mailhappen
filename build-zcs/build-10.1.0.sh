#!/bin/bash

# Edit the version to build

GIT_DEFAULT_TAGS=10.1.0
BUILD_RELEASE_NO=10.1.0
BUILD_NO=1001

# Prepare volumes and stuffs
[ ! -d ./data ] && ( mkdir ./data; chmod 777 ./data )

RUN=./run.sh.$$
cat > ${RUN} <<EOT
#!/bin/bash

mkdir installer-build
cd installer-build
git clone --depth 1 https://github.com/Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl \
	--ant-options \
	-DskipTests=true \
	--git-default-tag=${GIT_DEFAULT_TAGS} \
	--build-no=${BUILD_NO} \
	--build-ts=`date +'%Y%m%d%H%M%S'` \
	--build-release-no=${BUILD_RELEASE_NO} \
	--build-type=FOSS \
	--build-release=LIBERTY \
	--build-release-candidate=GA \
	--build-thirdparty-server=files.zimbra.com \
	--no-interactive
cp -vf ../BUILDS/*/*.tgz /data

EOT
chmod 777 ${RUN}
docker run -it \
	-v ${RUN}:/run.sh \
	-v ./data:/data \
	yeak/zm-base-os-rl9 /run.sh

# clean up
rm -f ${RUN}
