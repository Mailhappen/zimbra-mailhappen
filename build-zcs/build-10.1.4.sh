#!/bin/bash

# Edit the version to build

GIT_DEFAULT_TAGS=10.1.4,10.1.3,10.1.2,10.1.1,10.1.0
BUILD_RELEASE_NO=10.1.4
BUILD_NO=1000

# Do not edit below
TMPDIR=./tmp.$$
mkdir ${TMPDIR}
cat > ${TMPDIR}/run.sh <<EOT
#!/bin/bash

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
EOT
chmod -R 777 ${TMPDIR}
docker run --rm -it \
	-v ${TMPDIR}:/home/build/installer-build \
	yeak/zm-base-os-rl9 /home/build/installer-build/run.sh
mv ${TMPDIR}/BUILDS/*/*.tgz .
rm -rf ${TMPDIR}
