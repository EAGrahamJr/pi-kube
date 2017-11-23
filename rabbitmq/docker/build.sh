#!/bin/sh
IMAGE="rabbit:2"

# include auto-cluster just in case it's needed
AUTOVER="0.10.0"
AUTO_TGZ="autocluster-${AUTOVER}.tgz"
AUTO_URL="https://github.com/aweber/rabbitmq-autocluster/releases/download/$AUTOVER/$AUTO_TGZ"

# latest stable
DL_VERION="rabbitmq_v3_6_14"
BLD_VERSION="3.6.14-1_all"

DEB="rabbitmq-server_${BLD_VERSION}.deb"
MQ_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/${DL_VERSION}/$DEB"

# clean, download everything, build the image
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
