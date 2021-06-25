#!/usr/bin/env bash

set -euo pipefail

current_version=$(docker run --rm ubuntu:20.04 \
  bash -c 'apt-get update > /dev/null 2>&1 && apt-cache show nvidia-kernel-source-460' \
  | grep '^Version:' | cut -d' ' -f2 | cut -d'-' -f1)

if [ -z "$current_version" ] ; then
  echo "couldn't determine current version" >&2
  exit 1
fi

dockerfile=$(dirname "$0")/../Dockerfile
docker_version=$(grep '^ARG NVIDIA_DRIVER_VERSION=' "$dockerfile" | cut -d'=' -f2)

if [ -z "$docker_version" ] ; then
  echo "couldn't find version in Dockerfile" >&2
  exit 1
fi

if [ "$current_version" != "$docker_version" ] ; then
  echo "updating from $current_version to $docker_version"
  sed -i -E "/ARG NVIDIA_DRIVER_VERSION=/s/=.*/=$current_version/" "$dockerfile"
else
  echo "current version is up-to-date: $current_version"
fi
