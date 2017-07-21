#!/bin/bash
# 1ST SECTION - CAPTURE ARGUMENTS FROM ARM TEMPLATE AS VARIABLES

UCP_PUBLIC_FQDN=$1
echo "UCP_PUBLIC_FQDN: $UCP_PUBLIC_FQDN"
DTR_PUBLIC_FQDN=$2
echo "DTR_PUBLIC_FQDN: $DTR_PUBLIC_FQDN"
UCP_ADMIN_PASSWORD=$3
echo "UCP_ADMIN_PASSWORD: $UCP_ADMIN_PASSWORD"
UCP_VERSION=$4
echo "UCP_VERSION: $UCP_VERSION"
DTR_VERSION=$5
echo "DTR_VERSION: $DTR_VERSION"
DOCKER_VERSION=$6
echo "DOCKER_VERSION: $DOCKER_VERSION"
HUB_PASSWORD=$7
echo "HUB_PASSWORD: $HUB_PASSWORD"
HUB_USERNAME=$8
echo "HUB_USERNAME: $HUB_USERNAME"

# 2ND SECTION - CHECK VARIABLES EXIST

if [ -z "$UCP_PUBLIC_FQDN" ]; then
    echo 'UCP_PUBLIC_FQDN is undefined'
    exit 1
fi

if [ -z "$UCP_ADMIN_PASSWORD" ]; then
    echo 'UCP_ADMIN_PASSWORD is undefined'
    exit 1
fi

if [ -z "$DTR_PUBLIC_FQDN" ]; then
    echo 'DTR_PUBLIC_FQDN is undefined'
    exit 1
fi

if [ -z "$HUB_USERNAME" ]; then
    echo 'HUB_USERNAME is undefined'
    exit 1
fi

# 3RD SECTION - INSTALL DOCKER

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

# 4TH SECTION - INSTALL UCP

echo "UCP_PUBLIC_FQDN=$UCP_PUBLIC_FQDN"
service docker restart

#docker login -p $HUB_PASSWORD -u $HUB_USERNAME

#docker run dockerorcadev/ucp:$UCP_VERSION images --list --image-version dev: | xargs -L 1 docker pull

docker pull docker/ucp:$UCP_VERSION

docker run --rm --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:$UCP_VERSION \
  install --san $UCP_PUBLIC_FQDN --admin-password $UCP_ADMIN_PASSWORD --debug

sleep 10

# 5TH SECTION - INSTALL DTR

if [ -z "$UCP_NODE"]; then
  export UCP_NODE=$(docker node ls | grep mgr0 | awk '{print $3}');
fi

docker run --rm \
  docker/dtr:$DTR_VERSION install \
  --ucp-url $UCP_PUBLIC_FQDN \
  --ucp-node $UCP_NODE \
  --dtr-external-url $DTR_PUBLIC_FQDN \
  --ucp-username admin --ucp-password $UCP_ADMIN_PASSWORD \
  --ucp-insecure-tls \
  --replica-https-port 8443 \
