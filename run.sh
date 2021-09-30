#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/pgwatch.docker
docker volume create pgwatch
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker stop pgwatch || echo $?
docker rm pgwatch || echo $?
docker run \
    --detach \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PW2_DATASTORE=postgres \
    --env PW2_PGDATABASE=pgwatch \
    --env PW2_PGHOST=/run/postgresql \
    --env PW2_PGUSER=pgwatch \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname pgwatch \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=volume,source=pgwatch,destination=/home \
    --name pgwatch \
    --network name=docker \
    --restart always \
    ghcr.io/rekgrpth/pgwatch.docker su-exec pgwatch:pgwatch pgwatch2
