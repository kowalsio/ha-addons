ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:9.2.1
FROM ${BUILD_FROM}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base=0.5-r2 \
        git=2.30.2-r0 \
    \
    && apk add --no-cache \
        go=1.15.12-r0 \
        openresolv=3.12.0-r0 \
        wireguard-tools=1.0.20200827-r1 \
    \
    && git clone --branch "0.0.20210212" --depth=1 \
        "https://git.zx2c4.com/wireguard-go" /tmp/wireguard \
    \
    && cd /tmp/wireguard \
    && make \
    && make install \
    \
    && rm -f -r /tmp/* \
    && apk del --no-cache --purge \
        .build-dependencies \
        go

# Copy root filesystem
COPY rootfs /
