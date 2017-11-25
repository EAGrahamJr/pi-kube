#!/bin/sh
IMAGE="rabbit:2"

# include auto-cluster just in case it's needed
AUTOVER="0.10.0"
AUTO_FILE="autocluster-${AUTOVER}.ez"
AUTO_URL="https://github.com/rabbitmq/rabbitmq-autocluster/releases/download/$AUTOVER"
# which also requires the AWS plugin, apparently
AUTO_AWS="rabbitmq_aws-${AUTOVER}.ez"

# latest stable
VER="3_6_14"
RVER="3.6.14"
DEB="rabbitmq-server_$RVER-1_all.deb"
MQ_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v$VER/$DEB"

# clean, download everything, build the image
echo "Removing local image $IMAGE"
docker rmi -f ${IMAGE}

if [ ! -f "$DEB" ] ; then
    echo "Fetching .deb file for RabbitMQ"
    echo ${MQ_URL}
    curl -LOf ${MQ_URL}
    [ $? -ne 0 ] && exit 1
fi

if [ ! -f "$AUTO_FILE" -o -f "$AUTO_AWS" ]; then
    [ $? -ne 0 ] && exit 1
    echo "${AUTO_URL}/${AUTO_AWS}"
    curl -LOf ${AUTO_URL}/${AUTO_AWS}
    [ $? -ne 0 ] && exit 1
fi

docker build -t ${IMAGE} --build-arg RVER=${RVER} --build-arg DEB=${DEB} .
