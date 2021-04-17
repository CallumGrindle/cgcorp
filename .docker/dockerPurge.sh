#!/usr/bin/env bash

# Delete all containers
docker rm -fv $(docker ps -a -q)
# Delete all images
docker rmi $(docker images -q)

docker system prune
