#!/bin/sh
IMAGE="rabbit:1"
AUTOVER="0.6.1"
AUTO_TGZ="autocluster-${AUTOVER}.tgz"
AUTO_URL="https://github.com/aweber/rabbitmq-autocluster/releases/download/$AUTOVER/$AUTO_TGZ"

DEB="rabbitmq-server_3.6.5-1_all.deb"
MQ_URL="https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/$DEB"

echo "Removing local image $IMAGE"
docker rmi -f ${IMAGE}

if [ ! -f "$DEB" ] ; then
    rm -rf *.deb
    echo "Fetching .deb file for RabbitMQ"
    curl -L -O ${MQ_URL}
fi

if [ ! -f "$AUTO_TGZ" ]; then
    rm -rf *.tgz
    echo "Fetching autocluster plugin, version $AUTOVER"
    curl -L -O ${AUTO_URL}
    tar -xvf ${AUTO_TGZ}
fi

echo "$(date) - Starting build..."
docker build -t ${IMAGE} .
echo "$(date) - Complete"
