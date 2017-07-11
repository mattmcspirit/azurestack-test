#!/bin/bash
if [ -z "$UCP_PUBLIC_FQDN" ]; then
    echo 'UCP_PUBLIC_FQDN is undefined'
    exit 1
fi

if [ -z "$UCP_ADMIN_PASSWORD" ]; then
    echo 'UCP_ADMIN_PASSWORD is undefined'
    exit 1
fi

echo "UCP_PUBLIC_FQDN=$UCP_PUBLIC_FQDN"

#start docker service
sudo service docker start

docker login -p $HUB_PASSWORD -u $HUB_USERNAME

#install UCP
docker run dockerorcadev/ucp:$UCP_VERSION images --list --image-version dev: | xargs -L 1 docker pull
docker run --rm --name ucp \
  -e REGISTRY_USERNAME=$HUB_USERNAME -e REGISTRY_PASSWORD=$HUB_PASSWORD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  dockerorcadev/ucp:$UCP_VERSION \
  install --san $UCP_PUBLIC_FQDN --admin-username ddcadmin --admin-password $UCP_ADMIN_PASSWORD --debug --image-version dev:
