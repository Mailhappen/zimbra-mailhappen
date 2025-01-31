#!/bin/bash

# Edit the version to build

GIT_DEFAULT_TAGS=10.1.3,10.1.2,10.1.1,10.1.0
BUILD_RELEASE_NO=10.1.3
BUILD_CANDIDATE=GA
BUILD_NO=1000
BUILD_TS=`date +'%Y%m%d%H%M%S'`
BUILD_TYPE=FOSS

# Prepare volumes and stuffs
[ ! -d ./data ] && ( mkdir ./data; chmod 777 ./data )

RUN=./data/run-${BUILD_RELEASE_NO}.sh
cat > ${RUN} <<EOT
#!/bin/bash

mkdir installer-build
cd installer-build
#git clone --depth 1 --branch ${BUILD_RELEASE_NO} https://github.com/Zimbra/zm-build.git
git clone --depth 1 https://github.com/Zimbra/zm-build.git
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
	docker run -it \
		-v ./data:/data \
		zm-base-os \
		/data/run-${BUILD_RELEASE_NO}.sh
fi

# 3. Make the yeak/baseimage for deployment
docker build -t yeak/baseimage ./baseimage

# 4. Make the yeak/zimbraimage for deployment
cp -f ./data/${ZCS}.tgz ./zimbraimage
docker build -t yeak/zimbraimage:${BUILD_RELEASE_NO} \
	--label name=zimbra \
	--label version=${BUILD_RELEASE_NO} \
	--label candidate=${BUILD_CANDIDATE} \
	--label build=${BUILD_NO} \
	--label type=${BUILD_TYPE} \
	--build-arg ZCS=${ZCS} \
	./zimbraimage
rm -f ./zimbraimage/${ZCS}.tgz
