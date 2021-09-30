#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/pgwatch.docker
docker volume create pgwatch
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker stop pgwatch || echo $?
docker rm pgwatch || echo $?
docker run \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PGDATABASE=pgwatch \
    --env PGHOST=/run/postgresql \
    --env PGUSER=pgwatch \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname pgwatch \
    --interactive \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=pgwatch,destination=/home \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --name pgwatch \
    --network name=docker \
    --rm \
    --tty \
    ghcr.io/rekgrpth/pgwatch.docker su-exec pgwatch:pgwatch pgwatch2
