#!/usr/bin/env bash
# Applies the specified file that has a Docker image and substitutes the parameter for the image name
# Assumes the image name is "{{ docker-repo }}/{{ docker-image }}"
FILE="$1"
REPO="$2"
IMAGE="$3"

cat ${FILE} | sed s/"{{ docker-repo }}"/"$REPO"/g | sed s/"{{ docker-image }}"/"$IMAGE"/g | kubectl apply -f -
