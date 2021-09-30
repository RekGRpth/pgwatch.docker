FROM ghcr.io/rekgrpth/gost.docker
ENV GROUP=pgwatch \
    USER=pgwatch
RUN set -eux; \
    mkdir -p "${HOME}"; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}"; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build-deps \
        git \
        go \
    ; \
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    git clone https://github.com/RekGRpth/pgwatch2.git; \
    cd "${HOME}/src/pgwatch2/pgwatch2"; \
    go build pgwatch2.go prom.go patroni.go logparse.go; \
    cp -f pgwatch2 /usr/local/bin/; \
    cd /; \
    apk add --no-cache --virtual .pgwatch-rundeps \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
        su-exec \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod -R 0755 /usr/local/bin; \
    echo done
