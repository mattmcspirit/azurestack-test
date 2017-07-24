#!/bin/bash

DOCKER_VERSION=$1
echo "DOCKER_VERSION: $DOCKER_VERSION"
UCP_VERSION=$2
echo "UCP_VERSION: $UCP_VERSION"

#  SECTION - CHECK VARIABLES EXIST

if [ -z "$UcpVersion" ]; then
    echo 'UcpVersion is undefined'
    exit 1
fi


#  SECTION - INSTALL DOCKER

apt-get update
apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable test"
apt-get update
apt-get install -y docker-ce
sleep 10

# SECTION - INSTALL UCP

#install UCP agents

docker pull docker/ucp-dsinfo:$UCP_VERSION
docker pull docker/ucp-agent:$UCP_VERSION

docker run --rm docker/ucp-agent:$UCP_VERSION
