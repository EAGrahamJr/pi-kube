#!/bin/sh
IMAGE="rabbit:3"

# latest stable
VER="3.7.12"
DEB="rabbitmq-server_${VER}-1_all.deb"
MQ_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v$VER/$DEB"

# https://github.com/rabbitmq/rabbitmq-server/releases/download/v${VER}/

# clean, download everything, build the image
echo "Removing local image $IMAGE"
docker rmi -f ${IMAGE}

if [ ! -f "$DEB" ] ; then
    echo "Fetching .deb file for RabbitMQ"
    echo ${MQ_URL}
    curl -LOf ${MQ_URL}
    [ $? -ne 0 ] && exit 1
fi
docker build -t ${IMAGE} --build-arg RVER=${RVER} --build-arg DEB=${DEB} .
