#!/bin/bash

# Edit the version to build

GIT_DEFAULT_TAGS=10.1.7,10.1.6,10.1.5,10.1.4,10.1.3,10.1.2,10.1.1,10.1.0
BUILD_TAG=10.1.6
BUILD_RELEASE_NO=10.1.7
BUILD_CANDIDATE=GA
BUILD_NO=1040000
BUILD_TS=`date +'%Y%m%d%H%M%S'`
BUILD_TYPE=FOSS

# Prepare volumes and stuffs
[ ! -d ./data ] && ( mkdir ./data; chmod 777 ./data )

RUN=./data/run-${BUILD_RELEASE_NO}.sh
cat > ${RUN} <<EOT
#!/bin/bash

mkdir installer-build
cd installer-build
git clone --depth 1 --branch ${BUILD_TAG} https://github.com/Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl \
	--ant-options \
	-DskipTests=true \
	--git-default-tag=${GIT_DEFAULT_TAGS} \
	--build-no=${BUILD_NO} \
	--build-ts=${BUILD_TS} \
	--build-release-no=${BUILD_RELEASE_NO} \
	--build-type=${BUILD_TYPE} \
	--build-release=LIBERTY \
	--build-release-candidate=${BUILD_CANDIDATE} \
	--build-thirdparty-server=files.zimbra.com \
	--no-interactive
cp -vf ../BUILDS/*/*.tgz /data

EOT
chmod 777 ${RUN}

# 1. Make our zm-base-os for building use
docker build -t zm-base-os ./zm-base-os

# 2. Make the zcs installer if required. Result in ./data
if [ -f ./data/zcs-${BUILD_RELEASE_NO}* -a x"$1" != "xremake-installer" ]; then
	ZCS=`basename ./data/zcs-${BUILD_RELEASE_NO}*`
	ZCS=${ZCS%.tgz}
else
	ZCS=zcs-${BUILD_RELEASE_NO}_${BUILD_CANDIDATE}_${BUILD_NO}.RHEL9_64.${BUILD_TS}
	docker run -it --rm \
		-v ./data:/data \
		zm-base-os \
		/data/run-${BUILD_RELEASE_NO}.sh
fi

ls ./data
